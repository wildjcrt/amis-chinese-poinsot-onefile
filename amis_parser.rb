class AmisDictionaryParser
  def initialize
    @dialect_codes = {
      "Ch" => "國語",
      "S" => "南方話",
      "F" => "鳳林話",
      "T" => "富田語",
      "J" => "日語",
      "Tw" => "閩南語",
      "N" => "北方話",
      "Z" => "撒奇萊雅語",
      "豐濱" => "豐濱",
      "英語" => "英語",
      "玉里" => "玉里",
      "Tingalaw" => "豐濱豐富部落",
      "希伯來語" => "希伯來語",
      "光復鄉" => "光復鄉",
      "希臘文" => "希臘文",
    }

    @results = []
  end

  def parse_line(line)
    return [] if line.strip.empty?

    # Split on the main colon separator
    parts = line.split('：', 2)
    return [] if parts.length < 2

    term_part = parts[0].strip
    description_part = parts[1].strip

    # Parse the term part to extract terms, stems, dialects, and synonyms
    term_info = parse_term_part(term_part)

    # Parse the description part to extract descriptions and examples
    desc_info = parse_description_part(description_part)

    # Generate results based on the parsed information
    generate_results(term_info, desc_info)
  end

  private

  def parse_term_part(term_part)
    parse_term_structure(term_part)
  end

  def parse_term_structure(term_part)
    result = {
      stems: [],
      terms: [],
      synonyms_groups: [],
      dialects: {},
      stem_derived_terms: [] # Track which terms are directly derived from stems
    }

    # Split by ' - ' to handle stem relationships and ' = ' for synonyms
    # First handle the case where we have both stems and synonyms
    if term_part.include?(' - ') && term_part.include?(' = ')
      # Pattern like: "stem - term1 {dialect} = term2"
      dash_parts = term_part.split(' - ', 2)
      stem = dash_parts[0].strip
      rest = dash_parts[1].strip

      # Parse the rest for synonyms and dialects
      synonym_info = parse_synonyms_and_dialects(rest)

      result[:stems] << stem
      synonym_info[:terms].each_with_index do |term, index|
        result[:terms] << term
        if synonym_info[:dialects][index] && !synonym_info[:dialects][index].empty?
          result[:dialects][term] = synonym_info[:dialects][index]
        end

        # Only the first term is stem-derived
        if index == 0
          result[:stem_derived_terms] << term
        end
      end
      result[:synonyms_groups] = [synonym_info[:terms]]

    elsif term_part.include?(' - ')
      # Pattern like: "stem - term1 - term2" or "stem - term {dialect}"
      parts = term_part.split(' - ')
      stem = parts[0].strip
      result[:stems] << stem

      terms_part = parts[1..-1].join(' - ')
      if terms_part.include?(' = ')
        # Handle case like "stem - term1 = term2"
        synonym_info = parse_synonyms_and_dialects(terms_part)
        synonym_info[:terms].each_with_index do |term, index|
          result[:terms] << term
          if synonym_info[:dialects][index] && !synonym_info[:dialects][index].empty?
            result[:dialects][term] = synonym_info[:dialects][index]
          end

          # Only the first term is stem-derived
          if index == 0
            result[:stem_derived_terms] << term
          end
        end
        result[:synonyms_groups] = [synonym_info[:terms]]
      else
        # Multiple terms from same stem: "stem - term1 - term2"
        parts[1..-1].each do |term_with_dialect|
          term, dialects = extract_term_and_dialects(term_with_dialect.strip)
          result[:terms] << term
          result[:stem_derived_terms] << term # All are stem-derived in this case
          result[:dialects][term] = dialects if dialects && !dialects.empty?
        end
      end

    elsif term_part.include?(' = ')
      # Pattern like: "term1 = term2 = term3"
      synonym_info = parse_synonyms_and_dialects(term_part)
      synonym_info[:terms].each_with_index do |term, index|
        result[:terms] << term
        if synonym_info[:dialects][index] && !synonym_info[:dialects][index].empty?
          result[:dialects][term] = synonym_info[:dialects][index]
        end
      end
      result[:synonyms_groups] = [synonym_info[:terms]]

    else
      # Single term, possibly with dialect
      term, dialects = extract_term_and_dialects(term_part)
      result[:terms] << term
      result[:dialects][term] = dialects if dialects && !dialects.empty?
    end

    result
  end

  def parse_synonyms_and_dialects(text)
    # Split by ' = ' and extract dialects from each part
    parts = text.split(' = ')
    terms = []
    dialects = []

    parts.each do |part|
      term, term_dialects = extract_term_and_dialects(part.strip)
      terms << term
      dialects << term_dialects
    end

    { terms: terms, dialects: dialects }
  end

  def extract_term_and_dialects(text)
    # Extract dialects in format {A}{B}{C}
    dialect_matches = text.scan(/\{([^}]+)\}/)
    dialects = dialect_matches.flatten.map { |code| @dialect_codes[code] }.compact

    # Remove dialect codes from term
    clean_term = text.gsub(/\s*\{[^}]+\}/, '').strip

    [clean_term, dialects]
  end

  def extract_dialects(dialect_part)
    dialect_matches = dialect_part.scan(/\{([^}]+)\}/)
    dialect_matches.flatten.map { |code| @dialect_codes[code] }.compact
  end

  def parse_description_part(description_part)
    result = {
      descriptions: [],
      examples: [],
      parenthetical_part: nil
    }

    # First check for examples with quotes (highest priority)
    quote_match = description_part.match(/^(.+?)\s*-\s*"([^"]+)"\s*\(([^)]+)\)\s*"([^"]+)"$/)
    if quote_match
      desc_text = quote_match[1].strip
      amis_example = quote_match[2].strip
      reference = quote_match[3].strip
      zh_translation = "#{reference}#{quote_match[4].strip}"

      result[:descriptions] = parse_descriptions(desc_text)
      result[:examples] << { amis: amis_example, zh: zh_translation }
      return result
    end

    # Check for simple examples
    example_match = description_part.match(/^(.+?)\s*-\s*([^：]+)：(.+)$/)
    if example_match
      desc_text = example_match[1].strip
      amis_example = example_match[2].strip
      zh_translation = example_match[3].strip

      result[:descriptions] = parse_descriptions(desc_text)
      result[:examples] << { amis: amis_example, zh: zh_translation }
      return result
    end

    # Parse descriptions and check for parenthetical content with dialect
    # Split by ；and check if last part has parenthetical + dialect pattern
    desc_parts = description_part.split('；').map(&:strip)

    # Check if the last part has parenthetical content with dialect
    if desc_parts.length > 1
      last_part = desc_parts.last
      # Pattern: (parenthetical)additional_text {dialect}
      parenthetical_match = last_part.match(/^\(([^)]+)\)(.+?)\s*(\{[^}]+\})$/)

      if parenthetical_match
        # Found parenthetical with dialect in last part
        parenthetical_part = parenthetical_match[1].strip
        additional_text = parenthetical_match[2].strip
        dialect_part = parenthetical_match[3]

        # Full description is parenthetical + additional text
        full_desc = "(#{parenthetical_part})#{additional_text}"

        # Main descriptions are all parts except the last one
        result[:descriptions] = desc_parts[0..-2]

        # Extract dialects and store parenthetical info
        if dialect_part
          dialects = extract_dialects(dialect_part)
          result[:parenthetical_part] = {
            description: full_desc,
            dialects: dialects
          }
        end

        return result
      end
    end

    # No parenthetical content, just regular descriptions
    if description_part.include?(' = ')
      result[:descriptions] = description_part.split(' = ').map(&:strip)
    else
      result[:descriptions] = desc_parts
    end

    result
  end

  def parse_descriptions(desc_text)
    # Split descriptions by '；' and handle '=' for alternative descriptions
    if desc_text.include?(' = ')
      desc_text.split(' = ').map(&:strip)
    else
      desc_text.split('；').map(&:strip)
    end
  end

  def generate_results(term_info, desc_info)
    results = []

    # Handle parenthetical entries from term part first
    if term_info[:parenthetical]
      # Create entry for the main term with parenthetical description
      main_term = term_info[:terms].first
      if main_term
        # Only assign stem if this term is stem-derived
        stem_to_assign = if term_info[:stem_derived_terms].include?(main_term)
                          term_info[:stems].first
                        else
                          nil
                        end

        results << create_entry(
          term: main_term,
          dialects: term_info[:parenthetical][:dialects],
          descriptions: [term_info[:parenthetical][:description]],
          stem: stem_to_assign
        )
      end

      # Create entries for main descriptions (excluding parenthetical)
      term_info[:terms].each do |term|
        next if term_info[:dialects][term] # Skip terms that already have dialects from parenthetical

        # Only assign stem if this term is stem-derived
        stem_to_assign = if term_info[:stem_derived_terms].include?(term)
                          term_info[:stems].first
                        else
                          nil
                        end

        results << create_entry(
          term: term,
          descriptions: desc_info[:descriptions],
          examples: desc_info[:examples],
          synonyms: get_synonyms_for_term(term, term_info[:synonyms_groups]),
          stem: stem_to_assign
        )
      end
    else
      # Regular processing - handle parenthetical from description part
      if desc_info[:parenthetical_part]
        # Create main entry with main descriptions
        term_info[:terms].each do |term|
          if !desc_info[:descriptions].empty?
            # Only assign stem if this term is stem-derived
            stem_to_assign = if term_info[:stem_derived_terms].include?(term)
                              term_info[:stems].first
                            else
                              nil
                            end

            entry = create_entry(
              term: term,
              descriptions: desc_info[:descriptions],
              examples: desc_info[:examples],
              dialects: term_info[:dialects][term],
              synonyms: get_synonyms_for_term(term, term_info[:synonyms_groups]),
              stem: stem_to_assign
            )
            results << entry
          end

          # Create separate entry for parenthetical part
          stem_to_assign = if term_info[:stem_derived_terms].include?(term)
                            term_info[:stems].first
                          else
                            nil
                          end

          parenthetical_entry = create_entry(
            term: term,
            descriptions: [desc_info[:parenthetical_part][:description]],
            dialects: desc_info[:parenthetical_part][:dialects],
            stem: stem_to_assign
          )
          results << parenthetical_entry
        end
      else
        # No parenthetical content - regular processing
        term_info[:terms].each do |term|
          # Only assign stem if this term is stem-derived
          stem_to_assign = if term_info[:stem_derived_terms].include?(term)
                            term_info[:stems].first
                          else
                            nil
                          end

          entry = create_entry(
            term: term,
            descriptions: desc_info[:descriptions],
            examples: desc_info[:examples],
            dialects: term_info[:dialects][term],
            synonyms: get_synonyms_for_term(term, term_info[:synonyms_groups]),
            stem: stem_to_assign
          )
          results << entry
        end
      end
    end

    results
  end

  def create_entry(term:, descriptions: [], examples: [], dialects: nil, synonyms: nil, stem: nil)
    entry = {}
    entry[:stem] = stem if stem && stem != term
    entry[:term] = term
    entry[:dialects] = dialects if dialects && !dialects.empty?

    if descriptions.length == 1
      entry[:description] = descriptions.first
    elsif descriptions.length > 1
      entry[:description] = descriptions
    end

    entry[:examples] = examples.first if examples && !examples.empty?
    entry[:synonyms] = synonyms if synonyms && !synonyms.empty?

    entry
  end

  def get_synonyms_for_term(term, synonym_groups)
    synonym_groups.each do |group|
      if group.include?(term)
        return group.reject { |t| t == term }
      end
    end
    nil
  end
end

parser = AmisDictionaryParser.new

# Read the file line by line
File.foreach('example.txt') do |line|
  puts "================================================"
  line.chomp!

  puts "Processing: #{line.inspect}"
  results = parser.parse_line(line)

  results.each do |entry|
    # Extract variables as requested
    term = entry[:term]
    stem = entry[:stem]
    dialet = entry[:dialects] # Note: keeping original typo from examples
    description = entry[:description]
    example = entry[:examples]
    synonym = entry[:synonyms]

    # Your processing logic here
    # You can now use these variables as needed
    puts "---"
    puts "term=#{term.inspect}"
    puts "stem=#{stem.inspect}" if stem
    puts "dialet=#{dialet.inspect}" if dialet
    puts "description=#{description.inspect}" if description
    puts "example=#{example.inspect}" if example
    puts "synonym=#{synonym.inspect}" if synonym
  end
end
require 'set'

class FileSpecialCharCollector
  def initialize
    # Known special characters
    @known_special_chars = Set.new(['-', '<', '>', '"', "'", '(', ')', '：', '{', '}', '=', '.', '/', '?', '；', '，', '。', '？'])
    # Set to collect unknown special characters
    @unknown_special_chars = Set.new
    @processed_lines = 0
    @lines_with_known_special_chars = 0
    @lines_with_unknown_special_chars = 0
  end

  def has_known_special_chars?(line)
    # Check if line contains any of the known special characters
    line.match?(/[<>"'()：{}'=.\/?；，。？-]/)
  end

  def collect_unknown_special_chars(line)
    found_unknown = false
    line.each_char do |char|
      # Skip if it's alphanumeric, whitespace, or Chinese characters
      next if char.match?(/[a-zA-Z0-9\s]/) || char.match?(/[\u4e00-\u9fff]/)
      next if @known_special_chars.include?(char)

      # This is an unknown special character
      @unknown_special_chars.add(char)
      found_unknown = true
    end
    found_unknown
  end

  def process_line(line)
    @processed_lines += 1

    has_known = has_known_special_chars?(line)
    has_unknown = collect_unknown_special_chars(line)

    @lines_with_known_special_chars += 1 if has_known
    @lines_with_unknown_special_chars += 1 if has_unknown

    { has_known: has_known, has_unknown: has_unknown }
  end

  def process_file(filename)
    unless File.exist?(filename)
      puts "Error: File '#{filename}' not found!"
      return
    end

    puts "Processing file: #{filename}"
    puts "=" * 60

    begin
      File.foreach(filename).with_index(1) do |line, line_number|
        line = line.chomp  # Remove newline character
        next if line.strip.empty?  # Skip empty lines

        result = process_line(line)

        # Optional: Print progress for large files (uncomment if needed)
        # if line_number % 1000 == 0
        #   puts "Processed #{line_number} lines..."
        # end

        # Optional: Print lines with unknown characters as they're found
        if result[:has_unknown] && @unknown_special_chars.size <= 50  # Limit output for large files
          # puts "Line #{line_number} has unknown chars: \"#{line.length > 100 ? line[0..100] + '...' : line}\""
        end
      end
    rescue => e
      puts "Error reading file: #{e.message}"
      return
    end

    print_summary
  end

  def print_summary
    puts "\n" + "=" * 60
    puts "PROCESSING SUMMARY"
    puts "=" * 60
    puts "Total lines processed: #{@processed_lines}"
    puts "Lines with known special chars: #{@lines_with_known_special_chars}"
    puts "Lines with unknown special chars: #{@lines_with_unknown_special_chars}"

    print_unknown_chars
  end

  def print_unknown_chars
    puts "\n" + "-" * 40
    if @unknown_special_chars.empty?
      puts "No unknown special characters found."
    else
      puts "UNKNOWN SPECIAL CHARACTERS FOUND:"
      puts "-" * 40
      puts "Characters: #{@unknown_special_chars.to_a.sort.join(' ')}"
      puts "\nDetailed list:"
      @unknown_special_chars.to_a.sort.each do |char|
        puts "  '#{char}' (Unicode: U+#{char.ord.to_s(16).upcase.rjust(4, '0')})"
      end
      puts "\nTo add to your known chars list:"
      puts @unknown_special_chars.to_a.sort.map { |c| "'#{c}'" }.join(', ')
    end
  end

  def get_unknown_chars
    @unknown_special_chars.to_a
  end
end

# Usage
def main
  if ARGV.empty?
    puts "Usage: ruby #{__FILE__} <filename>"
    puts "Example: ruby #{__FILE__} data.txt"
    exit 1
  end

  filename = ARGV[0]
  collector = FileSpecialCharCollector.new
  collector.process_file(filename)
end

# Alternative usage without command line arguments
def process_file(filename)
  collector = FileSpecialCharCollector.new
  collector.process_file(filename)
  collector.get_unknown_chars  # Return unknown chars if needed
end

# Run if called directly
main if __FILE__ == $0

# Example of how to use in code:
# collector = FileSpecialCharCollector.new
# collector.process_file("your_file.txt")

# Or use the helper function:
# unknown_chars = process_file("your_file.txt")
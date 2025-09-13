# 首字為中文，就合併到上一行

def merge_chinese_lines(text)
  lines = text.split("\n")
  result = []

  lines.each_with_index do |line, index|
    # Skip empty lines
    next if line.strip.empty?

    # For the first line, always add it to result
    if index == 0 || result.empty?
      result << line
      next
    end

    # Check if the first character is Chinese
    first_char = line.strip[0]

    if first_char && chinese_character?(first_char)
      # Merge with the previous line
      result[-1] = result[-1] + line
    else
      # Keep as separate line
      result << line
    end
  end

  result.join("\n")
end

def chinese_character?(char)
  # Check if character is in CJK Unified Ideographs range (U+4E00-U+9FFF)
  # This covers most common Chinese characters
  codepoint = char.ord
  (codepoint >= 0x4E00 && codepoint <= 0x9FFF) ||
  (codepoint >= 0x3400 && codepoint <= 0x4DBF) ||  # CJK Extension A
  (codepoint >= 0xF900 && codepoint <= 0xFAFF)     # CJK Compatibility Ideographs
end

# Example usage:
text1 = <<~TEXT
a <1> 未來時：'a'虛字在一個動詞前是未來的符號 - a maorad ano dafak：明天
會下雨 - a komaen kako：我要吃飯 - tayra kako a misalama：我耍去玩
TEXT

text2 = "'a'ad ＝ 'ad'ad ＝ wadwad：陳列 (為使乾) ＝ 翻亂 (如 小孩子亂翻)"

puts "Example 1 - Before:"
puts text1
puts "\nExample 1 - After:"
puts merge_chinese_lines(text1)

puts "\n" + "="*50

puts "\nExample 2 - Before:"
puts text2
puts "\nExample 2 - After:"
puts merge_chinese_lines(text2)

# Method to process a file
def process_file(input_file, output_file = nil)
  content = File.read(input_file, encoding: 'UTF-8')
  processed_content = merge_chinese_lines(content)

  if output_file
    File.write(output_file, processed_content, encoding: 'UTF-8')
    puts "Processed content written to #{output_file}"
  else
    puts processed_content
  end
end

# Command line usage
if __FILE__ == $0
  if ARGV.empty?
    puts "Usage:"
    puts "  ruby #{File.basename(__FILE__)} input_file [output_file]"
    puts "  cat input_file | ruby #{File.basename(__FILE__)}"
    puts ""
    puts "Examples:"
    puts "  ruby #{File.basename(__FILE__)} input.txt"
    puts "  ruby #{File.basename(__FILE__)} input.txt output.txt"
    puts "  echo 'text' | ruby #{File.basename(__FILE__)}"
    exit 1
  end

  input_file = ARGV[0]
  output_file = ARGV[1]

  if File.exist?(input_file)
    process_file(input_file, output_file)
  else
    # Read from stdin if file doesn't exist (for pipe usage)
    content = STDIN.read
    processed_content = merge_chinese_lines(content)

    if output_file
      File.write(output_file, processed_content, encoding: 'UTF-8')
      puts "Processed content written to #{output_file}"
    else
      puts processed_content
    end
  end
end

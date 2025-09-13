# https://claude.ai/chat/55370c64-32a1-49c4-a182-ea54f46e435b
# sql 輸出的問題，要將有, 的行要拿掉雙引號
def remove_quotes_from_comma_lines(content)
  content.lines.map do |line|
    if line.include?(',')
      line.gsub('"', '')
    else
      line
    end
  end.join
end

# Method to process a file directly
def process_file(input_file, output_file = nil)
  content = File.read(input_file)
  processed_content = remove_quotes_from_comma_lines(content)

  if output_file
    File.write(output_file, processed_content)
    puts "Processed content written to #{output_file}"
  else
    # If no output file specified, overwrite the original
    File.write(input_file, processed_content)
    puts "Original file #{input_file} has been updated"
  end

  processed_content
end

# Alternative method to process content from a string
def process_content_string(content)
  remove_quotes_from_comma_lines(content)
end

# Command line usage
if __FILE__ == $0
  if ARGV.empty?
    # No arguments - run example
    sample_content = <<~CONTENT
      'aca - pa'aca：賣，售.
      'aca - pi'acaan ＝ kalali'acaan 市場，商店，店舖；櫃台
      "acaram ＝ axaham, aharam：桑"
      'acaw - mi'acaw：汲水，搖水
    CONTENT

    puts "No file specified. Running example:"
    puts "Original content:"
    puts sample_content
    puts "\nProcessed content:"
    puts process_content_string(sample_content)
    puts "\nUsage: ruby quote_remover.rb <input_file> [output_file]"
  elsif ARGV.length == 1
    # Process file in-place
    input_file = ARGV[0]
    if File.exist?(input_file)
      process_file(input_file)
    else
      puts "Error: File '#{input_file}' not found."
    end
  elsif ARGV.length == 2
    # Process file and save to new file
    input_file = ARGV[0]
    output_file = ARGV[1]
    if File.exist?(input_file)
      process_file(input_file, output_file)
    else
      puts "Error: File '#{input_file}' not found."
    end
  else
    puts "Usage: ruby quote_remover.rb <input_file> [output_file]"
  end
end

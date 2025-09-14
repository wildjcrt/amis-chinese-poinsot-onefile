#!/usr/bin/env ruby
# 如果該行只有一個 ’，取代為 '

def process_file(input_file, output_file = nil)
  # Use input file with .processed extension if no output file specified
  output_file ||= input_file.gsub(/(\.[^.]+)?$/, '.processed\1')

  begin
    # Read file content and normalize line endings
    content = File.read(input_file, encoding: 'utf-8')
    lines = content.split(/\r\n|\n|\r/)

    File.open(output_file, 'w', encoding: 'utf-8') do |outfile|
      lines.each_with_index do |line, index|
        line_number = index + 1

        # Count single quotes in the line
        quote_count = line.count("’")

        if quote_count == 1
          # Replace single quote with curly quote
          processed_line = line.gsub("’", "'")
          outfile.puts(processed_line)
        else
          # Write line unchanged
          outfile.puts(line)
        end
      end
    end

    puts "Processing complete! Output written to: #{output_file}"

  rescue Errno::ENOENT
    puts "Error: File '#{input_file}' not found."
  rescue => e
    puts "Error processing file: #{e.message}"
  end
end

# Command line usage
if ARGV.length < 1
  puts "Usage: ruby #{$0} <input_file> [output_file]"
  puts "Example: ruby #{$0} myfile.txt"
  puts "Example: ruby #{$0} myfile.txt processed_myfile.txt"
  exit 1
end

input_file = ARGV[0]
output_file = ARGV[1]

process_file(input_file, output_file)
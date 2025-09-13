#!/usr/bin/env ruby
# 將 - 結尾換行還原成一行

def remove_dash_newlines(text)
  # Handle both cases:
  # 1. Word hyphenation: remove dash and newline (ta-\nma' -> tama')
  # 2. Dash separator: keep dash, remove newline (工作 -\nkarteg -> 工作 - karteg)

  result = text.gsub(/(\w)-\n(\w)/) do |match|
    # Case 1: Word hyphenation - letter/digit before dash, letter/digit after newline
    $1 + $2
  end

  result = result.gsub(/(\S)\s*-\s*\n\s*(\S)/) do |match|
    # Case 2: Dash separator - keep the dash with proper spacing
    $1 + ' - ' + $2
  end

  result
end

def process_file(input_file, output_file = nil)
  unless File.exist?(input_file)
    puts "Error: File '#{input_file}' not found!"
    exit 1
  end

  content = File.read(input_file, encoding: 'utf-8')
  processed_content = remove_dash_newlines(content)

  if output_file
    File.write(output_file, processed_content, encoding: 'utf-8')
    puts "Processed content saved to: #{output_file}"
  else
    # Output to stdout if no output file specified
    puts processed_content
  end
end

def process_stdin
  content = STDIN.read
  processed_content = remove_dash_newlines(content)
  puts processed_content
end

# Command line interface
if ARGV.empty?
  puts "Usage:"
  puts "  ruby remove_dash_newline.rb <input_file> [output_file]"
  puts "  cat file.txt | ruby remove_dash_newline.rb"
  puts ""
  puts "Examples:"
  puts "  ruby remove_dash_newline.rb input.txt output.txt"
  puts "  ruby remove_dash_newline.rb input.txt  # outputs to screen"
  puts "  cat input.txt | ruby remove_dash_newline.rb  # pipe input"
  exit 0
elsif ARGV[0] == "-"
  # Read from stdin
  process_stdin
else
  # Read from file
  input_file = ARGV[0]
  output_file = ARGV[1]
  process_file(input_file, output_file)
end

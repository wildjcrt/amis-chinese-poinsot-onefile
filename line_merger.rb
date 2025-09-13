#!/usr/bin/env ruby
# encoding: utf-8

# Simple function to merge lines
def merge_lines(text)
  lines = text.split("\n")
  result = []

  lines.each do |line|
    # Check if line starts with “ (straight quote) or ” (left double quotation mark)
    if (line.start_with?('“') || line.start_with?('”')) && !result.empty?
      # Merge with previous line (remove line break)
      result[-1] += line
    else
      # Keep as separate line
      result << line
    end
  end

  result.join("\n")
end

# Method to process a file with custom output name
def process_file(input_filename, output_filename = nil)
  content = File.read(input_filename, encoding: 'utf-8')
  merged_content = merge_lines(content)

  # Use provided output filename or generate default
  if output_filename
    final_output = output_filename
  else
    final_output = input_filename.gsub(/\.([^.]+)$/, '_merged.\1')
  end

  File.write(final_output, merged_content, encoding: 'utf-8')
  puts "Processed #{input_filename} -> #{final_output}"
end

# Method to process from standard input
def process_stdin
  content = STDIN.read
  merged_content = merge_lines(content)
  puts merged_content
end

# Show help
def show_help
  puts <<~HELP
    Usage:
      ruby line_merger.rb [options] [input_file] [output_file]

    Options:
      --test              Run test with example
      --help, -h          Show this help

    Examples:
      ruby line_merger.rb --test                           # Run test
      ruby line_merger.rb input.txt                        # Output to input_merged.txt
      ruby line_merger.rb input.txt output.txt             # Output to output.txt
      cat input.txt | ruby line_merger.rb                  # Process from pipe
      cat input.txt | ruby line_merger.rb > output.txt     # Pipe to specific file
  HELP
end

# Test with the provided example
def run_test
  test_input = <<~TEXT
caleg：松樹；松柏科；木麻黃 - "Padipog ko tolatolaw i caleg a kilag"(詩；03,17)
"鳥兒在香柏樹(雪松樹)裏築巢
TEXT

  puts "=== TEST ==="
  puts "Input:"
  puts test_input
  puts "\nOutput:"
  puts merge_lines(test_input)
  puts "============"
end

# Main execution
case ARGV.length
when 0
  # No arguments, read from STDIN
  process_stdin
when 1
  arg = ARGV[0]
  case arg
  when '--test'
    run_test
  when '--help', '-h'
    show_help
  else
    # Single file argument
    if File.exist?(arg)
      process_file(arg)
    else
      puts "File not found: #{arg}"
      exit 1
    end
  end
when 2
  # Two arguments: input and output files
  input_file, output_file = ARGV
  if File.exist?(input_file)
    process_file(input_file, output_file)
  else
    puts "File not found: #{input_file}"
    exit 1
  end
else
  puts "Too many arguments. Use --help for usage information."
  exit 1
end
#!/usr/bin/env ruby

# Script to replace colons with spaces in biblical references
# Usage: ruby script.rb filename.txt
# Processes files line by line using File.foreach for memory efficiency

def process_file(filename)
  unless File.exist?(filename)
    puts "Error: File '#{filename}' not found."
    exit 1
  end

  # Pattern to match ONLY biblical references with various parentheses combinations
  # Handles: (), （）, （), (）
  # Looks for: opening paren + any chars + colon + numbers + comma + numbers + closing paren
  # Will NOT match colons in dictionary definitions like 'arini：經常排尿
  pattern = /[(\（][^)\）]*：\d+[,，]\d+[)\）]/

  # Create temporary file for output
  temp_filename = "#{filename}.tmp"
  changes_made = 0

  File.open(temp_filename, 'w', encoding: 'UTF-8') do |output_file|
    File.foreach(filename, encoding: 'UTF-8') do |line|
      # Process each line individually
      modified_line = line.gsub(pattern) do |match|
        changes_made += 1
        puts "Line changed: #{line.strip}" if changes_made <= 5  # Show first 5 changes
        match.gsub('：', ' ')
      end

      output_file.write(modified_line)
    end
  end

  # Replace original file with modified version
  File.rename(temp_filename, filename)

  puts "File '#{filename}' has been updated successfully."
  puts "Total biblical references updated: #{changes_made}"
end

if ARGV.length != 1
  puts "Usage: ruby #{$0} <filename>"
  puts "       ruby #{$0} --preview <filename>  (to preview changes)"
  exit 1
end

filename = ARGV[0]
process_file(filename)
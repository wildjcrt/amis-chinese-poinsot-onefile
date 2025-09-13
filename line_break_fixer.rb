#!/usr/bin/env ruby

# Check if input and output filenames are provided
if ARGV.length != 2
  puts "Usage: ruby script.rb <input_filename> <output_filename>"
  exit 1
end

input_filename = ARGV[0]
output_filename = ARGV[1]

# Check if file exists
unless File.exist?(input_filename)
  puts "Error: File '#{input_filename}' not found"
  exit 1
end

# Read all lines from file
lines = File.readlines(input_filename, chomp: true)

# Function to get first character ignoring apostrophes and case
def get_first_char(line)
  stripped_line = line.strip
  return nil if stripped_line.empty?

  # Skip leading apostrophes to get the actual first character
  i = 0
  while i < stripped_line.length && stripped_line[i] == "'"
    i += 1
  end

  return i < stripped_line.length ? stripped_line[i].downcase : nil
end

# Step 2: Find alphabet sections based on predefined sequence
puts "Finding alphabet sections..."
puts "Expected alphabet order: a, c, d, e, f, g, h, i, k, l, m, n, o, p, r, s, t, w, x, y, z"

# Predefined alphabet sequence
alphabet_sequence = ['a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'w', 'x', 'y', 'z']
char_ranges = {}

# Find section transitions by scanning for each alphabet character in sequence
# current_section_start = nil
# current_section_char = nil
# search_start_index = 0  # Start searching from this index
#
# alphabet_sequence.each do |expected_char|
#   # Find where this section starts (search from where we left off)
#   found = false
#   (search_start_index...lines.length).each do |index|
#     line = lines[index]
#     line_number = index + 1
#     first_char = get_first_char(line)
#
#     if first_char == expected_char
#       # Found start of this section
#       if current_section_char && current_section_start
#         # End previous section
#         char_ranges[current_section_char] = {
#           start: current_section_start,
#           end: line_number - 1
#         }
#       end
#
#       # Start new section
#       current_section_char = expected_char
#       current_section_start = line_number
#       search_start_index = index + 1  # Next search starts after this line
#       found = true
#       break
#     end
#   end
#
#   # If we didn't find this character, stop looking for further ones
#   break unless found
# end
#
# # Don't forget the last section
# if current_section_char && current_section_start
#   char_ranges[current_section_char] = {
#     start: current_section_start,
#     end: lines.length
#   }
# end
#
# # puts "Alphabet sections found:"
# alphabet_sequence.each do |char|
#   if char_ranges[char]
#     range = char_ranges[char]
#     puts "  '#{char}': lines #{range[:start]} to #{range[:end]} (#{range[:end] - range[:start] + 1} lines)"
#   else
#     puts "  '#{char}': not found"
#   end
# end

# Claude 寫的 L43-85 問題太多，乾脆手動寫死
char_ranges = {
  "a" => {:start=>1,     :end=>954},
  "c" => {:start=>955,   :end=>2539},
  "d" => {:start=>2540,  :end=>3135},
  "e" => {:start=>3136,  :end=>3209},
  "f" => {:start=>3210,  :end=>4494},
  "g" => {:start=>4495,  :end=>4830},
  "h" => {:start=>4831,  :end=>5660},
  "i" => {:start=>5661,  :end=>6087},
  "k" => {:start=>6088,  :end=>8314},
  "l" => {:start=>8315,  :end=>10054},
  "m" => {:start=>10055, :end=>11250},
  "n" => {:start=>11251, :end=>11653},
  "o" => {:start=>11654, :end=>11983},
  "p" => {:start=>11984, :end=>13895},
  "r" => {:start=>13896, :end=>14676},
  "s" => {:start=>14677, :end=>16424},
  "t" => {:start=>16425, :end=>18676},
  "w" => {:start=>18677, :end=>18862},
  "x" => {:start=>18863, :end=>18864},
  "y" => {:start=>18865, :end=>18917},
  "z" => {:start=>18918, :end=>18931}
}

# Step 3: Check each line and merge if first char doesn't match expected
puts "Processing lines..."
result_lines = []
merged_count = 0

lines.each_with_index do |line, index|
  line_number = index + 1
  stripped_line = line.strip

  if stripped_line.empty?
    result_lines << line
    next
  end

  # Check if this line is within any alphabet section
  expected_char = nil
  char_ranges.each do |char, range|
    if line_number >= range[:start] && line_number <= range[:end]
      expected_char = char
      break
    end
  end

  # If we're in an alphabet section, check if first char matches
  if expected_char
    first_char = get_first_char(line)

    if first_char && first_char.match?(/[a-z]/)
      # If first char doesn't match expected char, merge with previous line
      if first_char != expected_char && !result_lines.empty?
        result_lines[-1] += " #{stripped_line}"
        merged_count += 1
        next
      end
    else
      # Non-alphabetic lines in alphabet sections should be merged
      if !result_lines.empty?
        result_lines[-1] += " #{stripped_line}"
        merged_count += 1
        next
      end
    end
  end

  result_lines << line
end

# Write result to output file
File.write(output_filename, result_lines.join("\n") + "\n")

puts "Processing complete!"
puts "Input file: #{input_filename}"
puts "Output file: #{output_filename}"
puts "Original lines: #{lines.length}"
puts "Result lines: #{result_lines.length}"
puts "Lines merged: #{merged_count}"
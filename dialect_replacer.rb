#!/usr/bin/env ruby

# Compact version - single line approach
filename = ARGV[0] || (puts "Usage: ruby #{$0} <filename>"; exit)

# Read, replace, and write back to file
File.write(filename, File.read(filename)
  .gsub('(Ch)', '{Ch}')
  .gsub('(S)', '{S}')
  .gsub('(F)', '{F}')
  .gsub('(T)', '{T}')
  .gsub('(J)', '{J}')
  .gsub('(Tw)', '{Tw}')
  .gsub('(N)', '{N}')
  .gsub('(Z)', '{Z}'))

puts "File '#{filename}' modified successfully!"

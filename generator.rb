require 'mustache'
require 'fileutils'

class FileCollsion < StandardError
end

class Generator
  def initialize(source, target)
    @source = source
    @target = target
    unless File.directory?(@target)
        FileUtils.mkdir_p(@target)
    end
  end
    
  def all_html_files()
    Dir["#{@source}/**/*.html"]
  end

  def all_mustache_files()
    Dir["#{@source}/**/*.mustache"]
  end

  def generate()
    file_names = all_html_files
    @files = Hash.new("")
    tempfiles = []
    begin
      file_names.each do |file|
        target_file = file[@source.length, file.length - @source.length]
        target_file = @target + target_file + ".mustache"
        puts "#{file} => #{target_file}"
        dirname = File.dirname(target_file) 
        unless File.directory?(dirname)
          puts "Creating directory '#{dirname}'"
          FileUtils.mkdir_p(dirname)
        end
        FileUtils.cp(file, target_file)
        tempfiles << target_file  
        @files[file] = File.read(file)
      end

      all_mustache_files.each do |file|
        target_file = file[@source.length, file.length - @source.length]
        target_file = @target + target_file
        if tempfiles.include? target_file 
          puts ""
          puts "Can't copy #{file}. Can't have html-file with the same name as a mustache-file! Aborting..."
          puts ""
          raise 'error'
        else
          puts "#{file} => #{target_file}"
          dirname = File.dirname(target_file) 
          unless File.directory?(dirname)
            puts "Creating directory '#{dirname}'"
            FileUtils.mkdir_p(dirname)
          end
          FileUtils.cp(file, target_file)
          tempfiles << target_file  
        end
      end
      
      Dir.chdir(@target) do
        puts "In #{Dir.pwd}"
        @files.each do |name, content|
          output = Mustache.render(content) 
          write_generated(name, output)
        end
      end
    ensure 
      tempfiles.each do |file|
        puts "deleting #{file}"
        File.delete(file)
      end
    end
  end

  def write_generated(file_name, content)
    target_file = file_name[@source.length + 1, file_name.length - @source.length]
    puts "#{file_name} => #{target_file}"
    dirname = File.dirname(target_file) 
    unless File.directory?(dirname)
      puts "Creating directory '#{dirname}'"
      FileUtils.mkdir_p(dirname)
    end
    file = File.new(target_file, "w")
    file.write(content)
  end
end

##usage: sourcedir targetdir
from, to = ARGV
puts "#{from} => #{to}"
puts "This will generate html files from mustache syntax using partials, using all files (recursively) from #{from} to #{to}. Are you sure? [y/n] (n)"
answer = STDIN.gets.chomp
if answer == "y"
  puts "OK!"
  puts ""
  generator = Generator.new(from, to)
  generator.generate
else
  puts "Aborting..."
end

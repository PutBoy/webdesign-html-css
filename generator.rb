require 'mustache'

class Generator
  def initialize(sourceDir, targetDir)
    @source = sourceDir
    @target = targetDir
  end
    
  def AllHtmlFiles()
    Dir["#{@source}/**/*.html"]
  end
  
  def Generate()
    filesNames = AllHtmlFiles
    @files = Hash.new("")
    filesNames.each do |file|
      @files[file] = File.read(file)
    end
    @files.each do |name, content|
      output = Mustache.render(content, @files) 
      WriteGenerated(file, output)
    end
  end

  def WriteGenerated(fileName, content)
    file = File.new("w")
    file.write(content)
  end
end

##usage: sourcedir targetdir
Generator generator = Generator.new(ARGS[0], ARGS[1])
generator.Generate()


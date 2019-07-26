# Testing image conversion
class Branch
  require 'fileutils'
  require 'RMagick'

  include Magick

  def initialize(input_dir, output_dir)
    @input_dir = input_dir
    @output_dir = output_dir
  end

  def branches
    Dir.entries(@input_dir).select { |entry| File.directory? File.join(@input_dir,entry) and !(entry =='.' || entry == '..') }
  end

  def leaves
    Dir["#{@input_dir}/*.tiff"] + Dir["#{@input_dir}/*.tif"]
  end

  def grow
    grow_leaves
    grow_branches
  end

  def climb
    branches.each do |branch|
      new_input = File.join(@input_dir, branch)
      new_output = File.join(@output_dir, branch)
      new_branch = Branch.new(new_input, new_output)
      new_branch.grow
      new_branch.climb
    end
  end

  def grow_branches
    branches.each do |folder|
      new_folder = File.join(@output_dir, folder)
      Dir.mkdir(new_folder) unless File.exist?(new_folder)
    end
  end

  def grow_leaves
    leaves.each do |tiff|
      output_file = tiff.gsub(@input_dir, @output_dir).sub(/\.[^\.]+$/, '.pdf')
      image = Image.read(tiff).first
      image.write(output_file)
    end
  end
end

output_dir = 'data/results'
input_dir = 'data/example'

trunk = Branch.new(input_dir, output_dir)
trunk.grow
trunk.climb

# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
#require './nr_test_unit'
require 'time'
require 'fileutils'

class Nr_test_unit < Test::Unit::TestCase

  def setup
    @base_dir = "/Users/macuser/ruby/newrelic/lib/files/"
    @infile_name  = @base_dir + 'input1'
    @outfile_name = @base_dir + 'output1'

    begin
      @infile  = File.open  @infile_name, 'r+'
      @outfile = File.open @outfile_name, 'r+'
    rescue Exception => e
      puts "Error opening files: #{e}"
    end
  end

  def teardown
    @infile.close
    @outfile.close
  end

  def test_file_size_match

    assert_equal(@infile.size, @outfile.size, "File sizes not equal")
#    if (@infile.size != @outfile.size)
#      puts "\nTest Failed: Infile size does not equal outfile size"
#    end
  end

  def test_file_content_match
    @outfile_data = @outfile.readlines
    @infile_data = @infile.readlines

    for i in 0...@outfile_data.length
      if (@outfile_data[i] != @infile_data[i])
        puts "Test Failed: elements not equal: outfile[#{i}]=#{@outfile_data[i]},
              infile[#{i}]=#{@infile_data[i]}#"
      end
    end

#    for i in 0...@outfile_data.length
      assert_equal(@infile_data, @outfile_data,
        "Data in infile and outfile not equal")

#    end
  end

  def test_file_compare_check
    FileUtils.cmp(@infile, @outfile)
    assert_equal(FileUtils.cmp(@infile, @outfile), false)

#    if (FileUtils.cmp(@outfile, @infile)==false)
#      puts "Test Failed: FileUtils.compare returned false!"
#    end
  end
end

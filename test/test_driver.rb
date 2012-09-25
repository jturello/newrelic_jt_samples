# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'time'
require 'test/unit'
require 'test/unit/assertions'
require 'FileUtils'


class TestDriver < Test::Unit::TestCase

  attr_reader :outfile, :infile

  def initialize
    @debug_on = false
    @time_out = 10
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

  def watch
    @iter_start = Time.now
    while @outfile.size == 0 do
      puts 'wait for data in outfile'
      if (Time.now - @iter_start > @time_out)
        puts "Processing timed out after #{'%.1f' % (Time.now - @iter_start)} seconds of inactivity."
        exit
      end
    end

    @test_run = 1
    set_vars

    @files_changed = false
    while true do

      if ((@test_run == 1) || (@test_run > 1) && (@files_changed == true))
        run_tests(@test_run)
        @test_run += 1
      end
      
      sleep 5

      set_vars
      @files_changed = files_changed?
      @iter_start = Time.now if @files_changed

      if ((Time.now - @iter_start) > @time_out) && (@files_changed == false)
        puts "Processing timed out after #{'%.1f' % (Time.now - @iter_start)} seconds of inactivity."
        exit
      end
      
    end # end of 'more' loop
  end # end of watch method


  def run_tests(test_run)
    puts "\ntestrun: #{test_run}"
    puts "Test run start: #{Time.now}"
    puts "last modtime- infile/outfile: #{@infile.mtime}/#{@outfile.mtime}"
    puts "File size - infile/outfile: #{@infile_size}/#{@outfile_size}"
    puts "\nin_data- length: #{@infile_data.length}"
    puts "out_data- length: #{@outfile_data.length}\n"

    file_size_match
    file_content_match
    file_compare_check
  end

  def file_size_match
    if (@infile.size != @outfile.size)
      puts "\nTest Failed: Infile size does not equal outfile size"
    end
  end

  def file_content_match

    for i in 0...@outfile_data.length
      if (@outfile_data[i] != @infile_data[i])
        puts "Test Failed: elements not equal: outfile[#{i}]=#{@outfile_data[i]},
              infile[#{i}]=#{@infile_data[i]}"
      end
    end
  end

  def file_compare_check
    if (FileUtils.cmp(@outfile, @infile)==false)
      puts "Test Failed: FileUtils.compare returned false!"
    end
  end

  private
  def set_vars

    if @test_run > 1
      # set previous values to @prev_ vars to compare with current state
      @prev_outfile_size = @outfile_size
      @prev_outfile_data = @outfile_data.dup
      @prev_outfile_modtime = @outfile_modtime
      @prev_outfile_line_count = @outfile_line_count

      @prev_infile_size = @infile_size
      @prev_infile_data = @infile_data.dup
      @prev_infile_modtime = @infile_modtime
      @prev_infile_line_count = @infile_line_count
    end

    # set vars based on current state of files (i.e., pick up mods)
    @outfile_size = @outfile.size
    @outfile_data = @outfile.readlines
    @outfile_modtime = @outfile.mtime
    @outfile_line_count = @outfile_data.length

    @infile_size = @infile.size
    @infile_data = @infile.readlines
    @infile_modtime = @infile.mtime
    @infile_line_count = @infile_data.length

    # reset file pointers after call to readlines
    @outfile.rewind if @outfile.pos > 0
    @infile.rewind if @infile.pos > 0

  end

  def files_changed?

    @infile_changed = @outfile_changed = true
    # check if outfile was modified
    if (
       (@outfile_size == @prev_outfile_size) &&
       (@outfile_line_count == @prev_outfile_line_count) &&
       ((@outfile_data <=> @prev_outfile_data) == 0)
       (@outfile_modtime == @prev_outfile_modtime)
       )
        then @outfile_changed = false
    end

    # check if infile was modified
    if (
       (@infile_size == @prev_infile_size) &&
       (@infile_line_count == @prev_infile_line_count) &&
       ((@infile_data <=> @prev_infile_data) == 0)
       (@infile_modtime == @prev_infile_modtime)
       )
        then @infile_changed = false
    end

    if @debug_on
      puts "out_size - prev/curr: #{@prev_outfile_size}/#{@outfile_size}"
      puts "out_line_count - prev/curr: #{@prev_outfile_line_count}/#{@outfile_line_count}"
      puts "out_mtime - prev/curr: #{@prev_outfile_modtime}/#{@outfile_modtime}"

      puts "in_size - prev/curr: #{@prev_infile_size}/#{@infile_size}"
      puts "in_line_count - prev/curr: #{@prev_infile_line_count}/#{@infile_line_count}"
      puts "in_mtime - prev/curr: #{@prev_infile_modtime}/#{@infile_modtime}"      
    end


    if (@infile_changed == false && @outfile_changed == false)
      return false
    else
      return true
    end
  end


end


td = TestDriver.new
td.watch
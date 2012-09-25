# To change this template, choose Tools | Templates
# and open the template in the editor.
#require '../../test/test_driver'

class SingleDriver

  attr_reader :outfile1, :in_path, :out_path

  def initialize
    @base_dir = "/Users/macuser/ruby/newrelic/lib/"
    @in_path  = @base_dir + '/files/input1'
    @out_path = @base_dir + '/files/output1'

    @fast = false
    
    if File.exists? @out_path
       @outfile1 = File.open @out_path, 'w+'
       File.truncate(@outfile1) unless @outfile1.size == 0
    else
      @outfile1 = File.new @out_path, 'w+'
    end

    if File.exists? @in_path
      @infile1 = File.open @in_path, 'r+'
    else
      raise "infile (#{@in_path} not found."
    end

  rescue Exception => e
    puts "Error thrown instantiating Driver: #{e}."
  end

  def start

    line_num = 1
    while @infile1.size > @outfile1.size do
      line = @infile1.gets

      @outfile1.puts "#{line}" unless line_num == 3 || line_num == 4
      puts "#{line_num}: #{line}" unless line_num == 3 || line_num == 4
      @outfile1.puts "#{line_num} sd: #{line}" if line_num == 4
      puts "#{line_num}: #{line_num}: #{line}" if line_num == 4
      line_num += 1
      sleep 1 unless @fast
    end
  end
end

d = SingleDriver.new
d.start

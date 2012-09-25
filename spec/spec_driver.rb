# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'single_driver'

describe SingleDriver do
  before(:each) do
    @single_driver = SingleDriver.new
  end

  it "should desc" do
    # TODO
  end
end


def watch_for(file, pattern)
  f = File.open(file,"r")
  f.seek(0,IO::SEEK_END)
  while true do
    select([f])
    line = f.gets
    puts "Found it! #{line}" if line=~pattern
  end
end

watch_for("g.txt",/line/)


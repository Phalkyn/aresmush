$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "aresmush"

module AresMUSH

  describe Formatter do
    before do
      @config_reader = mock
      Formatter.config_reader = @config_reader
      @config_reader.stub(:line) { "" }
    end
    
    describe :format_client_output do
      it "should add an ANSI reset and linebreak to the end" do
        msg = Formatter.format_client_output("msg")
        msg.should eq "msg" + ANSI.reset + "\n"
      end

      it "should not add another \n if there's already one on the end" do
        msg = Formatter.format_client_output("msg\n")
        msg.should eq "msg" + ANSI.reset + "\n"
      end

      it "should expand ansi codes" do
        msg = Formatter.format_client_output("my %xcansi%xn message\n")
        msg.should eq "my " + ANSI.cyan + "ansi" + ANSI.reset + " message" + ANSI.reset + "\n"
      end

      it "should replace an escaped %" do
        msg = Formatter.format_client_output("A\\%c")
        msg.should eq "A%c"+ ANSI.reset + "\n"
      end
    end
        
    describe :parse_pose do

      it "should parse a say for a string starting with a quote" do
        Locale.stub(:translate).with("object.say", :name => "Bob", :msg => "Hello.") { "hi" }
        Formatter.parse_pose("Bob", "\"Hello.").should eq "hi"
      end

      it "should parse a pose for a string starting with a colon" do
        Locale.stub(:translate).with("object.pose", :name => "Bob", :msg => "waves.") { "waves" }
        Formatter.parse_pose("Bob", ":waves.").should eq "waves"
      end

      it "should parse a semipose for a string starting with a semicolon" do
        Locale.stub(:translate).with("object.semipose", :name => "Bob", :msg => "'s cat.") { "cat" }
        Formatter.parse_pose("Bob", ";'s cat.").should eq "cat"
      end

      it "should parse an emit for a string starting with a backslash" do
        Formatter.parse_pose("Bob", "\\Whee").should eq "Whee"
      end

      it "should parse an emit for an unadorned string" do
        Formatter.parse_pose("Bob", "Whee").should eq "Whee"
      end

    end
    
    
    describe :perform_subs do
      before do
        @enactor = { "name" => "Bob" }
      end

      it "should replace %r and %R with linebreaks" do
        Formatter.perform_subs("Test%rline%Rline2").should eq "Test\nline\nline2"
      end

      it "should replace %t and %T with 5 spaces" do
        Formatter.perform_subs("Test%tTest2%TTest3").should eq "Test     Test2     Test3"
      end

      it "should replace %~ with the unicode marker" do
        Formatter.perform_subs("Test%~Test").should eq "Test\u2682Test"
      end  
      
      it "should replace %l1 with line1" do
        @config_reader.stub(:line).with("1") { "---" }
        Formatter.perform_subs("Test%l1Test").should eq "Test---Test"
      end    

      it "should replace %l2 with line2" do
        @config_reader.stub(:line).with("2") { "---" }
        Formatter.perform_subs("Test%l2Test").should eq "Test---Test"
      end    

      it "should replace %l3 with line3" do
        @config_reader.stub(:line).with("3") { "---" }
        Formatter.perform_subs("Test%l3Test").should eq "Test---Test"
      end    

      it "should replace %l4 with line4" do
        @config_reader.stub(:line).with("4") { "---" }
        Formatter.perform_subs("Test%l4Test").should eq "Test---Test"
      end    
      
      it "should replace %x! with a random color" do
        AresMUSH::Formatter.should_receive(:random_color) { "b" }
        Formatter.perform_subs("A%x!B").should eq "A%xbB"
      end

    end
    
    describe :random_color do
      it "should pick the first color for the first bracket of time" do
        Time.stub(:now) { Time.new(2007,11,1,15,25,10) }
        Formatter.random_color.should eq "c"
      end
      
      it "should pick the second color for the second bracket of time" do
        Time.stub(:now) { Time.new(2007,11,1,15,25,20) }
        Formatter.random_color.should eq "b"
      end
      
      it "should pick the third color for the second bracket of time" do
        Time.stub(:now) { Time.new(2007,11,1,15,25,40) }
        Formatter.random_color.should eq "g"
      end
      
      it "should pick the last color for the fourth bracket of time" do
        Time.stub(:now) { Time.new(2007,11,1,15,25,55) }
        Formatter.random_color.should eq "r"
      end      
    end
    
    describe :to_ansi do
      it "should replace ansi codes" do
        Formatter.to_ansi("A%xrB%XnC").should eq "A" + ANSI.red + "B" + ANSI.reset + "C" 
      end
      
      it "should replace ansi c as well as x" do
        Formatter.to_ansi("A%crB%CnC").should eq "A" + ANSI.red + "B" + ANSI.reset + "C" 
      end
      
      it "should replace nested codes" do
        Formatter.to_ansi("A%xc%xGB%xnC").should eq "A" + ANSI.cyan + ANSI.on_green + "B" + ANSI.reset + "C" 
      end

      it "should not replace a code preceeded by a backslash" do
        Formatter.to_ansi("A\\%xcB").should eq "A\\%xcB" 
      end
    end
  end
end
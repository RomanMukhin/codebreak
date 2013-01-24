module Codebreak

  describe Game do
    let(:output) { double('output').as_null_object }
    let(:game)   { Game.new(output) }
    before(:each) do
      game.stub!(:save_result)
      game.stub(:gets).and_return("no")
      game.stub(:guess).and_return("++++")
      game.stub!(:generate)
      output.stub!(:puts)
    end

    describe "#start" do
      before(:each) do
        game.unstub!(:generate)
      end
      
      it "sends a welcome message" do
        output.should_receive(:puts).with('Welcome to Codebreaker!')
        game.start
      end
 
      it "prompts for the first guess" do
        output.should_receive(:puts).with('Enter your guess:')
        game.start
      end

      it "generates random 4 digit number within 1..6 range in string" do
        game.start
        code = game.instance_variable_get(:@code)
        code.split("").should have(4).items
        code.length.times do |i|
          (1..6).should include(code[i].to_i)
        end
      end
    end

    describe "#guess" do
      before(:each) do 
        game.unstub(:guess)
        game.instance_variable_set(:@code, '3463')
      end 
   
      it "returns '++++' if playes guesses the whole code" do
        game.stub!(:gets).and_return("3463") 
        output.should_receive(:puts).with('++++')
        game.start
      end

      it "returns '----' if all numbers are present but in wrong positions" do
        game.stub!(:gets).and_return("4346") 
        output.should_receive(:puts).with('----')
        game.start
      end

      it "returns '' if player guesses nothing" do
        game.stub!(:gets).and_return("5555") 
        output.should_receive(:puts).with('')
        game.start
      end

      it "returns '+-' if player guesses 2 symbols and position for 1 of them" do
        game.stub!(:gets).and_return("6113") 
        output.should_receive(:puts).with('+-')
        game.start
      end
    end

    
    describe "making attemts to guess" do
      it "congratulates a winner" do
        output.should_receive(:puts).with("Congratulations, You are winner!")
        game.stub(:guess).and_return("++++")
        game.start
      end

      it "informs about the lose" do
        output.should_receive(:puts).with("This code is unbreakable for you")
        game.stub(:guess).and_return("")
        game.start
      end
      it "says that you have a last turn on 5th turn" do 
        output.should_receive(:puts).with("This is your last chance to break it!")
        game.stub(:guess).and_return("----")
        game.start 
      end
      it "says 'You didn't get it with 5 turns'" do
        output.should_receive(:puts).with("You didn't get it with 5 turns")
        game.stub(:guess).and_return("----")
        game.start 
        number_of_turns = game.instance_variable_get(:@number_of_turns)
        number_of_turns.should == 5
      end
    end

    describe "playing again" do      
      it "asks player 'Do you want to repeat the game?' after the game" do
        output.should_receive(:puts).with("Do you want to repeat the game?")
        game.start
      end

      it "begins new game session if 'Yes'" do
        game.should_receive(:generate).twice
        game.stub!(:gets).and_return("", "yes", "no")
        game.start
      end
      
      it "ends the game  if 'No'" do 
        game.should_receive(:generate).once
        game.stub!(:gets).and_return("no")
        game.start 
      end
      
    end
 
    describe "#hint" do
      before(:each) do
        game.instance_variable_set(:@code, '3433')
        game.stub!(:gets).and_return("hint")
      end

      it "prompts player to enter the position of number, if player enteres 'hint'" do
        output.should_receive(:puts).with("Put the position of a number, you wanna know").once
        game.start
      end

      it "gives the number in asked position" do
        output.should_receive(:puts).with("**3*")
        game.stub!(:gets).and_return("hint","3")
        game.start
      end

      it "informs if the position is wrong" do
        output.should_receive(:puts).with("It is wrong position, u stay without a hint").once
        game.start
      end
    end
    
    describe "#save_result" do
      let(:path){"#{game.instance_variable_get(:@dir)}/Nickname_stats.txt" }

      before(:each) do
        game.stub!(:gets).and_return("", "yes", "Nickname" )
        game.unstub(:save_result)
      end
      
      it "prompts after win or lose to save, with asking for player's nickname" do
        output.should_receive(:puts).with("Do you wanna save?")
        output.should_receive(:puts).with("What is your nickname?")
        game.start
      end

      it "saves number of turns and hints used in file with player's name" do
        game.start
        File.open("#{path}", "r") do |file|
           @text = file.read
           file.close
        end     
        @text.should match( /Turns: 1\sHints: 0/)
        File.delete("#{path}")
      end    
    end
  end
end
  

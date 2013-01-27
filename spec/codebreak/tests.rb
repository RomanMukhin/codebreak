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
      
      it "sends a welcome message, and prompts for guess" do
        output.should_receive(:puts).with('Welcome to Codebreaker!').ordered
        output.should_receive(:puts).with('Enter your guess:').ordered
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
      let(:guesses){['3463', '4346', '4345', '4322', '1141', '1463', '1461', '1165', '3436','3432', '5435','6431', '3543','1251']}
      let(:answers){['++++', '----',  '---',   '--',    '-',  '+++',   '++',    '+', '++--', '++-',   '+-', '+--',  '++-',    '']}

      it "returns right answer for player's guess due to game rules" do
        guesses.size.times do |i|
          game.stub!(:gets).and_return(guesses[i])
          output.should_receive(:puts).with(answers[i])
          game.start
        end
      end
    end
    
    describe "making attemts to guess" do
      before(:each) do
        game.stub(:guess).and_return("----")
      end

      it "congratulates a winner" do
        output.should_receive(:puts).with("Congratulations, You are winner!")
        game.stub(:guess).and_return("++++")
        game.start
      end

      it "informs about that u nothing guessed" do
        output.should_receive(:puts).with("Noting guessed")
        game.stub(:guess).and_return("")
        game.start
      end

      it "makes steps" do
        5.times do |i|
          guesses = (Array.new(i, "'----'") << "'++++'").join(', ')
          eval "game.stub(:guess).send(:and_return , #{guesses})"
          game.should_receive(:guess).exactly(i + 1).times
          game.start
        end
      end

      it "counts steps" do
        5.times do |i|
          guesses = (Array.new(i, "'----'") << "'++++'").join(', ')
          eval "game.stub(:guess).send(:and_return , #{guesses})"
          expect{ game.start }.to change{ game.instance_variable_get(:@number_of_turns) }.to(i + 1)
        end
      end

      it "will show 1st turn if you enter 6 times not right guesses" do
          answer_stub = Array.new(5, "''").join(", ")
          eval "game.stub(:gets).and_return(#{answer_stub}, 'yes', 'no')"
          guesses = (Array.new(5, "'----'") << "'++++'").join(', ')
          eval "game.stub(:guess).send(:and_return , #{guesses})" 
          game.start 
          game.instance_variable_get(:@number_of_turns).should == 1
      end

      it "says that you have a last turn on 5th turn" do 
        game.should_receive(:guess).exactly(4).times.ordered
        output.should_receive(:puts).with("This is your last chance to break it!").ordered
        game.should_receive(:guess).exactly(1).times.ordered
        game.start
      end

      it "says 'You didn't get it with 5 turns' after 5 wrong guesses" do
        game.should_receive(:guess).exactly(5).times.ordered
        output.should_receive(:puts).with("You didn't get it with 5 turns").ordered
        game.start 
        number_of_turns = game.instance_variable_get(:@number_of_turns)
        number_of_turns.should == 5
      end
    end

    describe "playing again" do      
      it "asks player 'Do you want to repeat the game?' after the game" do
        game.should_receive(:guess).once.ordered
        output.should_receive(:puts).with("Do you want to repeat the game?")
        game.start
        game.stub(:guess).and_return('----')
        game.should_receive(:guess).exactly(5).times.ordered
        output.should_receive(:puts).with("Do you want to repeat the game?").ordered
        game.start
      end

      it "begins new game session if 'Yes'" do
        game.should_receive(:generate).twice
        game.should_receive(:guess).twice
        game.stub!(:gets).and_return("", "yes", "no")
        game.start
      end
      
      it "ends the game  if 'No'" do 
        game.should_receive(:generate).once.ordered
        game.should_receive(:guess).once.ordered
        game.stub!(:gets).and_return("no")
        game.start 
      end
    end
 
    describe "#hint" do
      before(:each) do
        game.instance_variable_set(:@code, '3435')
      end

      it "prompts player to enter the position of number, if player enteres 'hint'" do
        game.stub!(:gets).and_return( "hint" )
        output.should_receive( :puts ).with("Put the position of a number, you wanna know").once
        game.start
      end

      let(:hints){ ['3***', '*4**', '**3*', '***5'] }

      it "gives the number in asked position" do
        (1..4).each do |n|
          output.should_receive(:puts).with( hints[n - 1])
          game.stub!(:gets).and_return( "hint", "#{n}" )
          game.start
        end
      end

      it "informs if the position is wrong" do
        game.stub!(:gets).and_return( "hint", "24" )
        output.should_receive(:puts).with("It is wrong position, u stay without a hint").once
        game.start
      end
    end
    
    describe "#save_result" do
      let(:nickname){ ['Vitya','123','name'] }
      let(:path)     { "#{game.instance_variable_get(:@dir)}/" }

      before(:each) do
        game.stub!(:gets).and_return( "", "yes", "no" )
        game.unstub(:save_result)
      end
      
      it "prompts after win or lose to save, with asking for player's nickname with calling '#save_result'" do
        game.should_receive(:guess).once.ordered
        output.should_receive(:puts).with( "Do you wanna save?"     ).ordered
        output.should_receive(:puts).with( "What is your nickname?" ).ordered
        File.should_receive(:open).ordered
        game.start
      end

      it "saves number of turns and hints used in file with player's name" do
        3.times do |i|
          game.stub!(:gets).and_return("", "yes", nickname[i] )
          game.start
          file_name = "#{path}#{nickname[i]}_stats.txt"
          File.open(file_name, "r") do |file|
             @text = file.read
             file.close
          end     
          @text.should match( /Turns: 1\sHints: 0/ )
          File.delete( file_name )
        end
      end    
    end
  end
end

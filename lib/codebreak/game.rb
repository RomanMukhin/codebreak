module Codebreak
  class Game
    def initialize(output)
      @output = output
      @dir = File.dirname(__FILE__)    
    end
 
    def start
      @output.puts 'Welcome to Codebreaker!'
      begin
        generate
        @number_of_turns, @number_of_hints = 0, 0
        5.times do |i|
          @number_of_turns = i + 1
          @output.puts "Enter your guess:"
          @guess_string = gets
        
          if @guess_string =~ /hint/
            @output.puts ask_for_hint
            @output.puts "Enter your guess:"
            @guess_string = gets
          end
          
          @output.puts answer = guess
          if answer == '++++' 
            @output.puts "Congratulations, You are winner!" 
            break
          elsif answer == ''
            @output.puts "Noting guessed"
          elsif @number_of_turns == 4
            @output.puts "This is your last chance to break it!"
          elsif @number_of_turns == 5
            @output.puts "You didn't get it with 5 turns"
          end
        end 
     
        save_result
        @output.puts "Do you want to repeat the game?"
        @repeat = gets.downcase
      end while @repeat =~ /yes/
    end
    
    private
    def generate
      @code = ""
      4.times do 
        @code += (rand(6) + 1).to_s
      end
      @code
    end

    def guess 
      answer = ''
      @guess_string.length.times do |i|
        str = @guess_string[i]
        if str == @code[i]
          answer.prepend '+'
        elsif @code.include?(str)
          answer += '-'
        end
      end
      answer
    end
   
    def save_result
      @output.puts "Do you wanna save?"
      if gets.downcase =~ /yes/
        @output.puts "What is your nickname?"
        nickname = gets.chomp
        File.open("#{@dir}/#{nickname}_stats.txt",'a') do |file|
          file << "#{Time.now}\n"
          file << "Turns: #{@number_of_turns}\n"
          file << "Hints: #{@number_of_hints}\n"
        end
      end
    end

    def ask_for_hint
      @output.puts "Put the position of a number, you wanna know"
      hint = gets
      hint_answer = ''
      if (1..4).include?(hint.to_i)
        @number_of_hints += 1
        4.times do |i|
          hint_answer.concat( i == (hint.to_i - 1) ? @code[i] : '*')
        end
      else 
        hint_answer = "It is wrong position, u stay without a hint"
      end
      hint_answer
    end
  end
end



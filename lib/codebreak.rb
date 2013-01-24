require File.dirname(__FILE__) + '/codebreak/game.rb'

module Codebreak
  class Chatter
    def start_game
      Game.new($stdout).start
    end
  end
end
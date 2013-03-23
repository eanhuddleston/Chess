require "./player.rb"
require "./board.rb"
require "./pieces.rb"
require 'debugger'

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def play
    game_over = false
    player1 = Player.new(@board, :W)
    player2 = Player.new(@board, :B)
    @board.print_board

    until game_over
      puts "White's turn"
      while true
        player1.make_move
        if @board.check_mate?(:B)
          @board.print_board
          print_message("Checkmate!")
          return nil
        elsif @board.in_check?(:W)
          print_message("Check: move not allowed!")
          player1.revert_move
          next
        elsif @board.in_check?(:B)
          print_message("Check!")
          break
        else
          break
        end
      end
      @board.print_board
      puts "Black's turn"
      while true
        player2.make_move
        if @board.check_mate?(:W)
          @board.print_board
          print_message("Checkmate!")
          return nil
        elsif @board.in_check?(:B)
          print_message("Check: move not allowed!")
          player2.revert_move
          next
        elsif @board.in_check?(:W)
          print_message("Check!")
          puts "Check!"
          break
        else
          break
        end
      end
      @board.print_board
    end

    print_message("Game over")
  end

  def print_message(message)
  puts ""
  puts message
  puts ""
  end
end

Game.new.play
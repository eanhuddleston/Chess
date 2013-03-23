#encoding: utf-8

class Board
  attr_accessor :board

  def initialize
    @board = [ [],[],[],[],[],[],[],[] ]
    create_initial_board_state
    @start_object = nil
    @start_coord = []
    @end_object = nil
    @end_coord = []
  end

  def check_mate?(color)
    king = nil
    poss_king_moves = []
    same_col_objects = []

    @board.flatten.each do |square|
      if square == "__"
        #don't do anything
      else #has object
        if square.type == :K and square.color == color
          king = square
        else
          if square.color == color
            same_col_objects << square
          end
        end
      end
    end

    all_king_moves_result_in_check = true

    king.find_valid_moves.each do |coord|
      poss_king_moves << coord
    end

    if !in_check?(color)
      all_king_moves_result_in_check = false
    end

    #TODO: refactor the below two blocks into helper method
    poss_king_moves.each do |end_coord|
      @start_object = king
      @start_coord = king.position.dup
      @end_object = @board[ end_coord[0] ] [ end_coord[1] ] #was dup

      king.make_move([ end_coord[0], end_coord[1] ])
      if !in_check?(color)
        all_king_moves_result_in_check = false
      end
      revert_move
    end

    all_buddy_moves_result_in_check = true

    #check if any moves from same color pieces eliminate checkmate
    same_col_objects.each do |piece|
      piece.find_valid_moves.each do |end_coord|
        @start_object = piece
        @start_coord = piece.position.dup
        @end_object = @board[ end_coord[0] ] [ end_coord[1] ] #was dup
        @end_coord = end_coord.dup

        piece.make_move([ end_coord[0], end_coord[1] ])
        if !in_check?(color)
          all_buddy_moves_result_in_check = false
        end
        revert_move
      end
    end

    all_king_moves_result_in_check and all_buddy_moves_result_in_check
  end

  def revert_move
    @start_object.position = @start_coord
    @board[ @start_coord[0] ] [ @start_coord[1] ] = @start_object
    @board[ @end_coord[0] ] [ @end_coord[1] ] = @end_object
  end

  def in_check?(color)
    king = nil
    opp_col_objects = []
    @board.flatten.each do |square|
      if square == "__"
        #don't do anything
      else #has object
        if (square.type == :K) and (square.color == color)
          king = square
        end
        if square.color != color
          opp_col_objects << square
        end
      end
    end

    possible_moves = []
    opp_col_objects.each do |piece|
      piece.find_valid_moves.each do |coord|
        possible_moves << coord
      end
    end

    if possible_moves.include?(king.position)
      return true
    else
      return false
    end
  end

  def create_initial_board_state
    #populate underscores for blank board spaces
    (0..7).each do |row|
      (0..7).each do |pos|
        @board[row][pos] = "__"
      end
    end

    #populate black pawns
    black_pawns_start_coords = [ [1,0], [1,1], [1,2],
                      [1,3], [1,4], [1,5], [1,6],
                      [1,7] ]
    black_pawns_start_coords.each do |coord|
      piece = Pawn.new(:B, coord, self, :P)
      @board[coord[0]][coord[1]] = piece
    end

    #populate white pawns
    white_pawns_start_coords = [ [6,0], [6,1], [6,2],
                      [6,3], [6,4], [6,5], [6,6],
                      [6,7] ]
    white_pawns_start_coords.each do |coord|
      piece = Pawn.new(:W, coord, self, :P)
      @board[coord[0]][coord[1]] = piece
    end

    #populate queens
    @board[0][4] = Queen.new(:B, [0,4], self, :Q)
    @board[7][4] = Queen.new(:W, [7,4], self, :Q)

    #populate bishops
    @board[0][2] = Bishop.new(:B, [0,2], self, :B)
    @board[0][5] = Bishop.new(:B, [0,5], self, :B)
    @board[7][2] = Bishop.new(:W, [7,2], self, :B)
    @board[7][5] = Bishop.new(:W, [7,5], self, :B)

    #populate rooks
    @board[0][0] = Rook.new(:B, [0,0], self, :R)
    @board[0][7] = Rook.new(:B, [0,7], self, :R)
    @board[7][0] = Rook.new(:W, [7,0], self, :R)
    @board[7][7] = Rook.new(:W, [7,7], self, :R)

    #populate knights
    @board[0][1] = Knight.new(:B, [0,1], self, :N)
    @board[0][6] = Knight.new(:B, [0,6], self, :N)
    @board[7][1] = Knight.new(:W, [7,1], self, :N)
    @board[7][6] = Knight.new(:W, [7,6], self, :N)

    #populate kings
    @board[0][3] = King.new(:B, [0,3], self, :K)
    @board[7][3] = King.new(:W, [7,3], self, :K)
  end

  def print_board
    white = {}
    white[:K] = "♔"
    white[:Q] = "♕"
    white[:R] = "♖"
    white[:B] = "♗"
    white[:N] = "♘"
    white[:P] = "♙"

    black = {}
    black[:K] = "♚"
    black[:Q] = "♛"
    black[:R] = "♜"
    black[:B] = "♝"
    black[:N] = "♞"
    black[:P] = "♟"

    puts "    0   1   2   3   4   5   6   7"
    puts ""
    @board.each_with_index do |row, i|
      output_row = row.map do |piece|
        if piece == "__"
          "___"
        else
          if piece.color == :W
            " #{white[piece.type]} "
          else
            " #{black[piece.type]} "
          end
        end
      end
      puts "#{i}  #{output_row.join(" ")}"
      puts "" #empty line
    end
    nil
  end
end
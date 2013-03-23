class Piece
  attr_reader :color, :type, :board
  attr_accessor :position

  def initialize(color, position, board, type)
    @color = color
    @position = position
    @board = board
    @type = type
  end

  def valid_move?(coord)
    valid_trans = valid_transformation?(coord)
    dest_has_object = dest_has_object?(coord)
    if dest_has_object
      dest_same_color = dest_same_color?(coord)
    end

    if valid_trans
      if dest_has_object && dest_same_color
        return false
      else
        return true
      end
    else
      return false
    end
  end

  def dest_has_object?(coord)
    dest_piece = @board.board[coord[0]][coord[1]]
    dest_piece == '__' ? false : true
  end

  #redundant from valid_move?
  def dest_same_color?(coord)
    dest_piece = @board.board[coord[0]][coord[1]]
    dest_piece.color == @color ? true : false
  end

  def make_move(coord)
    @board.board[coord[0]][coord[1]] = self
    @board.board[@position[0]][@position[1]] = "__"
    @position = coord
  end

  def within_bounds?(current_pos)
    if (current_pos[0] < 0) or (current_pos[0] > 7) or
        (current_pos[1] < 0) or (current_pos[1] > 7)
      return false
    else
      return true
    end
  end
end

class SlidingPiece < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves
    valid_moves.include?(coord) ? true : false
  end

  def find_valid_moves
    valid_moves = []
    @valid_trans.each do |trans|
      current_pos = @position.dup

      while true
        current_pos[0] += trans[0]
        current_pos[1] += trans[1]

        break unless within_bounds?(current_pos)

        path_contents = @board.board[current_pos[0]][current_pos[1]]
        if path_contents == "__"
          valid_moves << current_pos.dup
          next
        else #there's an object
          if dest_same_color?(current_pos)
            #don't add to valid_moves
          else
            valid_moves << current_pos.dup
          end
          break
        end
      end
    end

    valid_moves
  end
end

class SteppingPiece < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves
    valid_moves.include?(coord) ? true : false
  end

  def find_valid_moves
    valid_moves = []
    @valid_trans.each do |trans|
      current_pos = @position.dup

      current_pos[0] += trans[0]
      current_pos[1] += trans[1]
      next unless within_bounds?(current_pos)

      path_contents = @board.board[current_pos[0]][current_pos[1]]
      if path_contents == "__"
        valid_moves << current_pos.dup
      else #there's an object
        if dest_same_color?(current_pos)
          #don't add to valid_moves
        else
          valid_moves << current_pos.dup
        end
        next
      end
    end

    valid_moves
  end
end

class King < SteppingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, -1], [-1, 0], [-1, 1],
                   [0, 1], [1, 1], [1, 0], [1, -1]]
  end
end

class Knight < SteppingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [-1, -2], [-2, -1], [-2, 1], [-1, 2],
                   [1, 2], [2, 1], [2, -1], [1, -2]]
  end
end

class Queen < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, -1], [-1, 0], [-1, 1],
                   [0, 1], [1, 1], [1, 0], [1, -1]]
  end
end

class Rook < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, 0], [0, 1], [1, 0] ]
  end
end


class Bishop < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [-1, -1], [-1, 1], [1, 1], [1, -1] ]
  end
end

class Pawn < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves
    valid_moves.include?(coord) ? true : false
  end

  def object_of_same_color?(coord)
    piece = @board.board[coord[0]][coord[1]]
    if piece == "__"
      return false
    else #there's a piece there
      if piece.color == @color
        return true
      else
        return false
      end
    end
  end

  def object_present?(coord)
    piece = @board.board[coord[0]][coord[1]]
    if piece == "__"
      return false
    else
      return true
    end
  end

  def find_valid_moves
    all_valid_moves = []
    valid_vert_trans = []
    valid_diag_trans = []
    if @color == :W
      valid_vert_trans = [ [-1, 0] ]
      valid_diag_trans = [[-1, -1], [-1, 1]]
    else #player color = :B
      valid_vert_trans = [ [ 1, 0] ]
      valid_diag_trans = [[1, -1], [1, 1]]
    end

    valid_vert_trans.each do |trans|
      new_coord = [ @position[0] + trans[0], @position[1] + trans[1] ]
      if within_bounds?(new_coord) && !object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    valid_diag_trans.each do |trans|
      new_coord = [ @position[0] + trans[0], @position[1] + trans[1] ]
      if within_bounds?(new_coord) && !object_of_same_color?(new_coord) &&
              object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    all_valid_moves
  end
end
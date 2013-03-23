class Player
  attr_accessor :color

  def initialize(board, color)
    @board = board
    @color = color
    @start_object = nil
    @start_coord = []
    @end_object = nil
    @end_coord = []
  end

  def revert_move
    @start_object.position = @start_coord
    @board.board[ @start_coord[0] ] [ @start_coord[1] ] = @start_object
    @board.board[ @end_coord[0] ] [ @end_coord[1] ] = @end_object
  end

  def make_move
    while true
      start_coord, end_coord = collect_input
      if @board.board[ start_coord[0] ] [ start_coord[1] ] == '__'
        puts "Please select a non-empty coordinate"
        next
      end

      piece = @board.board[ start_coord[0] ] [ start_coord[1] ]

      if piece.color != @color
        puts "Please select a piece of the correct color"
        next
      elsif !piece.valid_move?(end_coord)
        puts "Invalid move; please try again"
        next
      end

      @start_object = piece
      @start_coord = start_coord.dup
      @end_object = @board.board[ end_coord[0] ] [ end_coord[1] ].dup
      @end_coord = end_coord.dup

      piece.make_move([ end_coord[0], end_coord[1] ])
      break
    end
  end

  def collect_input
    puts "Enter coord of piece to move:"
    start_coord = read_keyboard_input
    puts "Enter destination coord:"
    end_coord = read_keyboard_input
    return start_coord, end_coord
  end

  def read_keyboard_input
    gets.chomp.split(" ").map! { |el| el.to_i }
  end
end
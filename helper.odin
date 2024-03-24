package main

import rl "vendor:raylib"

starting_pos: rl.Vector2 = {160, HEIGHT - 120}
BOARD_LENGTH :: PIECE_SIZE * 8
PIECE_SIZE :: 80

get_coords_from_index :: proc(piece_index: int) -> [2]int{
    x := int(piece_index % 8)
    y := int(piece_index / 8)
    return {x, y} 
}

//0 - nothing 
//1 - white pawn
//2 - white rook
//3 - white knight
//4 - white bishop
//5 - white queen
//6 - white king
//7 - black pawn
//8 - black rook 
//9 - black knight
//10 - black bishop
//11 - black queen
//12 - black king

piece_int_to_enum :: proc(num: int) -> Pieces{
    piece: Pieces
    switch num{
        case 1: piece = .WHITE_PAWN
        case 2: piece = .WHITE_ROOK
        case 3: piece = .WHITE_KNIGHT
        case 4: piece = .WHITE_BISHOP
        case 5: piece = .WHITE_QUEEN
        case 6: piece = .WHITE_KING
        case 7: piece = .BLACK_PAWN
        case 8: piece = .BLACK_ROOK
        case 9: piece = .BLACK_KNIGHT
        case 10: piece = .BLACK_BISHOP
        case 11: piece = .BLACK_QUEEN
        case 12: piece = .BLACK_KING
    }
    return piece
}

piece_enum_to_int :: proc(piece_enum: Pieces) -> int{
    piece: int
    switch piece_enum{
        case .WHITE_PAWN: piece = 1
        case .WHITE_ROOK: piece = 2
        case .WHITE_KNIGHT: piece = 3
        case .WHITE_BISHOP: piece = 4
        case .WHITE_QUEEN: piece = 5
        case .WHITE_KING: piece = 6
        case .BLACK_PAWN: piece = 7
        case .BLACK_ROOK: piece = 8
        case .BLACK_KNIGHT: piece = 9
        case .BLACK_BISHOP: piece = 10
        case .BLACK_QUEEN: piece = 11
        case .BLACK_KING: piece = 12
    }
    return piece 
}

Pieces :: enum{
    WHITE_PAWN,
    WHITE_ROOK,
    WHITE_KNIGHT,
    WHITE_BISHOP,
    WHITE_QUEEN,
    WHITE_KING,
    BLACK_PAWN,
    BLACK_ROOK,
    BLACK_KNIGHT,
    BLACK_BISHOP,
    BLACK_QUEEN,
    BLACK_KING,
}
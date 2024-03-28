package main 

import rl "vendor:raylib"
import "core:fmt"


is_same_colour :: proc(piece_to_check: int, validate_piece: int) -> bool{
    if validate_piece > 0 && validate_piece < 7 && piece_to_check > 0 && piece_to_check < 7 ||
        validate_piece > 6 && piece_to_check > 6{
            return true
        }
    return false
}

is_different_colour :: proc(piece_to_check: int, validate_piece: int) -> bool{
    return !is_same_colour(piece_to_check, validate_piece) && piece_to_check != 0
}

check_if_move_is_legal :: proc(picked_index: int, moves: [dynamic]int) -> bool{
    is_move_legal := false
    for move in moves{
        if move == picked_index{
            is_move_legal = true
        }
    }
    return is_move_legal
}

show_possible_moves :: proc(moves: [dynamic]int, piece_index: int, piece: Pieces, pieces: [64]int){
    color := rl.Color{0, 0, 0, 70}
    for move in moves{
        move_pos := get_coords_from_index(move)

        if is_different_colour(pieces[move], piece_enum_to_int(piece)){
            //if there is a piece in front of a pawn we shouldn't draw a ring
            if piece == .WHITE_PAWN && move - 8 == piece_index || move + 8 == piece_index && piece == .BLACK_PAWN{
            }
            else{
                rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + move_pos.x * 80.0 + 40), f32(int(starting_pos.y) - move_pos.y * 80 + 40)}, 30, 38, 360.0, 0.0, 1, color) 
            }
        }
        else{
            rl.DrawCircle(i32(int(starting_pos.x) + move_pos.x * 80 + 40), i32(int(starting_pos.y) - move_pos.y * 80 + 40), 12.0, color)
        }
    }
}

is_square_attacked :: proc(square: int, pieces: [64]int, this_turn_color: bool) -> bool{
    pieces_indexes: [dynamic]int
    actual_pieces: [dynamic]int


    piece_of_this_turn_color := this_turn_color ? Pieces.WHITE_PAWN : Pieces.BLACK_PAWN

    for piece, i in pieces{
        if piece != 0 && !is_same_colour(piece, piece_enum_to_int(piece_of_this_turn_color)){
            append(&actual_pieces, piece)
            append(&pieces_indexes, i)
        }
    }
    for index, i in pieces_indexes{
        moves := get_moves(index, piece_int_to_enum(actual_pieces[i]), pieces)
        for move in moves{
            if move == square{
                return true
            }
        }
    }
    delete(actual_pieces)
    delete(pieces_indexes)

    return false 
}


//moves thingies
get_moves :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    moves: [dynamic]int
    #partial switch piece{
        case .WHITE_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
        case .BLACK_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
        case .WHITE_BISHOP: moves = get_moves_bishop(piece_index, piece, pieces)
        case .BLACK_BISHOP: moves = get_moves_bishop(piece_index, piece, pieces)
        case .WHITE_QUEEN: moves = get_moves_queen(piece_index, piece, pieces)
        case .BLACK_QUEEN: moves = get_moves_queen(piece_index, piece, pieces)
        case .WHITE_PAWN: moves = are_we_looking_at_white ? get_moves_white_pawn(piece_index, piece, pieces) : get_moves_black_pawn(piece_index, piece, pieces)
        case .BLACK_PAWN: moves = !are_we_looking_at_white ? get_moves_white_pawn(piece_index, piece, pieces) : get_moves_black_pawn(piece_index, piece, pieces)
        case .WHITE_KNIGHT: moves = get_moves_knight(piece_index, piece, pieces)
        case .BLACK_KNIGHT: moves = get_moves_knight(piece_index, piece, pieces)
        case .WHITE_KING: moves = get_king_moves(piece_index, piece, pieces)
        case .BLACK_KING: moves = get_king_moves(piece_index, piece, pieces)
    }
    return moves
}

get_king_moves :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    possible_moves: [dynamic]int
    pos := get_coords_from_index(piece_index)

    if pos.y < 7 && !is_same_colour(pieces[piece_index + 8], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 8)
    }
    if pos.y < 7 && pos.x < 7 && !is_same_colour(pieces[piece_index + 9], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 9)
    }
    if pos.x < 7 && !is_same_colour(pieces[piece_index + 1], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 1)
    }
    if pos.y > 0 && pos.x < 7 && !is_same_colour(pieces[piece_index - 7], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 7)
    }
    if pos.y > 0 && !is_same_colour(pieces[piece_index - 8], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 8)
    }
    if pos.y > 0  && pos.x > 0 && !is_same_colour(pieces[piece_index - 9], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 9)
    }
    if pos.x > 0 && !is_same_colour(pieces[piece_index - 1], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 1)
    }
    if pos.y < 7 && pos.x > 0 && !is_same_colour(pieces[piece_index + 7], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 7)
    }

    return possible_moves
}

get_moves_knight :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    piece_pos := get_coords_from_index(piece_index)
    possible_moves: [dynamic]int

    //0 0 8 0 1 0 0 0 
    //0 7 0 0 0 2 0 0 
    //0 0 0 N 0 0 0 0 
    //0 6 0 0 0 3 0 0 
    //0 0 5 0 4 0 0 0 

    checking_index := (piece_pos.y + 2) * 8 + piece_pos.x + 1
    if piece_pos.y < 6 && piece_pos.x != 7 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y + 1) * 8 + piece_pos.x + 2 
    if piece_pos.y != 7 && piece_pos.x < 6 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y - 1) * 8 + piece_pos.x + 2 
    if piece_pos.y != 0 && piece_pos.x < 6 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y - 2) * 8 + piece_pos.x + 1 
    if piece_pos.y > 1 && piece_pos.x != 7 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y - 2) * 8 + piece_pos.x - 1 
    if piece_pos.y > 1 && piece_pos.x != 0 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y - 1) * 8 + piece_pos.x - 2 
    if piece_pos.y != 0 && piece_pos.x > 1 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y + 1) * 8 + piece_pos.x - 2 
    if piece_pos.y != 7 && piece_pos.x > 1 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }
    checking_index = (piece_pos.y + 2) * 8 + piece_pos.x - 1 
    if piece_pos.y < 6 && piece_pos.x != 0 && !is_same_colour(pieces[checking_index], piece_enum_to_int(piece)){
        append(&possible_moves, checking_index)
    }

    return possible_moves
}

get_moves_queen :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    possible_moves := get_moves_bishop(piece_index, piece, pieces)
    for move in get_moves_rook(piece_index, piece, pieces){
        append(&possible_moves, move)
    }
    return possible_moves
}

get_moves_black_pawn :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    piece_pos := get_coords_from_index(piece_index)
    possible_moves: [dynamic]int

    counter_piece := are_we_looking_at_white ? Pieces.WHITE_PAWN : Pieces.BLACK_PAWN

    //index out of bounds check, probably will change in the future to promoting
    if piece_pos.y == 0{
        return possible_moves
    }

    //movement
    if !is_same_colour(pieces[piece_index - 8], piece_enum_to_int(piece)) && pieces[piece_index - 8] != piece_enum_to_int(counter_piece){
        append(&possible_moves, piece_index - 8)
    }
    if piece_pos.y == 6 && !is_same_colour(pieces[piece_index - 16], piece_enum_to_int(piece)) && pieces[piece_index - 16] != piece_enum_to_int(counter_piece){
        append(&possible_moves, piece_index - 16)
    }

    //piece attacking
    if is_different_colour(pieces[piece_index - 7], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 7)
    }
    if is_different_colour(pieces[piece_index - 9], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index - 9)
    }
    return possible_moves
}

get_moves_white_pawn :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    piece_pos := get_coords_from_index(piece_index)
    possible_moves: [dynamic]int

    counter_piece := are_we_looking_at_white ? Pieces.BLACK_PAWN : Pieces.WHITE_PAWN

    //index out of bounds check, probably will change in the future to promoting
    if piece_pos.y == 7{
        return possible_moves
    }

    //movement
    if !is_same_colour(pieces[piece_index + 8], piece_enum_to_int(piece)) && pieces[piece_index + 8] != piece_enum_to_int(counter_piece){
        append(&possible_moves, piece_index + 8)
    }
    if piece_pos.y == 1 && !is_same_colour(pieces[piece_index + 16], piece_enum_to_int(piece)) && pieces[piece_index + 16] != piece_enum_to_int(counter_piece){
        append(&possible_moves, piece_index + 16)
    }

    //piece attacking
    if is_different_colour(pieces[piece_index + 7], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 7)
    }
    if is_different_colour(pieces[piece_index + 9], piece_enum_to_int(piece)){
        append(&possible_moves, piece_index + 9)
    }
    return possible_moves
}

get_moves_bishop :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    piece_pos := get_coords_from_index(piece_index)
    possible_moves: [dynamic]int

    //top-right
    x_copy := piece_pos.x + 1 
    y_copy := piece_pos.y + 1
    for x_copy < 8 && y_copy < 8{
        if is_same_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            append(&possible_moves, int(y_copy * 8 + x_copy))
            break
        }
        append(&possible_moves, int(y_copy * 8 + x_copy))

        x_copy += 1
        y_copy += 1
    }
    //top-left
    x_copy = piece_pos.x - 1
    y_copy = piece_pos.y + 1
    for x_copy >= 0 && y_copy < 8{
        if is_same_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            append(&possible_moves, int(y_copy * 8 + x_copy))
            break
        }
        append(&possible_moves, int(y_copy * 8 + x_copy))

        x_copy -= 1
        y_copy += 1
    }
    //bottom-right
    x_copy = piece_pos.x + 1
    y_copy = piece_pos.y - 1
    for x_copy < 8 && y_copy >= 0{
        if is_same_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            append(&possible_moves, int(y_copy * 8 + x_copy))
            break
        }
        append(&possible_moves, int(y_copy * 8 + x_copy))

        x_copy += 1
        y_copy -= 1
    }
    //bottom-left
    x_copy = piece_pos.x - 1
    y_copy = piece_pos.y - 1
    for x_copy >= 0 && y_copy >= 0{
        if is_same_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[y_copy * 8 + x_copy], piece_enum_to_int(piece)){
            append(&possible_moves, int(y_copy * 8 + x_copy))
            break
        }
        append(&possible_moves, int(y_copy * 8 + x_copy))

        x_copy -= 1
        y_copy -= 1
    }

    return possible_moves
}

get_moves_rook :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    piece_pos := get_coords_from_index(piece_index)
    possible_moves: [dynamic]int

    //vertical to right
    for i in (piece_pos.x + 1)..<8{
        if is_same_colour(pieces[piece_pos.y * 8 + i], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[piece_pos.y * 8 + i], piece_enum_to_int(piece)){
            append(&possible_moves, int(piece_pos.y * 8 + i))
            break
        }
        append(&possible_moves, int(piece_pos.y * 8 + i))
    }

    //vertial from piece to left
    for i := piece_pos.x - 1; i >= 0; i -= 1{
        if is_same_colour(pieces[piece_pos.y * 8 + i], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[piece_pos.y * 8 + i], piece_enum_to_int(piece)){
            append(&possible_moves, int(piece_pos.y * 8 + i))
            break
        }
        append(&possible_moves, int(piece_pos.y * 8 + i))
    }

    //horizontal to up 
    for i in (piece_pos.y + 1)..<8{
        if is_same_colour(pieces[i * 8 + piece_pos.x], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[i * 8 + piece_pos.x], piece_enum_to_int(piece)){
            append(&possible_moves, int(i * 8 + piece_pos.x))
            break
        }
        append(&possible_moves, int(i * 8 + piece_pos.x))
    }
    //horizontal piece to down 
    for i := piece_pos.y - 1; i >= 0; i -= 1{
        if is_same_colour(pieces[i * 8 + piece_pos.x], piece_enum_to_int(piece)){
            break
        }
        else if is_different_colour(pieces[i * 8 + piece_pos.x], piece_enum_to_int(piece)){
            append(&possible_moves, int(i * 8 + piece_pos.x))
            break
        }
        append(&possible_moves, int(i * 8 + piece_pos.x))
    }

    return possible_moves 
}
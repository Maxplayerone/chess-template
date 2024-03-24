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


get_moves :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    moves: [dynamic]int
    #partial switch piece{
        case .WHITE_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
        case .BLACK_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
        case .WHITE_BISHOP: moves = get_moves_bishop(piece_index, piece, pieces)
        case .BLACK_BISHOP: moves = get_moves_bishop(piece_index, piece, pieces)
        case.WHITE_QUEEN: moves = get_moves_bishop(piece_index, piece, pieces)
                        for move in get_moves_rook(piece_index, piece, pieces){
                            append(&moves, move)
                        }
    }
    return moves
}

check_if_move_is_legal :: proc(pieces: [64]int, index: int, sel_piece_index: int, sel_piece: Pieces) -> bool{
    if index == sel_piece_index{
        return false
    }
    return true
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
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

get_moves :: proc(piece_index: int, piece: Pieces, pieces: [64]int) -> [dynamic]int{
    moves: [dynamic]int
    #partial switch piece{
        case .WHITE_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
        case .BLACK_ROOK: moves = get_moves_rook(piece_index, piece, pieces)
    }
    return moves
}

show_piece_possible_moves :: proc(index: int, piece: Pieces, pieces: [64]int){
    x := int(index % 8)
    y := int(index / 8)
    if x < 0 || y < 0{
        return 
    }

    radius := 12 
    color := rl.Color{0, 0, 0, 70}
    //color := rl.Color{255, 0, 255, 255}
    #partial switch piece{
        case .WHITE_PAWN:
            if (y + 1) * 8 + x > 63{
                return
            }
            if pieces[(y + 1) * 8 + x] == 0{
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - y * 80 - 40), f32(radius), color) 
            }
            if y == 1 && pieces[(y + 2) * 8 + x] == 0 && pieces[(y + 1) * 8 + x] == 0{
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - y * 80 - 120), f32(radius), color) 
            }

            //taking moves
            if pieces[(y + 1) * 8 + x + 1] > 6{
                rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + x * 80 + 120), f32(int(starting_pos.y) - y * 80 - 40)}, 30, 38, 360.0, 0.0, 1, color) 
            }
            if pieces[(y + 1) * 8 + x - 1] > 6{
                rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + x * 80 - 40), f32(int(starting_pos.y) - y * 80 - 40)}, 30, 38, 360.0, 0.0, 1, color) 
            }
        case .WHITE_ROOK: 
            for i in (x + 1)..<8{
                if pieces[y * 8 + i] > 6{
                    rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + x * 80 + 120), f32(int(starting_pos.y) - y * 80 + 40)}, 30, 38, 360.0, 0.0, 1, color) 
                    break
                }
                if pieces[y * 8 + i] != 0{
                    break
                }
                rl.DrawCircle(i32(int(starting_pos.x) + i * 80 + 40), i32(int(starting_pos.y) - y * 80 + 40), f32(radius), color) 
            }
            for i := (x -1); i >= 0; i -= 1{
                if pieces[y * 8 + i] != 0{
                    break
                }
                rl.DrawCircle(i32(int(starting_pos.x) + i * 80 + 40), i32(int(starting_pos.y) - y * 80 + 40), f32(radius), color) 
            }

            for i in (y + 1)..<8{
                if pieces[i * 8 + x] != 0{
                    break
                }
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - i * 80 + 40), f32(radius), color) 
            }
            for i := (y -1); i >= 0; i -= 1{
                if pieces[i * 8 + x] != 0{
                    break
                }
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - i * 80 + 40), f32(radius), color) 
            }
        case .BLACK_PAWN:
            if pieces[(y - 1) * 8 + x] == 0{
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - y * 80 + 120), f32(radius), color) 
            }
            if y == 6 && pieces[(y - 2) * 8 + x] == 0 && pieces[(y - 1) * 8 + x] == 0{
                rl.DrawCircle(i32(int(starting_pos.x) + x * 80 + 40), i32(int(starting_pos.y) - y * 80 + 200), f32(radius), color) 
            }

            //for taking pieces
            if pieces[(y - 1) * 8 + x + 1] < 7 && pieces[(y - 1) * 8 + x + 1] > 0{
                rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + x * 80 + 120), f32(int(starting_pos.y) - y * 80 + 120)}, 30, 38, 360.0, 0.0, 1, color) 
            }
            if pieces[(y - 1) * 8 + x - 1] < 7 && pieces[(y - 1) * 8 + x - 1] > 0{
                rl.DrawRing(rl.Vector2{f32(int(starting_pos.x) + x * 80 - 40), f32(int(starting_pos.y) - y * 80 + 120)}, 30, 38, 360.0, 0.0, 1, color) 
            }
    }
}

check_if_move_is_legal :: proc(pieces: [64]int, index: int, sel_piece_index: int, sel_piece: Pieces) -> bool{
    piece := sel_piece 
    can_move := false

    //the position in which the piece wants to move
    x := int(index % 8)
    y := int(index / 8)

    //the position the piece now occupies
    piece_x := int(sel_piece_index % 8)
    piece_y := int(sel_piece_index / 8)

    if index > 63{
        return can_move
    }

    #partial switch piece{
        case .WHITE_PAWN:
            if sel_piece_index + 8 == index && pieces[index] == 0 || piece_y == 1 && sel_piece_index + 16 == index && pieces[index] == 0 && pieces[index - 8] == 0{
                can_move = true
            } 

            //for taking pieces
            if sel_piece_index + 7 == index && pieces[index] > 6 || sel_piece_index + 9 == index && pieces[index] > 6{
                can_move = true
            }
        case .WHITE_ROOK: 
            //at least one delta thing has to be zero
            //there cannot be any piece between the rook and the wanted tile
            delta_x := abs(x - piece_x)
            delta_y := abs(y - piece_y)
            if delta_x != 0 && delta_y == 0 || delta_x == 0 && delta_y != 0{

                if delta_x != 0{
                    if x > piece_x{
                        for i in (piece_x + 1)..=x{
                            //a break-like statement
                            if pieces[piece_y * 8 + i] > 0 && pieces[piece_y * 8 + i] < 7{
                                return can_move
                            }
                        }
                    }
                    else{
                        for i := piece_x - 1; i > x; i -= 1{
                            if pieces[piece_y * 8 + i] != 0{
                                return can_move
                            }
                        }
                    }
                }
                else{
                    if y > piece_y{
                        for i in (piece_y + 1)..=y{
                            if pieces[i * 8 + piece_x] > 0 && pieces[i * 8 + piece_x] < 7{
                                return can_move
                            }
                        }
                    }
                    else{
                        for i := piece_y - 1; i > y; i -= 1{
                            if pieces[i * 8 + piece_x] != 0{
                                return can_move
                            }
                        }
                    }
                }

                can_move = true
            }
            case .BLACK_PAWN:
                if sel_piece_index - 8 == index && pieces[index] == 0 || piece_y == 6 && sel_piece_index - 16 == index && pieces[index] == 0 && pieces[index + 8] == 0{
                    can_move = true
                } 

                //for taking pieces
                if sel_piece_index - 7 == index && pieces[index] < 7 && pieces[index] > 0 || sel_piece_index - 9 == index && pieces[index] < 7 && pieces[index] > 0{
                    can_move = true
                }
    }
    return can_move 
}
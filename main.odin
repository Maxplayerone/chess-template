package main

import rl "vendor:raylib"
import "core:fmt"

WIDTH :: 960
HEIGHT :: 720

get_clicked_tile :: proc() -> int{
    index := -1
    x := int(rl.GetMouseX())
    y := int(rl.GetMouseY())

    x = x - int(starting_pos.x)
    y = y - int(starting_pos.y) - 80 //for convenience so x and y are 0.0 at the bottom left
    if x <= 0 || x >= BOARD_LENGTH || y >= 0 || y <= -BOARD_LENGTH{
        return index
    }

    x = x / 80
    y = -y / 80

    index = y * 8 + x

    return index
}

read_from_fen :: proc(fen: string) -> [64]int{
    pieces: [64]int
    i := -1

    for c in fen{
        switch c{
            case '1': i += 1
            case '2': i += 2
            case '3': i += 3
            case '4': i += 4
            case '5': i += 5
            case '6': i += 6
            case '7': i += 7
            case '8': i += 8
            case 'p': i += 1; pieces[i] = piece_enum_to_int(.BLACK_PAWN)
            case 'n': i += 1; pieces[i] = piece_enum_to_int(.BLACK_KNIGHT)
            case 'r': i += 1; pieces[i] = piece_enum_to_int(.BLACK_ROOK)
            case 'b': i += 1; pieces[i] = piece_enum_to_int(.BLACK_BISHOP)
            case 'q': i += 1; pieces[i] = piece_enum_to_int(.BLACK_QUEEN)
            case 'k': i += 1; pieces[i] = piece_enum_to_int(.BLACK_KING)
            case 'P': i += 1; pieces[i] = piece_enum_to_int(.WHITE_PAWN)
            case 'N': i += 1; pieces[i] = piece_enum_to_int(.WHITE_KNIGHT)
            case 'R': i += 1; pieces[i] = piece_enum_to_int(.WHITE_ROOK)
            case 'B': i += 1; pieces[i] = piece_enum_to_int(.WHITE_BISHOP)
            case 'Q': i += 1; pieces[i] = piece_enum_to_int(.WHITE_QUEEN)
            case 'K': i += 1; pieces[i] = piece_enum_to_int(.WHITE_KING)
        }
    }

    //rotate to our "coordinate-space"
    for i in 0..<8{
        temp := pieces[56 + i]
        pieces[56 + i] = pieces[i]
        pieces[i] = temp 
    }
    for i in 0..<8{
        temp := pieces[48 + i]
        pieces[48 + i] = pieces[8 + i]
        pieces[8 + i] = temp 
    }
    for i in 0..<8{
        temp := pieces[40 + i]
        pieces[40 + i] = pieces[16 + i]
        pieces[16 + i] = temp 
    }
    for i in 0..<8{
        temp := pieces[32 + i]
        pieces[32 + i] = pieces[24 + i]
        pieces[24 + i] = temp 
    }
    return pieces
}

is_this_that_color_turn :: proc(white_move: bool, pieces: [64]int, hovered_tile: int) -> bool{
    if white_move && pieces[hovered_tile] > 0 && pieces[hovered_tile] < 7{
        return true
    }
    else if !white_move && pieces[hovered_tile] > 6{
        return true
    }
    return false
}


are_we_looking_at_white := true
rotate_board :: proc(pieces: [64]int) -> [64]int{
    pieces := pieces

    for i in 0..<32{
        temp := pieces[i]
        pieces[i] = pieces[63 - i]
        pieces[63 - i] = temp
    }

    return pieces
}

main :: proc(){
    rl.InitWindow(WIDTH, HEIGHT, "Chess game")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    /*
    pieces[0] = 2
    pieces[1] = 3
    pieces[2] = 4
    pieces[3] = 5
    pieces[4] = 6
    pieces[5] = 4
    pieces[6] = 3
    pieces[7] = 2
    for i in 0..<8{
        pieces[8 + i] = 1
    }
    for i in 0..<8{
        pieces[48 + i] = piece_enum_to_int(.BLACK_PAWN)
    }

    pieces[56] = piece_enum_to_int(.BLACK_ROOK)
    pieces[57] = piece_enum_to_int(.BLACK_KNIGHT)
    pieces[58] = piece_enum_to_int(.BLACK_BISHOP)
    pieces[59] = piece_enum_to_int(.BLACK_QUEEN)
    pieces[60] = piece_enum_to_int(.BLACK_KING)
    pieces[61] = piece_enum_to_int(.BLACK_BISHOP)
    pieces[62] = piece_enum_to_int(.BLACK_KNIGHT)
    pieces[63] = piece_enum_to_int(.BLACK_ROOK)
    */

    pieces := read_from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")


    active_piece_index := -1
    active_piece := -1
    active_waiting_state := false

    white_move := true 

    moves: [dynamic]int

    rotate_icon := rl.LoadTexture("vendor/rotate.png")
    rotate_icon_rect := rl.Rectangle{starting_pos.x +  80.0 * 8.0 + 20.0, starting_pos.y, 40.0, 40.0}

    primary_color := rl.Color{122, 84, 61, 255}
    secondary_color := rl.Color{255, 238, 214, 255}

    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        for j in 0..<8{
            for i in 0..<8{
                color := primary_color
                if (i + j) % 2 == 1{
                    color = secondary_color 
                }

                rl.DrawRectangle(i32(int(starting_pos.x) + i * 80), i32(int(starting_pos.y) - j * 80), 80, 80, color) 
            }
        }

        for i in 0..<8{
            for j in 0..<8{
                piece_index := pieces[i * 8 + j]
                if piece_index > 0{
                    rl.DrawTexturePro(get_pieces_tex(), get_spritesheet_piece_pos(piece_index), rl.Rectangle{f32(int(starting_pos.x) + j * 80), f32(int(starting_pos.y) - i * 80), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
                }
            }
        }

        //changing cursor
        hovered_tile := get_clicked_tile()
        if hovered_tile != -1 && pieces[hovered_tile] != 0 && active_piece_index == -1{
            rl.SetMouseCursor(.CROSSHAIR)
        }
        else{
            rl.SetMouseCursor(.DEFAULT)
        }

        //when holding left click
        if rl.IsMouseButtonDown(.LEFT) && hovered_tile != -1 && pieces[hovered_tile] != 0{
            if active_piece_index == -1 || active_waiting_state == true && hovered_tile != active_piece_index{
                if is_this_that_color_turn(white_move, pieces, hovered_tile){
                    active_piece_index = hovered_tile
                    active_piece = pieces[active_piece_index]
                    pieces[active_piece_index] = 0

                    active_waiting_state = false

                    moves = get_moves(active_piece_index, piece_int_to_enum(active_piece), pieces) 
                }
            }
        }

        //while the left click is down (or the piece is in it's waiting tile)
        if active_piece_index != -1{
            /*
                    for move in moves{
                        draw_quad_at_index(move, rl.RED)
                    }
                    */

            //gradient
            real_x := i32(int(starting_pos.x) + int(active_piece_index % 8) * 80)
            real_y := i32(int(starting_pos.y) - int(active_piece_index / 8) * 80)
            rl.DrawRectangle(real_x, real_y, 80, 80, rl.Color{97, 158, 36, 255}) 

            show_possible_moves(moves, active_piece_index, piece_int_to_enum(active_piece), pieces)

            if !active_waiting_state{
                //drawing pieces at mouse position
                rl.DrawTexturePro(get_pieces_tex(), get_spritesheet_piece_pos(active_piece), rl.Rectangle{f32(rl.GetMouseX() - 40), f32(rl.GetMouseY() - 40), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)

                //outline
                if hovered_tile != -1{
                    x := i32(int(starting_pos.x) + int(hovered_tile % 8) * 80)
                    y := i32(int(starting_pos.y) - int(hovered_tile / 8) * 80)
                    rl.DrawRectangleLinesEx(rl.Rectangle{f32(x), f32(y), 80.0, 80.0}, 4.0, rl.WHITE);  
                }

                rl.SetMouseCursor(.POINTING_HAND)
            }
            else{
                rl.DrawTexturePro(get_pieces_tex(), get_spritesheet_piece_pos(active_piece), rl.Rectangle{f32(real_x), f32(real_y), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
            }
        }

        //after clicking left click
        if rl.IsMouseButtonReleased(.LEFT) && active_piece_index != -1{
            //if we try to drop pieces on the void we reset the move
            if hovered_tile == -1{
                pieces[active_piece_index] = active_piece
                active_piece_index = -1
            }
            else{
                if check_if_move_is_legal(hovered_tile, moves){
                    pieces[hovered_tile] = active_piece
                    pieces[active_piece_index] = 0
                    active_piece_index = -1

                    white_move = !white_move
                }
                else if hovered_tile == active_piece_index && active_waiting_state == false{
                    active_waiting_state = true 

                    pieces[active_piece_index] = active_piece
                }
                else{
                    pieces[active_piece_index] = active_piece
                    active_piece_index = -1
                }
            }
        }


        //-----------GUI----------
        if white_move{
            rl.DrawText("White to move", WIDTH / 2 - 120, 0, 40, rl.WHITE)
        }
        else{
            rl.DrawText("Black to move", WIDTH / 2 - 120, 0, 40, rl.WHITE)
        }

        if rl.IsMouseButtonPressed(.LEFT) && mouse_rect_col(rotate_icon_rect){
            temp_color := primary_color 
            primary_color = secondary_color
            secondary_color = temp_color
            pieces = rotate_board(pieces)

            are_we_looking_at_white = !are_we_looking_at_white
        }

        rl.DrawTextureEx(rotate_icon, {rotate_icon_rect.x, rotate_icon_rect.y}, 0.0, 0.02, rl.WHITE)

        rl.ClearBackground(rl.Color{56, 56, 56, 255})
    }
}
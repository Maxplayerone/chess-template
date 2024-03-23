package main

import rl "vendor:raylib"
import "core:fmt"

WIDTH :: 960
HEIGHT :: 720

starting_pos: rl.Vector2 = {160, HEIGHT - 120}
PIECE_SIZE :: 80
BOARD_LENGTH :: PIECE_SIZE * 8

get_spritesheet_piece_pos :: proc(i: int) -> rl.Rectangle{
    rect := rl.Rectangle{0.0, 0.0, 200.0, 200.0}
    piece := piece_int_to_enum(i)
    switch piece{
        case .WHITE_KING:
            rect.x = 0.0
            rect.y = 0.0
        case .WHITE_QUEEN:
            rect.x = 200.0
            rect.y = 0.0
        case .WHITE_BISHOP:
            rect.x = 400.0
            rect.y = 0.0
        case .WHITE_KNIGHT:
            rect.x = 600.0
            rect.y = 0.0
        case .WHITE_ROOK:
            rect.x = 800.0
            rect.y = 0.0
        case .WHITE_PAWN:
            rect.x = 1000.0
            rect.y = 0.0
        case .BLACK_KING:
            rect.x = 0.0
            rect.y = 1000.0
        case .BLACK_QUEEN:
            rect.x = 200.0
            rect.y = 1000.0
        case .BLACK_BISHOP:
            rect.x = 400.0
            rect.y = 1000.0
        case .BLACK_KNIGHT:
            rect.x = 600.0
            rect.y = 1000.0
        case .BLACK_ROOK:
            rect.x = 800.0
            rect.y = 1000.0
        case .BLACK_PAWN:
            rect.x = 1000.0
            rect.y = 1000.0
    }
    return rect
}

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

show_piece_possible_moves :: proc(index: int, pieces: [64]int){
    x := int(index % 8)
    y := int(index / 8)
    if x < 0 || y < 0{
        return 
    }

    radius := 12 
    color := rl.Color{0, 0, 0, 40}
    //color := rl.Color{255, 0, 255, 255}
    piece := piece_int_to_enum(pieces[index])
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
        case .WHITE_ROOK: 
            for i in (x + 1)..<8{
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
    }
}

check_if_move_is_legal :: proc(pieces: [64]int, index: int, sel_piece_index: int) -> bool{
    piece := piece_int_to_enum(pieces[sel_piece_index])
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

            if sel_piece_index + 7 == index && pieces[index] != 0 || sel_piece_index + 9 == index && pieces[index] != 0{
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
                        for i in (piece_x + 1)..<x{
                            if pieces[piece_y * 8 + i] != 0{
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
                        for i in (piece_y + 1)..<y{
                            if pieces[i * 8 + piece_x] != 0{
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
    }
    return can_move 
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

main :: proc(){
    rl.InitWindow(WIDTH, HEIGHT, "Chess game")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    pieces_tex := rl.LoadTexture("vendor/pieces.png")

    pieces: [64]int
    /*
    pieces[0] = 2
    pieces[1] = 3
    pieces[2] = 4
    pieces[3] = 5
    pieces[4] = 6
    pieces[5] = 4
    pieces[6] = 3
    pieces[7] = 2
    */
    for i in 0..<8{
        pieces[i] = piece_enum_to_int(.WHITE_ROOK)
    }

    for i in 0..<8{
        pieces[8 + i] = 1
    }

    for i in 0..<8{
        pieces[48 + i] = piece_enum_to_int(.BLACK_PAWN)
    }
    for i in 0..<8{
        pieces[56 + i] = piece_enum_to_int(.BLACK_ROOK)
    }

    //-----------TEST------------
    //pieces[38] = piece_enum_to_int(.WHITE_ROOK)
    //pieces[53] = piece_enum_to_int(.WHITE_PAWN)

    holding_piece := false
    index := 0

    active_piece_index := -1
    active_piece := -1

    active_waiting_state := false

    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        for j in 0..<8{
            for i in 0..<8{
                color := rl.Color{255, 238, 214, 255}
                if (i + j) % 2 == 1{
                    color = rl.Color{122, 84, 61, 255}
                }

                rl.DrawRectangle(i32(int(starting_pos.x) + i * 80), i32(int(starting_pos.y) - j * 80), 80, 80, color) 
            }
        }


        hovered_tile := get_clicked_tile()
        if hovered_tile != -1 && pieces[hovered_tile] != 0 && active_piece_index == -1{
            rl.SetMouseCursor(.CROSSHAIR)
        }
        else{
            rl.SetMouseCursor(.DEFAULT)
        }

        if rl.IsMouseButtonDown(.LEFT) && hovered_tile != -1 && pieces[hovered_tile] != 0 && active_piece_index == -1{
            active_piece_index = hovered_tile
            active_piece = pieces[active_piece_index]
            pieces[active_piece_index] = 0

            active_waiting_state = false
        }

        if active_piece_index != -1{
            //gradient
            real_x := i32(int(starting_pos.x) + int(active_piece_index % 8) * 80)
            real_y := i32(int(starting_pos.y) - int(active_piece_index / 8) * 80)
            rl.DrawRectangle(real_x, real_y, 80, 80, rl.Color{97, 158, 36, 255}) 

            show_piece_possible_moves(active_piece_index, pieces)

            if !active_waiting_state{
                rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(pieces[active_piece_index]), rl.Rectangle{f32(rl.GetMouseX() - 40), f32(rl.GetMouseY() - 40), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)

                //outline
                x := i32(int(starting_pos.x) + int(hovered_tile % 8) * 80)
                y := i32(int(starting_pos.y) - int(hovered_tile / 8) * 80)
                rl.DrawRectangleLinesEx(rl.Rectangle{f32(x), f32(y), 80.0, 80.0}, 4.0, rl.WHITE);  

                rl.SetMouseCursor(.POINTING_HAND)
            }
        }

        if rl.IsMouseButtonReleased(.LEFT) && active_piece_index != -1{
            if check_if_move_is_legal(pieces, hovered_tile, active_piece_index){
                pieces[hovered_tile] = active_piece
                pieces[active_piece_index] = 0
                active_piece_index = -1
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

        /*
        if rl.IsMouseButtonDown(.LEFT){

        }
        */

        /*
        if rl.IsMouseButtonDown(.LEFT){
            mouse_pos := rl.GetMousePosition()
            index := 0
            if !holding_piece{
                index = get_clicked_tile()
                holding_piece = true
            }
            rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(index), rl.Rectangle{mouse_pos.x, mouse_pos.y, 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)

            if rl.IsMouseButtonReleased(.LEFT){
                holding_piece = false

                if cur_sel_index >= 0{
                    if check_if_move_is_legal(pieces, index, cur_sel_index){
                        pieces[index] = pieces[cur_sel_index]
                        pieces[cur_sel_index] = 0
                        cur_sel_index = -1
                    }
                    else{
                        cur_sel_index = -1
                    }
                }
                else if index >= 0 && index < 64 && pieces[index] != 0{
                    cur_sel_index = index
                }
            }
        }
        */

        /*
        if rl.IsMouseButtonDown(.LEFT){
            mouse_pos := rl.GetMousePosition()
            if !holding_piece{
                index = get_clicked_tile()
                holding_piece = true
            }
            rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(pieces[index]), rl.Rectangle{mouse_pos.x, mouse_pos.y, 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
        }
        if rl.IsMouseButtonReleased(.LEFT){
            holding_piece = false
            mouse_pos := rl.GetMousePosition()
            //get wanted index as the index the cursor is currently above and then check if it's move is legal
            if check_if_move_is_legal(pieces, index){
                pieces[index] = pieces[]
            }

                if cur_sel_index >= 0{
                    if check_if_move_is_legal(pieces, index, cur_sel_index){
                        pieces[index] = pieces[cur_sel_index]
                        pieces[cur_sel_index] = 0
                        cur_sel_index = -1
                    }
                    else{
                        cur_sel_index = -1
                    }
                }
                else if index >= 0 && index < 64 && pieces[index] != 0{
                    cur_sel_index = index
                }
        }
        */
        for i in 0..<8{
            for j in 0..<8{
                piece_index := pieces[i * 8 + j]
                if piece_index > 0{
                    rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(piece_index), rl.Rectangle{f32(int(starting_pos.x) + j * 80), f32(int(starting_pos.y) - i * 80), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
                }
            }
        }

        rl.ClearBackground(rl.Color{56, 56, 56, 255})
    }
}
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

        for i in 0..<8{
            for j in 0..<8{
                piece_index := pieces[i * 8 + j]
                if piece_index > 0{
                    rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(piece_index), rl.Rectangle{f32(int(starting_pos.x) + j * 80), f32(int(starting_pos.y) - i * 80), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
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
                active_piece_index = hovered_tile
                active_piece = pieces[active_piece_index]
                pieces[active_piece_index] = 0

                active_waiting_state = false
            }
        }

        //while the left click is down (or the piece is in it's waiting tile)
        if active_piece_index != -1{
            //gradient
            real_x := i32(int(starting_pos.x) + int(active_piece_index % 8) * 80)
            real_y := i32(int(starting_pos.y) - int(active_piece_index / 8) * 80)
            rl.DrawRectangle(real_x, real_y, 80, 80, rl.Color{97, 158, 36, 255}) 

            show_piece_possible_moves(active_piece_index, piece_int_to_enum(active_piece), pieces)

            if !active_waiting_state{
                rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(active_piece), rl.Rectangle{f32(rl.GetMouseX() - 40), f32(rl.GetMouseY() - 40), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)

                //outline
                x := i32(int(starting_pos.x) + int(hovered_tile % 8) * 80)
                y := i32(int(starting_pos.y) - int(hovered_tile / 8) * 80)
                rl.DrawRectangleLinesEx(rl.Rectangle{f32(x), f32(y), 80.0, 80.0}, 4.0, rl.WHITE);  

                rl.SetMouseCursor(.POINTING_HAND)
            }
            else{
                rl.DrawTexturePro(pieces_tex, get_spritesheet_piece_pos(active_piece), rl.Rectangle{f32(real_x), f32(real_y), 80, 80}, rl.Vector2{0.0, 0.0}, 0.0, rl.WHITE)
            }
        }

        //after clicking left click
        if rl.IsMouseButtonReleased(.LEFT) && active_piece_index != -1{
            if check_if_move_is_legal(pieces, hovered_tile, active_piece_index, piece_int_to_enum(active_piece)){
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

        rl.ClearBackground(rl.Color{56, 56, 56, 255})
    }
}
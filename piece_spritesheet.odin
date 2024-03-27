package main

import rl "vendor:raylib"

@(private="file")
pieces_tex: rl.Texture 

get_pieces_tex :: proc() -> rl.Texture{
    if pieces_tex.width == 0{
        pieces_tex = rl.LoadTexture("vendor/pieces.png")
    }
    return pieces_tex
}

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
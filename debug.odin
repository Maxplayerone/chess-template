package main

import rl "vendor:raylib"
import "core:fmt"

draw_quad_at_index :: proc(index: int, color: rl.Color){
    piece_pos := get_coords_from_index(index)
    rl.DrawRectangle(i32(starting_pos.x + f32(piece_pos.x) * 80.0), i32(starting_pos.y - 80.0 * f32(piece_pos.y)), 80, 80, color)
}
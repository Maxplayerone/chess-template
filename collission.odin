package main

import rl "vendor:raylib"
import "core:fmt"

mouse_rect_col :: proc(rect: rl.Rectangle) -> bool{
    x := f32(rl.GetMouseX())
    y := f32(rl.GetMouseY())

    if x > rect.x && x < rect.x + rect.width && y > rect.y && y < rect.y + rect.height{
        return true
    }
    return false
}
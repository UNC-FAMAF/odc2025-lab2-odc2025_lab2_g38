.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

.extern paint_sky_night
.extern paint_moon
.extern fore_ground
.extern paint_casita
.extern update_moon_position
.extern restore_background_at

.extern draw_rectangle
.extern draw_odc2025

.extern moon_x
.extern moon_y
.extern moon_x_prev
.extern moon_y_prev

.globl main

main:
    // x0 contiene la direccion base del framebuffer
    mov x20, x0 // Guarda la dirección base del framebuffer en x20 
    mov x23, x20

    // Dibuja objetos estáticos SOLO UNA VEZ
    bl paint_sky_night
    bl fore_ground
    mov x0, x23
    mov x1, #50
    mov x2, #400
    movz w3, #0xFF, lsl 16
    movk w3, #0x6666, lsl 00
    bl draw_odc2025
    bl paint_casita

LoopAnim:
    // Actualiza la posición de la luna
    bl update_moon_position

    
    // Dibujar la luna en la nueva posición
    ldr x1, =moon_x
    ldr w6, [x1]
    ldr x1, =moon_y
    ldr w5, [x1]
    bl paint_moon

    // Restaurar el fondo donde estaba la luna anterior
    ldr x1, =moon_x_prev
    ldr w6, [x1]
    ldr x1, =moon_y_prev
    ldr w5, [x1]
    bl restore_background_at

    b LoopAnim


.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

// Variables globales para la posición de la luna
.data
.align 3
moon_t:      .word 0        // t*1000, inicia en 0
moon_dt:     .word 10       // dt*1000, por ejemplo 0.01 -> 10
moon_x:      .word 0
moon_y:      .word 0
moon_x_prev: .word 0
moon_y_prev: .word 0

zero: .word 0
one:  .word 1000            // 1.0 representado como 1000

.text
.global update_moon_position
.global moon_x
.global moon_y
.global moon_x_prev
.global moon_y_prev

update_moon_position:
    // Guarda posición anterior
    ldr x1, =moon_x
    ldr w2, [x1]
    ldr x3, =moon_x_prev
    str w2, [x3]
    ldr x1, =moon_y
    ldr w2, [x1]
    ldr x3, =moon_y_prev
    str w2, [x3]

    // Leer t y dt
    ldr x1, =moon_t
    ldr w2, [x1]
    ldr x3, =moon_dt
    ldr w4, [x3]
    add w2, w2, w4
    str w2, [x1]

    // Movimiento horizontal simple: x = 70 + (t/10) % 510
    mov w5, w2
    mov w8, #10
    udiv w5, w5, w8
    mov w6, #510
    udiv w7, w5, w6
    msub w5, w7, w6, w5 // w5 = w5 - w7*w6 (w5 mod w6)
    add w11, w5, #70    // x = 70 + (t/10)%510

    // Y fijo más arriba (por ejemplo, 120)
    mov w17, #120       // y fijo más arriba

    // Guardar nuevas posiciones
    ldr x1, =moon_x
    str w11, [x1]
    ldr x1, =moon_y
    str w17, [x1]

    ret

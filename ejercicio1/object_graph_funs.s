.include "graph_funs.s"
    .equ SCREEN_WIDTH,   640
    .equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32

    //-----------------------------------------------
    // paint_sun
    // Dibuja un sol con varios círculos concéntricos,
    // reduciendo radio y oscureciendo el color.
.globl paint_sun        // Exporta la etiqueta para que sea visible
paint_sun:
    sub     sp, sp, #48               // reservar espacio en stack
    str     lr, [sp]                  // guardar lr
    str     x5, [sp, #8]              // guardar Y del centro
    str     x6, [sp, #16]             // guardar X del centro
    str     x7, [sp, #24]             // guardar r²
    str     x8, [sp, #32]             // guardar radio
    str     x10,[sp, #40]             // guardar color

    // Círculo grande (color 0x00FFDAFF, r = 120)
    movz    x10, #0x00FF, lsl 16      // w10 = 0x00FF0000
    movk    x10, #0xDAFF              // w10 = 0x00FFDAFF
    mov     x8, 120                   // radio inicial
    mul     x7, x8, x8                // r²
    mov     x5, 240                   // Y del centro
    mov     x6, 110                   // X del centro
    bl      paint_circle              // invoca paint_circle

    // Círculo intermedio (r = 100, color 0x00FFC44E)
    sub     x8, x8, #20               // nuevo radio = 100
    mul     x7, x8, x8
    movz    x10, #0x00FF, lsl 16      // w10 = 0x00FF0000
    movk    x10, #0xC44E              // w10 = 0x00FFC44E
    bl      paint_circle

    // Círculo siguiente (r = 80, color 0x00FFB829)
    sub     x8, x8, #20               // nuevo radio = 80
    mul     x7, x8, x8
    movz    x10, #0x00FF, lsl 16      // w10 = 0x00FF0000
    movk    x10, #0xB829              // w10 = 0x00FFB829
    bl      paint_circle

    // Círculo más pequeño (r = 70, color 0x00FFAA00)
    sub     x8, x8, #10               // nuevo radio = 70
    mul     x7, x8, x8
    movz    x10, #0x00FF, lsl 16      // w10 = 0x00FF0000
    movk    x10, #0xAA00              // w10 = 0x00FFAA00
    bl      paint_circle

    // Restaurar registros y volver
    ldr     lr, [sp]
    ldr     x5, [sp, #8]
    ldr     x6, [sp, #16]
    ldr     x7, [sp, #24]
    ldr     x8, [sp, #32]
    ldr     x10,[sp, #40]
    add     sp, sp, #48
    ret
    //-----------------------------------------------


    //-----------------------------------------------
    // paint_sky_day
    // Pinta el cielo en modo “día”:
    // 1) Mitad inferior color oscuro
    // 2) Mitad superior color claro
    // 3) Rayas horizontales dispersas (nubes)
.globl paint_sky_day    // Exporta la etiqueta para que sea visible 
paint_sky_day:
    sub     sp, sp, #64                // reservar espacio en stack
    str     lr, [sp]                   // guardar lr
    str     x8, [sp, #8]               // (no usado aquí)
    str     x9, [sp, #16]              // (no usado aquí)
    str     x10,[sp, #24]              // guardar color
    str     x11,[sp, #32]              // offset entre rayas
    str     x15,[sp, #40]              // Y inicial de rayas

    // Fondo inferior (0x00FFE573)
    movz    w10, #0x00FF, lsl 16       // w10 = 0x00FF0000
    movk    w10, #0xE573              // w10 = 0x00FFE573
    bl      background_paint           // pinta toda la pantalla

    // Fondo superior (0x00FFFA99)
    movz    w10, #0x00FF, lsl 16       // w10 = 0x00FF0000
    movk    w10, #0xFA99              // w10 = 0x00FFFA99
    bl      upper_half                 // pinta mitad superior

    // Rayas horizontales (0x00FFE573)
    movz    w10, #0x00FF, lsl 16       // w10 = 0x00FF0000
    movk    w10, #0xE573              // w10 = 0x00FFE573
    mov     x16, 0                    // X inicio
    mov     x20, 640                  // X fin
    mov     x15, 240                  // Y inicial (mitad pantalla)
    mov     x11, 0                    // offset entre rayas

loop_hor_lines:
    cbz     x15, end_hor_line         // si Y = 0, terminar
    bl      paint_line_hr             // pinta 1 px de grosor
    sub     x15, x15, #1
    bl      paint_line_hr             // segundo px de grosor
    sub     x15, x15, #1
    bl      paint_line_hr             // tercer px de grosor
    sub     x15, x15, x11             // bajar según offset
    add     x11, x11, #2              // aumentar separación
    b       loop_hor_lines

end_hor_line:
    // Restaurar registros y volver
    ldr     lr,  [sp]
    ldr     x8,  [sp, #8]
    ldr     x9,  [sp, #16]
    ldr     x11, [sp, #24]
    ldr     x10, [sp, #32]
    ldr     x12, [sp, #40]
    add     sp,  sp, #64
    ret
    //-----------------------------------------------


    //-----------------------------------------------
    // fore_ground
    // Dibuja lomas/terreno con líneas inclinadas
.globl fore_ground      // Exporta la etiqueta para que sea visible desde el linker/otros archivos
fore_ground:
    sub     sp, sp, #64                // reservar espacio en stack

    str     lr,  [sp]                  // guardar lr
    str     x10, [sp, #8]              // guardar color
    str     x8,  [sp, #16]             // guardar contador filas
    str     x9,  [sp, #24]             // guardar offset X
    str     x15, [sp, #32]             // guardar Y
    str     x16, [sp, #40]             // guardar X inicio
    str     x20, [sp, #48]             // guardar X fin

    // Bloque principal de loma (0x00265430)
    movz    w10, #0x0026, lsl 16       // w10 = 0x00260000
    movk    w10, #0x5430               // w10 = 0x00265430
    mov     x16, 600                  // X inicio
    mov     x20, 640                  // X fin
    mov     x15, 270                  // Y inicial
    mov     x8, 6                     // grosor en filas
    mov     x9, 70                    // offset X por paso

loop_fore_ground_0:
    cmp     x15, 480                  // si Y >= 480, saltar
    b.eq    det_lines_R
    bl      paint_line_hr             // dibuja línea
    add     x15, x15, #1
    sub     x8, x8, #1
    cbnz    x8, loop_fore_ground_0
    mov     x8, 6
    sub     x16, x16, x9              // desplazar X inicio
    cmp     x9, 0
    b.le    loop_fore_ground_0
    sub     x9, x9, #4
    b       loop_fore_ground_0

det_lines_R:
    // Detalles de la loma (color 0x00387144)
    mov     x16, 600
    mov     x20, 640
    mov     x15, 270
    movz    w10, #0x0038, lsl 16      // w10 = 0x00380000
    movk    w10, #0x7144              // w10 = 0x00387144
    mov     x8, 6
    mov     x9, 70

det_lines_0:
    cmp     x15, 480
    b.eq    cont_foreground
    add     x15, x15, #1
    sub     x8, x8, #1
    cbnz    x8, det_lines_0
    bl      paint_line_hr
    mov     x8, 6
    sub     x16, x16, x9
    cmp     x9, 0
    b.le    det_lines_0
    sub     x9, x9, #4
    b       det_lines_0

cont_foreground:
    // Segundo bloque de loma en la parte izquierda
    movz    w10, #0x0038, lsl 16      // w10 = 0x00380000
    movk    w10, #0x7144              // w10 = 0x00387144
    mov     x16, 0
    mov     x20, 2
    mov     x15, 280
    mov     x8, 5
    mov     x9, 60

loop_fore_ground_1:
    cmp     x15, 480
    b.eq    det_lines_L
    bl      paint_line_hr
    add     x15, x15, #1
    sub     x8, x8, #1
    cbnz    x8, loop_fore_ground_1
    mov     x8, 5
    add     x20, x20, x9
    cmp     x9, 0
    b.le    loop_fore_ground_1
    sub     x9, x9, #2
    b       loop_fore_ground_1

det_lines_L:
    // Detalles de la loma izquierda (color 0x00265430)
    movz    w10, #0x0026, lsl 16      // w10 = 0x00260000
    movk    w10, #0x5430              // w10 = 0x00265430
    mov     x16, 0
    mov     x20, 2
    mov     x15, 280
    mov     x8, 5
    mov     x9, 60

det_lines_1:
    cmp     x15, 480
    b.eq    end_foreground
    add     x15, x15, #1
    sub     x8, x8, #1
    cbnz    x8, det_lines_1
    bl      paint_line_hr
    mov     x8, 5
    add     x20, x20, x9
    cmp     x9, 0
    b.le    det_lines_1
    sub     x9, x9, #2
    b       det_lines_1

end_foreground:
    // Restaurar registros y volver
    ldr     lr,  [sp]
    ldr     x10, [sp, #8]
    ldr     x8,  [sp, #16]
    ldr     x9,  [sp, #24]
    ldr     x15, [sp, #32]
    ldr     x16, [sp, #40]
    ldr     x20, [sp, #48]
    add     sp,  sp, #64
    ret
    //-----------------------------------------------


    //-----------------------------------------------
    // paint_casita
    // Dibuja una casita con cuerpo, puerta, ventanas y techo
.globl paint_casita     // Exporta la etiqueta
paint_casita:
    sub     sp, sp, #40               // reservar espacio en stack
    str     lr,  [sp]                 // guardar lr
    str     x10, [sp, #8]             // guardar color
    str     x15, [sp, #16]            // guardar Y
    str     x16, [sp, #24]            // guardar X inicio
    str     x20, [sp, #32]            // guardar X fin

    // Parte principal de la casa (cuerpo) color 0x00BB9766
    mov     x16, 500                  // X inicio
    mov     x20, 580                  // X fin
    mov     x15, 260                  // Y inicial
    movz    w10, #0x00BB, lsl 16      // w10 = 0x00BB0000
    movk    w10, #0x9766              // w10 = 0x00BB9766

loop_casita_princ:
    cmp     x15, 300                  // hasta Y = 300
    b.eq    end_casita_princ
    bl      paint_line_hr             // dibuja línea del cuerpo
    add     x15, x15, #1
    b       loop_casita_princ

end_casita_princ:
    // Frente de la casa (color 0x00957850)
    movz    w10, #0x0095, lsl 16      // w10 = 0x00950000
    movk    w10, #0x7850              // w10 = 0x00957850
    mov     x16, 480
    mov     x20, 500
    mov     x15, 240

loop_casita_front:
    cmp     x15, 300
    b.eq    end_casita_front
    bl      paint_line_hr             // dibuja línea frontal
    add     x15, x15, #1
    b       loop_casita_front

end_casita_front:
    // Puerta (color 0x0097641F)
    movz    w10, #0x0097, lsl 16      // w10 = 0x00970000
    movk    w10, #0x641F              // w10 = 0x0097641F
    mov     x16, 485
    mov     x20, 495
    mov     x15, 280

loop_casita_puerta:
    cmp     x15, 300
    b.eq    end_casita_puerta
    bl      paint_line_hr             // dibuja línea de puerta
    add     x15, x15, #1
    b       loop_casita_puerta

end_casita_puerta:
    // Ventanas (color 0x00FFFFFF)
    movz    w10, #0x00FF, lsl 16      // w10 = 0x00FF0000
    movk    w10, #0xFFFF              // w10 = 0x00FFFFFF

    // Ventana izquierda
    mov     x16, 510
    mov     x20, 530
    mov     x15, 275

loop_casita_ventana_0:
    cmp     x15, 295
    b.eq    end_casita_ventana_0
    bl      paint_line_hr             // dibuja línea ventana
    add     x15, x15, #1
    b       loop_casita_ventana_0

end_casita_ventana_0:
    // Ventana derecha
    mov     x16, 550
    mov     x20, 570
    mov     x15, 275

loop_casita_ventana_1:
    cmp     x15, 295
    b.eq    end_casita_ventana_1
    bl      paint_line_hr             // dibuja línea ventana
    add     x15, x15, #1
    b       loop_casita_ventana_1

end_casita_ventana_1:
    // Techo trasero (color 0x00972F1F)
    movz    w10, #0x0097, lsl 16      // w10 = 0x00970000
    movk    w10, #0x2F1F              // w10 = 0x00972F1F
    mov     x16, 480
    mov     x20, 580
    mov     x15, 240

loop_casita_techo_back:
    cmp     x15, 260
    b.eq    end_casita_techo_back
    bl      paint_line_hr             // dibuja línea techo trasero
    add     x15, x15, #1
    sub     x16, x16, #1              // reducir ancho trasero
    sub     x20, x20, #1
    b       loop_casita_techo_back

end_casita_techo_back:
    // Techo principal (mismo color)
    movz    w10, #0x0097, lsl 16
    movk    w10, #0x2F1F
    mov     x16, 480
    mov     x20, 580
    mov     x15, 240

loop_casita_techo_princ:
    cmp     x15, 260
    b.eq    end_casita_techo_princ
    bl      paint_line_hr             // dibuja línea techo principal
    add     x15, x15, #1
    add     x16, x16, #1              // ensanchar techo principal
    add     x20, x20, #1
    b       loop_casita_techo_princ

end_casita_techo_princ:
    // Chimenea (color 0x00504645)
    mov     x16, 560
    mov     x20, 570
    mov     x15, 225
    movz    w10, #0x0050, lsl 16      // w10 = 0x00500000
    movk    w10, #0x4645              // w10 = 0x00504645

loop_casita_chim:
    cmp     x15, 250                 // comparamos Y con 250 (tope de chimenea)
    b.eq    end_casita_chim         // si Y == 250, salimos
    bl      paint_line_hr           // dibuja 1px de la chimenea
    add     x15, x15, #1            // incrementa Y
    b       loop_casita_chim        // repite hasta llegar a 250

end_casita_chim:
    // Restaurar registros y regresar
    ldr     lr,  [sp]
    ldr     x10, [sp, #8]
    ldr     x15, [sp, #16]
    ldr     x16, [sp, #24]
    ldr     x20, [sp, #32]
    add     sp,  sp, #40
    ret

    .globl draw_text_OdC2025

draw_text_OdC2025:
    // Color del texto = blanco (0x00FFFFFF)
    movz    w10, #0x00FF, lsl 16    // w10 = 0x00FF0000
    movk    w10, #0x00FF            // w10 = 0x00FFFFFF

    // ─── LETRA “O” (en 50,400; ancho=40, alto=80) ───
    mov     x1, #50
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #50
    mov     x2, #475    // 400 + 80 – 5
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #50
    mov     x2, #405    // 400 + 5
    mov     x3, #5
    mov     x4, #70    // 80 – 2×5
    bl      paint_rect

    mov     x1, #85    // 50 + 40 – 5
    mov     x2, #405
    mov     x3, #5
    mov     x4, #70
    bl      paint_rect

    // ─── LETRA “d” (en 110,400; ancho=40, alto=80) ───
    mov     x1, #110
    mov     x2, #400
    mov     x3, #5
    mov     x4, #80
    bl      paint_rect

    mov     x1, #110
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #110
    mov     x2, #475    // 400 + 80 – 5
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #145    // 110 + 40 – 5
    mov     x2, #435    // 400 + 35
    mov     x3, #5
    mov     x4, #40     // 80 – 2×5 – 35
    bl      paint_rect

    // ─── LETRA “C” (en 170,400; ancho=40, alto=80) ───
    mov     x1, #170
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #170
    mov     x2, #475
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #170
    mov     x2, #405    // 400 + 5
    mov     x3, #5
    mov     x4, #70
    bl      paint_rect

    // ─── LETRA “2” (en 230,400; ancho=40, alto=80) ───
    mov     x1, #230
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #265    // 230 + 40 – 5
    mov     x2, #405    // 400 + 5
    mov     x3, #5
    mov     x4, #35     // mitad superior
    bl      paint_rect

    mov     x1, #230
    mov     x2, #435    // 400 + 35
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #230
    mov     x2, #435
    mov     x3, #5
    mov     x4, #35     // mitad inferior
    bl      paint_rect

    mov     x1, #230
    mov     x2, #475
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    // ─── LETRA “0” (en 290,400; ancho=40, alto=80) ───
    mov     x1, #290
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #290
    mov     x2, #475
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #290
    mov     x2, #405    // 400 + 5
    mov     x3, #5
    mov     x4, #70     // 80 – 2×5
    bl      paint_rect

    mov     x1, #325    // 290 + 40 – 5
    mov     x2, #405
    mov     x3, #5
    mov     x4, #70
    bl      paint_rect

    // ─── LETRA “2” (segunda vez en 350,400) ───
    mov     x1, #350
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #385    // 350 + 40 – 5
    mov     x2, #405
    mov     x3, #5
    mov     x4, #35
    bl      paint_rect

    mov     x1, #350
    mov     x2, #435    // 400 + 35
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #350
    mov     x2, #435
    mov     x3, #5
    mov     x4, #35
    bl      paint_rect

    mov     x1, #350
    mov     x2, #475
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    // ─── LETRA “5” (en 410,400; ancho=40, alto=80) ───
    mov     x1, #410
    mov     x2, #400
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #410
    mov     x2, #405    // 400 + 5
    mov     x3, #5
    mov     x4, #35
    bl      paint_rect

    mov     x1, #410
    mov     x2, #435    // 400 + 35
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    mov     x1, #445    // 410 + 40 – 5
    mov     x2, #435
    mov     x3, #5
    mov     x4, #40     // 80 – 2×5 – 35
    bl      paint_rect

    mov     x1, #410
    mov     x2, #475
    mov     x3, #40
    mov     x4, #5
    bl      paint_rect

    ret


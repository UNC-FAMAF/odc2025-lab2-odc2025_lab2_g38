// Funciones para dibujar texto en pantalla.

// Definiciones de constantes de la pantalla
.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGHT, 480
.equ PIXEL_SIZE, 4 // Cada píxel es de 32 bits (4 bytes) [4]

.extern draw_rectangle

.text
.globl draw_odc2025 // Declara draw_odc2025 como global.

// draw_odc2025(framebuffer_base (x0), x_pos (x1), y_pos (x2), color (w3))
// Dibuja la inscripción "OdC 2025" usando rectángulos simples.
draw_odc2025:
    // Salvar registros callee-saved que serán usados.
    stp x19, x20, [sp, #-16]! // Guarda x19, x20.
    str x21, [sp, #-8]!      // Guarda x21.
    str lr, [sp, #-8]!       // Guarda el Link Register.

    // Mover argumentos a registros callee-saved.
    mov x19, x0 // framebuffer_base
    mov x20, x1 // x_pos inicial del texto
    mov x21, x2 // y_pos inicial del texto
    mov w22, w3 // color del texto

    // Dibujar 'O' (representado por un rectángulo)
    // Argumentos para draw_rectangle: fb_base, x_start, y_start, width, height, color
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #0     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #0     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #0     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #15     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle

    // Dibujar 'd'
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #45     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izq
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #30     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #20     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #30     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #17     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #30     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    // Dibujar 'C'
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #60     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #60     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #60     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    
    // Dibujar '2' (del año)
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #100     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //medio
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #100     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #17     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #100     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #100     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #20     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #115     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle

    // Dibujar '0'
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #130     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #130     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #130     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #145     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #40         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle

    // Dibujar '2' (segundo del año)
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #160     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //medio
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #160     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #17     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #160     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #160     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #20     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #175     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle

    // Dibujar '5'
    //arriba
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #190     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //medio
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #190     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #17     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //abajo
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #190     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #35     // y_start para 'O' (relativo a y_pos)
    mov x3, #20         // Ancho del carácter
    mov x4, #5         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //izquierda
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #190     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #0     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle
    
    //derecha
    mov x0, x19         // Pasa framebuffer_base
    add x1, x20, #205     // x_start para 'O' (relativo a x_pos)
    add x2, x21, #20     // y_start para 'O' (relativo a y_pos)
    mov x3, #5         // Ancho del carácter
    mov x4, #20         // Alto del carácter
    mov w5, w22         // Color
    bl draw_rectangle


    // Restaurar registros callee-saved en orden inverso.
    ldr lr, [sp], #8        // Restaura LR.
    ldr x21, [sp], #8      // Restaura x21.
    ldp x19, x20, [sp], #16 // Restaura x19, x20.

    ret // Retorna de la función.

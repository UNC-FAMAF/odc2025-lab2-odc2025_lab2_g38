.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

.globl draw_rectangle


// Subrutina: draw_rectangle
//
// Dibuja un rectángulo rellenado con un color especificado
// en el framebuffer.
//
// Registros modificados: X10, X11 (temporales), X25, X26, X27, X28, X29 (contadores/cálculos).
// Preserva: Registros callee-saved (X19-X30, incluyendo LR).

// draw_pixel(framebuffer_base (x0), x (x1), y (x2), color (w3))
// Dibuja un píxel individual en la pantalla.
draw_pixel:
    mov x5, #SCREEN_WIDTH
    mul x4, x2, x5         // x4 = y * SCREEN_WIDTH
    add x4, x4, x1         // x4 = (y * SCREEN_WIDTH) + x
    mov x5, #4
    mul x4, x4, x5         // x4 = (y * SCREEN_WIDTH + x) * 4
    add x0, x0, x4
    str w3, [x0]
    ret
    
    // ---------------------------------------------- paint_rectangul?
    // Dibuja un rectángulo rellenado.
draw_rectangle:
    // Salvar registros callee-saved que serán modificados por esta función.
    // Usamos stp (Store Pair) para guardar pares de registros, y str para uno solo.
    // Aquí salvamos x19-x28 (10 registros) y el Link Register (lr).
    stp x19, x20, [sp, #-16]! // Guarda x19, x20 y decrementa SP en 16 bytes.
    stp x21, x22, [sp, #-16]! // Guarda x21, x22 y decrementa SP.
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    str lr, [sp, #-8]!        // Guarda el Link Register.

    // Mueve los argumentos de entrada a registros callee-saved para su uso interno.
    mov x21, x0 // framebuffer_base
    mov x22, x1 // x_start
    mov x23, x2 // y_start
    mov x24, x3 // width
    mov x25, x4 // height
    mov w26, w5 // color (w26 es la parte inferior de x26)

    // Calcula las coordenadas finales (no inclusivas)
    add x27, x23, x25 // y_end = y_start + height
    add x28, x22, x24 // x_end = x_start + width

    
    // Bucle exterior para recorrer las filas (eje Y)
    mov x19, x23 // x19 = y_actual (comienza en y_start)
y_loop_rect:
    cmp x19, x27       // Compara y_actual con y_end
    b.ge y_loop_rect_end // Si y_actual >= y_end, termina el bucle Y.

    // Bucle interior para recorrer las columnas (eje X)
    mov x18, x22 // x18 = x_actual (comienza en x_start)
x_loop_rect:
    cmp x18, x28       // Compara x_actual con x_end
    b.ge x_loop_rect_end // Si x_actual >= x_end, termina el bucle X.

    // Llama a draw_pixel para cada píxel del rectángulo.
    // Argumentos para draw_pixel: x0 (fb_base), x1 (x), x2 (y), w3 (color)
    mov x0, x21 // Pasa framebuffer_base
    mov x1, x18 // Pasa x_actual
    mov x2, x19 // Pasa y_actual
    mov w3, w26 // Pasa el color
    bl draw_pixel // Llama a draw_pixel.

    add x18, x18, #1 // Incrementa x_actual (x++)
    b x_loop_rect    // Salta al inicio del bucle X.

x_loop_rect_end:
    add x19, x19, #1 // Incrementa y_actual (y++)
    b y_loop_rect    // Salta al inicio del bucle Y.

y_loop_rect_end:
    // Restaurar los registros callee-saved en orden inverso al que se guardaron.
    ldr lr, [sp], #8        // Restaura LR y incrementa SP en 8 bytes.
    ldp x27, x28, [sp], #16 // Restaura x27, x28 y incrementa SP en 16 bytes.
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ret // Retorna de la función. 
    
    //----------------------------------------------- end paint_rectangul 

.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32
    
    //----------------------------------------------- graph functions list
    //
    // >>>> ln 16  : upper_half
    //
    // >>>> ln 47  : background_paint
    //
    // >>>> ln 77  : draw_circle
    //
    // >>>> ln 122 : draw_line_hr
    //
    // >>>> ln xxx : draw_pixel
    //
    // >>>> ln xxx : draw_rectangle
    //
    //-------------------------------------------------------------------------

    .global upper_half
    .global background_paint
    .global draw_circle
    .global draw_line_hr
    .global draw_pixel
    .global draw_rectangle

    //----------------------------------------------- upper_half
upper_half:
    sub sp,sp,#32                   // mem alloc
    str lr,[sp]                     // push to sp
    str x1,[sp,#8]                  // push to sp
    str x2,[sp,#16]                 // push to sp
    str x0,[sp,#24]                 // push to sp

    mov x0,x23

    mov x2, SCREEN_HEIGH            // Y Size
    lsr x2,x2,1
loop_uh1: 
	mov x1, SCREEN_WIDTH            // X Size
loop_uh0:
	stur w10,[x0]				     // Colorear el pixel N
	add x0,x0,4                      // Siguiente pixel
	sub x1,x1,1                      // Decrementar contador X
	cbnz x1,loop_uh0                 // Si no terminó la fila, salto
	sub x2,x2,1                      // Decrementar contador Y
	cbnz x2,loop_uh1                 // Si no es la última fila, salto
    
    ldr lr,[sp]                      // pop from sp                
    ldr x1,[sp,#8]                   // pop from sp
    ldr x2,[sp,#16]                  // pop from sp
    ldr x0,[sp,#24]                  // pop from sp
    add sp,sp,#32                    // mem free
    ret
    //----------------------------------------------- end upper_half


    //----------------------------------------------- background_paint
background_paint:
    sub sp,sp,#32                   // mem alloc
    str lr,[sp]                     // push to sp
    str x1,[sp,#8]                  // push to sp
    str x2,[sp,#16]                 // push to sp
    str x0,[sp,#24]                 // push to sp

    mov x0,x23

    mov x2, SCREEN_HEIGH            // Y Size
loop1: 
	mov x1, SCREEN_WIDTH            // X Size
loop0:
	stur w10,[x0]				    // Colorear el pixel N
	add x0,x0,4                     // Siguiente pixel
	sub x1,x1,1                     // Decrementar contador X
	cbnz x1,loop0                   // Si no terminó la fila, salto
	sub x2,x2,1                     // Decrementar contador Y
	cbnz x2,loop1                   // Si no es la última fila, salto
    
    ldr lr,[sp]                     // pop from sp
    ldr x1,[sp,#8]                  // pop from sp
    ldr x2,[sp,#16]                 // pop from sp
    ldr x0,[sp,#24]                 // pop from sp
    add sp,sp,#32                   // mem free
    ret
    //----------------------------------------------- end background_paint


    //----------------------------------------------- draw_circle
draw_circle:
    sub sp,sp,#48                   // mem alloc

    str lr,[sp]                     // push to sp
    str x8,[sp,#8]                  // push to sp
    str x9,[sp,#16]                 // push to sp
    str x1,[sp,#24]                 // push to sp 
    str x2,[sp,#32]                 // push to sp
    str x0,[sp,#40]                 // push to sp 

    mov x0,x23

    mov x2, #0                      // Y = 0
.loop1_crc:  
    cmp x2, SCREEN_HEIGH
    bge .end_draw_circle
    mov x1, #0                      // X = 0
.loop0_crc:
    cmp x1, SCREEN_WIDTH
    bge .end_loop0_crc

    sub x8,x5,x2                    // dist en Y al centro
    sub x9,x6,x1                    // dist en X al centro
    mul x8,x8,x8                    // a^2 -- distancia en Y al cuadrado
    mul x9,x9,x9                    // b^2 -- distancia en X al cuadrado
    add x9,x9,x8                    // a^2 + b^2 -- suma del cuadrado de las distancias
    cmp x9,x7                       // comparo distancias con radio
    b.hi .cont_crc                  // si a^2 + b^2 > r^2 => (a,b) ∉  a la imagen
    stur w10,[x0]                   // Colorear el pixel N
.cont_crc:   
    add x0,x0,4                     // Siguiente pixel
    add x1,x1,1                     // Incrementar X
    b .loop0_crc
.end_loop0_crc:
    add x2,x2,1                     // Incrementar Y
    b .loop1_crc
.end_draw_circle:

    ldr lr,[sp]                     // pop from sp
    ldr x8,[sp,#8]                  // pop from sp
    ldr x9,[sp,#16]                 // pop from sp
    ldr x1,[sp,#24]                 // pop from sp 
    ldr x2,[sp,#32]                 // pop from sp
    ldr x0,[sp,#40]                 // pop from sp 

    add sp,sp,#48                   // free mem
    ret
    //----------------------------------------------- end draw_circle

    //----------------------------------------------- draw_line_hr
draw_line_hr:
    sub sp,sp,#64                       // mem alloc
    str lr,[sp]                         // push to sp
    str x0,[sp,#8]                      // push to sp base FRAME_BUFFER
    str x18,[sp,#24]                    // push to sp altura Y
    str x17,[sp,#32]                    // push to sp auxiliar multiplicacion
    str x22,[sp,#16]                    // push to sp start X
    str x24,[sp,#48]                    // push to sp end X

    mov x22,x16                         // start X -- No modifica x16
    mov x24,x20                         // end X   -- No modifica x20
    mov x18,x15                         // altura Y-- No modifica x15
    mov x0,x23                          // base FRAME_BUFFER

    mov x17,SCREEN_WIDTH                // auxiliar multiplicacion
    mul x18,x18,x17                     // multiplicar Y por SCREEN_WIDTH nos da el primer pixel de la fila Y
    add x18,x18,x22                     // sumar X a Y nos da el pixel (x,y)
    lsl x18,x18,2                       // multiplicamos el resultado por 4 ya que cada pixel son 32bits = 4bytes

    add x0,x0,x18                       // sumamos el resultado a la base de FRAME_BUFFER
    sub x24,x24,x22                     // reutilizamos x24 nuevamente como contador para el ciclo, x24 - x22 = cantidad de px a colorear

loop_line:                              // en el loop se colorean x24 px a partir de x22 en la altura x18
    cbz x24,end_line                    // while x24 != 0
    stur w10,[x0]                       // colorea el base de FRAME_BUFFER
    add x0,x0,4                         // mueve la base de FRAME_BUFFER 1 px
    sub x24,x24,1                       // decrementa el contador
    b loop_line                         // fin loop
end_line:

    ldr lr,[sp]                         // pop from sp
    ldr x0,[sp,#8]                      // pop from sp
    ldr x18,[sp,#24]                    // pop from sp
    ldr x17,[sp,#32]                    // pop from sp
    ldr x22,[sp,#16]                    // pop from sp
    ldr x24,[sp,#48]                    // pop from sp                

    add sp,sp,#64                       // mem free
    ret
    //----------------------------------------------- end paint line_hr

    // ---------------------------------------------- draw_pixel
draw_pixel:
    mov x5, #SCREEN_WIDTH
    mul x4, x2, x5         // x4 = y * SCREEN_WIDTH
    add x4, x4, x1         // x4 = (y * SCREEN_WIDTH) + x
    mov x5, #4
    mul x4, x4, x5         // x4 = (y * SCREEN_WIDTH + x) * 4
    add x0, x0, x4
    str w3, [x0]
    ret

    //----------------------------------------------- end draw_rectangle 
    
    // ---------------------------------------------- draw_rectangle
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
    
    //----------------------------------------------- end draw_rectangle

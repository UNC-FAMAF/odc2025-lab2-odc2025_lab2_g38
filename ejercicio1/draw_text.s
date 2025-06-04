// Este archivo contiene las definiciones de la fuente y las subrutinas
// para dibujar texto en el framebuffer.

// Definiciones de constantes para el tamaño de la pantalla y píxeles
.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

// Definiciones de constantes para el tamaño de los caracteres
.equ CHAR_WIDTH, 5     // Ancho en píxeles de cada carácter
.equ CHAR_HEIGHT, 7    // Alto en píxeles de cada carácter
.equ CHAR_SPACING_X, 2 // Espacio horizontal en píxeles entre caracteres

.data
.align 4 // Asegura que los datos estén alineados a una palabra (4 bytes)

// Bitmaps para cada carácter (5x7 píxeles).
// Cada palabra representa una fila.
// La lógica de dibujo (lsl #2 y tst) espera que el bit más significativo (bit 4)
// corresponda a la columna 0 (más a la izquierda) y el bit menos significativo (bit 0)
// a la columna 4 (más a la derecha) para CHAR_WIDTH = 5.

char_O:
.word 0b01110 // .XXX.
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b01110 // .XXX.

char_d:
.word 0b00001 // ....X
.word 0b00001 // ....X
.word 0b00001 // ....X
.word 0b01111 // .XXXX
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b01111 // .XXXX

char_C:
.word 0b01110 // .XXX.
.word 0b10001 // X...X
.word 0b10000 // X....
.word 0b10000 // X....
.word 0b10000 // X....
.word 0b10001 // X...X
.word 0b01110 // .XXX.

char_space:
.word 0b00000 // .....
.word 0b00000 // .....
.word 0b00000 // .....
.word 0b00000 // .....
.word 0b00000 // .....
.word 0b00000 // .....
.word 0b00000 // .....

char_2:
.word 0b01110 // .XXX.
.word 0b10001 // X...X
.word 0b00001 // ....X
.word 0b01110 // .XXX.
.word 0b10000 // X....
.word 0b10000 // X....
.word 0b11111 // XXXXX

char_0: 
.word 0b01110 // .XXX.
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b10001 // X...X
.word 0b01110 // .XXX.

char_5:
.word 0b11111 // XXXXX
.word 0b10000 // X....
.word 0b10000 // X....
.word 0b01111 // .XXXX
.word 0b00001 // ....X
.word 0b00001 // ....X
.word 0b01110 // .XXX.

.text

.globl draw_char_from_bitmap
draw_char_from_bitmap:
    // Prólogo: Guarda los registros callee-saved (x19-x29, x30/lr) que serán modificados.
    // Se asigna espacio en el stack de 80 bytes para asegurar alineación de 16 bytes.
    stp x29, x30, [sp, #-80]! // Guarda Frame Pointer (x29) y Link Register (x30) [4]
    mov x29, sp               // Establece el nuevo Frame Pointer [5]
    stp x19, x20, [sp, #16]   // Guarda x19, x20 [5]
    stp x21, x22, [sp, #32]   // Guarda x21, x22 [5]
    stp x23, x24, [sp, #48]   // Guarda x23, x24 [5]
    str x25, [sp, #64]        // Guarda x25 [5]

    // Mueve los parámetros de entrada a registros callee-saved para su uso seguro dentro de la subrutina.
    mov x19, x0 // x_start
    mov x20, x1 // y_start
    mov w21, w2 // color
    mov x22, x3 // framebuffer_base_address
    mov x23, x4 // bitmap_address (puntero al bitmap del carácter)

    // Define constantes para el cálculo de la dirección del píxel en el framebuffer.
    mov x24, #SCREEN_WIDTH // Ancho de la pantalla en píxeles (640)
    mov x25, #4            // Bytes por píxel (32 bits = 4 bytes)

    mov x4, #0 // Inicializa row_idx = 0 (contador de filas para el carácter)

row_loop_char:
    cmp x4, #CHAR_HEIGHT // Compara row_idx con la altura del carácter
    bge end_draw_char    // Si row_idx >= CHAR_HEIGHT, termina el bucle de filas

    // Carga la "palabra" (word) que representa el bitmap de la fila actual.
    // Como cada fila es un `.word` (4 bytes), el offset se calcula como `row_idx * 4`.
    // `LSL #2` es equivalente a multiplicar por 4 
    ldr w6, [x23, x4, LSL #2] // w6 = bitmap de la fila actual del carácter

    mov x5, #0 // Inicializa col_idx = 0 (contador de columnas para el carácter) 

col_loop_char:
    cmp x5, #CHAR_WIDTH // Compara col_idx con el ancho del carácter 
    bge end_col_loop_char // Si col_idx >= CHAR_WIDTH, termina el bucle de columnas 

    // Comprueba si el píxel actual en el bitmap de la fila debe ser dibujado.
    // La lógica de los bitmaps usa bits desde la posición 0 (LSB) hasta 4 (MSB) para un ancho de 5.
    // Para dibujar de izquierda a derecha (col_idx 0 a 4), necesitamos verificar el bit en la posición `(CHAR_WIDTH - 1) - col_idx`.
    // Por ejemplo: col_idx=0 -> bit 4 (MSB), col_idx=1 -> bit 3, etc.
    mov x7, #CHAR_WIDTH // x7 = 5
    sub x7, x7, #1      // x7 = 4 (CHAR_WIDTH - 1)
    sub x7, x7, x5      // x7 = (CHAR_WIDTH - 1) - col_idx, que es la posición del bit a verificar 

    mov x8, #1          // Inicializa x8 a 1 para crear la máscara de bit 
    lsl x8, x8, x7      // Desplaza '1' a la izquierda por `x7` bits para obtener la máscara para el bit deseado

    tst w6, w8          // Realiza un AND bit a bit entre el bitmap de la fila (w6) y la máscara (w8).
                        // Esto actualiza los flags N y Z [9, 10].
    beq next_pixel_skip_char // Si el resultado es cero (bit no establecido), salta a `next_pixel_skip_char`

    // Si el bit está establecido, calcula la dirección del píxel en el framebuffer.
    // Fórmula: Dirección = Dirección de inicio + 4 * [x + (y * SCREEN_WIDTH)]
    add x9, x19, x5     // current_x = x_start + col_idx (coordenada X absoluta del píxel) 
    add x10, x20, x4    // current_y = y_start + row_idx (coordenada Y absoluta del píxel) 

    mul x11, x10, x24   // x11 = current_y * SCREEN_WIDTH (píxeles) 
    add x11, x11, x9    // x11 = (current_y * SCREEN_WIDTH) + current_x (índice lineal del píxel) 
    mul x11, x11, x25   // x11 = índice lineal * 4 (para obtener el offset en bytes)
    add x11, x22, x11   // pixel_address = framebuffer_base_address + offset_en_bytes 

    // Almacena el color en la dirección calculada del píxel en el framebuffer.
    str w21, [x11] // Almacena el color de 32 bits (w21) en la dirección del píxel 

next_pixel_skip_char:
    add x5, x5, #1 // Incrementa col_idx (pasa a la siguiente columna) 
    b col_loop_char  // Vuelve al inicio del bucle de columnas 

end_col_loop_char:
    add x4, x4, #1 // Incrementa row_idx (pasa a la siguiente fila) 
    b row_loop_char  // Vuelve al inicio del bucle de filas

end_draw_char:
    // Epílogo: Restaura los registros callee-saved en el orden inverso al que se guardaron.
    ldr x25, [sp, #64]        // Restaura x25 (Corregido: el original referenciaba x26)
    ldp x23, x24, [sp, #48]   // Restaura x23, x24 
    ldp x21, x22, [sp, #32]   // Restaura x21, x22 
    ldp x19, x20, [sp, #16]   // Restaura x19, x20 
    ldp x29, x30, [sp], #80  // Restaura Frame Pointer y Link Register, y ajusta el SP 
    ret                       // Retorna de la subrutina. 


// Subrutina para dibujar la frase "OdC 2025"
// Parámetros:
// x0: x_start (coordenada X inicial para la primera letra de la frase)
// x1: y_start (coordenada Y para la frase)
// w2: color (color ARGB de 32 bits)
// x3: framebuffer_base_address (dirección base del framebuffer)
.globl draw_string_OdC2025
draw_string_OdC2025:
    // Prólogo: Guarda los registros callee-saved (x19-x29, x30/lr) que serán modificados.
    stp x29, x30, [sp, #-80]! // Guarda Frame Pointer y Link Register
    mov x29, sp               // Establece el nuevo Frame Pointer
    stp x19, x20, [sp, #16]   // Guarda x19, x20
    stp x21, x22, [sp, #32]   // Guarda x21, x22
    stp x23, x24, [sp, #48]   // Guarda x23, x24
    str x25, [sp, #64]        // Guarda x25

    // Mueve los parámetros de entrada a registros callee-saved.
    mov x19, x0 // x_start inicial para la frase
    mov x20, x1 // y_start para la frase
    mov w21, w2 // color
    mov x22, x3 // framebuffer_base_address

    mov x23, x19 // x23 mantendrá la posición X actual para el dibujo del carácter

    // Dibuja el carácter 'O'
    mov x0, x23             // Pasa la x_start actual
    mov x1, x20             // Pasa la y_start
    mov w2, w21             // Pasa el color
    mov x3, x22             // Pasa la dirección base del framebuffer
    adr x4, char_O          // Pasa la dirección del bitmap para 'O'
    bl draw_char_from_bitmap // Llama a la función genérica de dibujo de carácter
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X // Avanza la posición X para el siguiente carácter

    // Dibuja el carácter 'd'
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_d
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el carácter 'C'
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_C
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el espacio ' '
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_space
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el dígito '2' (primero)
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_2
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el dígito '0'
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_0
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el dígito '2' (segundo)
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_2
    bl draw_char_from_bitmap
    add x23, x23, #CHAR_WIDTH + CHAR_SPACING_X

    // Dibuja el dígito '5'
    mov x0, x23
    mov x1, x20
    mov w2, w21
    mov x3, x22
    adr x4, char_5
    bl draw_char_from_bitmap
    // No es necesario avanzar x_position después del último carácter

    // Epílogo: Restaura los registros callee-saved en el orden inverso.
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret // Retorna de la subrutina.

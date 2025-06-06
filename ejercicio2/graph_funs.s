// Funciones gráficas de bajo nivel.

// Definiciones de constantes de la pantalla
.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGHT, 480
.equ PIXEL_SIZE, 4 // Cada píxel es de 32 bits (4 bytes) [4]

.text
.globl draw_pixel // Declara draw_pixel como global para ser llamada desde otros archivos.

// draw_pixel(framebuffer_base (x0), x (x1), y (x2), color (w3))
// Dibuja un píxel individual en la pantalla.
draw_pixel:
    mov x5, #SCREEN_WIDTH
    mul x4, x2, x5         // x4 = y * SCREEN_WIDTH
    add x4, x4, x1         // x4 = (y * SCREEN_WIDTH) + x
    mov x5, #PIXEL_SIZE
    mul x4, x4, x5         // x4 = (y * SCREEN_WIDTH + x) * 4
    add x0, x0, x4
    str w3, [x0]
    ret

.include "object_graph_funs.s"

.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE, 0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0, 0x34

.extern draw_rectangle
.extern draw_string_OdC2025

.globl main

main:
    // x0 contiene la direccion base del framebuffer
    mov x20, x0 // Guarda la dirección base del framebuffer en x20 

    // Pinta el dibujo usando object_graph_funs
    mov x23, x20      // x23 debe contener la base del framebuffer según tus rutinas
    bl paint_sky_night						//	definicion en "object_graph_funs.s" pinta el fondo de naranja-oscuro con algunas rayas
	bl paint_moon							//	definicion en "object_graph_funs.s" pinta la luna
	bl fore_ground							//	definicion en "object_graph_funs.s" pinta las lomas
	bl paint_casita							//	definicion en "object_graph_funs.s" pinta la casita
    
    //---------------- CODE FOR "OdC 2025" TEXT --------------------
    // Llama a la subrutina para dibujar la frase "OdC 2025".
    // x0: x_start
    // x1: y_start
    // w2: color (32-bit ARGB)
    // x3: framebuffer_base_address (x20)

    mov x0, #300 // x_start para la frase
    mov x1, #400 // y_start para la frase
    mov w2, #0xFF00FF00 // color = Verde (Alpha=FF, Rojo=00, Verde=FF, Azul=00)
    mov x3, x23 // framebuffer_base_address
    bl draw_string_OdC2025 // Llama a la nueva subrutina para dibujar la frase "OdC 2025"

    // ---------------- END OF TEXT CODE ----------------------------

	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w10, [x9, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10
	and w11, w10, 0b10

	// w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
	// efectivamente, su valor representará si GPIO 2 está activo
	lsr w11, w11, 1

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
    
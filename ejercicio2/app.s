	.equ SCREEN_WIDTH, 		640
	.equ SCREEN_HEIGH, 		480
	.equ BITS_PER_PIXEL,  	32

  	.equ COLOR_YELLOW, 0xFFFF00

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
 	mov x20, x0	// Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	movz x10, 0xC7, lsl 16
	movk x10, 0x1585, lsl 00

	mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]  // Colorear el pixel N
	add x0,x0,4	   // Siguiente pixel
	sub x1,x1,1	   // Decrementar contador X
	cbnz x1,loop0  // Si no terminó la fila, salto
	sub x2,x2,1	   // Decrementar contador Y
	cbnz x2,loop1  // Si no es la última fila, salto

 	// Dibujar la inscripción "OdC 2025" 
	// Se dibuja en una posición fija (parte superior izquierda) con un color amarillo.
	mov x0, x20             // Framebuffer base
	mov x1, #10             // Posición X
	mov x2, #10             // Posición Y
	mov w3, #COLOR_YELLOW   // Color del texto
	bl draw_odc2025         // Llama a la función de draw_text.s.

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop

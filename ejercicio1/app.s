	.equ SCREEN_WIDTH, 		640
	.equ SCREEN_HEIGH, 		480
	.equ BITS_PER_PIXEL,  	32

	.equ GPIO_BASE,      0x3f200000
	.equ GPIO_GPFSEL0,   0x00
	.equ GPIO_GPLEV0,    0x34

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
 	mov x23, x0	// Guarda la dirección base del framebuffer en x23
	//---------------- CODE HERE ------------------------------------

	// Pinta el cielo de día
	bl		paint_sky_day

	// Pinta el sol
	bl		paint_sun

	// Pinta las lomas/terreno
	bl		fore_ground

	// Pinta la casita
	bl		paint_casita

	// ── 2) DIBUJAR INSCRIPCIÓN “OdC 2025” ────────────────────────────────
	bl		draw_text_OdC2025

	// ── 3) BUCLE INFINITO PARA MANTENER LA IMAGEN ────────────────────────
	b		InfLoop

InfLoop:
	b		InfLoop

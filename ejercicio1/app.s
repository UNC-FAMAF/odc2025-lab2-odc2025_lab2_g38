.include "object_graph_funs.s"

.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ BITS_PER_PIXEL, 32

.extern draw_rectangle
.extern draw_odc2025

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
    // Llama a la subrutina para dibujar la frase "OdC 2025"

    mov x0, x23             // Framebuffer base
    mov x1, #50             // Posición X
    mov x2, #400             // Posición Y
    movz w3, #0xFF, lsl 16
    movk w3, #0x6666, lsl 00   // Color del texto
    bl draw_odc2025         // Llama a la función de draw_text.s.

    // ---------------- END OF TEXT CODE ---------------------------
	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
    

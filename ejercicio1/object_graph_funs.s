.include "graph_funs.s"
    .equ SCREEN_WIDTH,   640
    .equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32

    //----------------------------------------------- paint_moon
    //
    //  pinta una luna de color amarillo 
    //
paint_moon:
    sub sp,sp,#48                   // mem alloc
    str lr,[sp]                     // push to sp
    str x5,[sp,#8]                  // push to sp
    str x6,[sp,#16]                 // push to sp
    str x7,[sp,#24]                 // push to sp
    str x8,[sp,#32]                 // push to sp
    str x10,[sp,#40]                // push to sp

    // CIRCULOS LUNA

    movz x10,#0xFA,lsl 16         //color
    movk x10,#0xF328                //color

    mov x5,400                      // Y
    mov x6,550                      // X

    mov x8,80                       // r
    mul x7,x8,x8                    // r^2

    bl paint_circle

    movz x10,#0xFC,lsl 16         //color
    movk x10,#0xF760                //color

    sub x8,x8,5                     // disminuyo radio
    mul x7,x8,x8                    // r^2

    bl paint_circle

    movz x10,#0xF5,lsl 16         //color
    movk x10,#0xF17C                //color

    sub x8,x8,20                    // disminuyo radio
    mul x7,x8,x8                    // r^2

    bl paint_circle

    ldr lr,[sp]                     // pop from sp
    ldr x5,[sp,#8]                  // pop from sp
    ldr x6,[sp,#16]                 // pop from sp
    ldr x7,[sp,#24]                 // pop from sp
    ldr x8,[sp,#32]                 // pop from sp
    ldr x10,[sp,#40]                // pop from sp

    add sp,sp,#48                   // mem free
    ret
    //----------------------------------------------- end paint_moon


    //----------------------------------------------- paint_sky_night
    //
    //  pinta el cielo de azules
    //
paint_sky_night:
    sub sp,sp,#64                               // alloc mem
    str lr,[sp]                                 // push to sp
    str x16,[sp,#8]                             // push to sp
    str x20,[sp,#16]                            // push to sp
    str x10,[sp,#24]                            // push to sp
    str x11,[sp,#32]                            // push to sp
    str x15,[sp,#40]                            // push to sp
    

    movz w10,#0x17,lsl 16                     //
    movk w10,#0x0972                            //

    bl background_paint                         //

    movz w10,#0x15,lsl 16                     //
    movk w10,#0x0869                            //

    bl upper_half                               //

    movz w10,#0x0E,lsl 16                     //
    movk w10,#0x054A                            //

    mov x16,0                                   //
	mov x20,640                                 //
    mov x15,240                                 //                    
    mov x11,0                                   //                

loop_hor_lines_n:                               //
    cbz x15, end_hor_line_n                     //
    bl paint_line_hr                            //
    sub x15,x15,1                               //
    bl paint_line_hr                            //
    sub x15,x15,1                               //
    bl paint_line_hr                            //
    sub x15,x15,x11                             //
    add x11,x11,2                               //
    b loop_hor_lines_n                          //

end_hor_line_n:                                 //

    ldr lr,[sp]                                 // pop from sp
    ldr x8,[sp,#8]                              // pop from sp
    ldr x9,[sp,#16]                             // pop from sp
    ldr x11,[sp,#24]                            // pop from sp
    ldr x10,[sp,#32]                            // pop from sp
    ldr x12,[sp,#40]                            // pop from sp

    add sp,sp,#64                               // mem free
    ret
    //----------------------------------------------- end paint_sky_night


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



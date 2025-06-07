.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGH,   480
.equ BITS_PER_PIXEL, 32

.extern upper_half
.extern background_paint
.extern draw_circle
.extern draw_line_hr
.extern draw_pixel
.extern draw_rectangle

.global paint_sky_night
.global paint_moon
.global fore_ground
.global paint_casita
.global restore_background_at

    //----------------------------------------------- paint_moon
    // paint_moon espera en x5 (Y centro) y x6 (X centro) la posición de la luna
paint_moon:
    sub sp,sp,#48
    str lr,[sp]
    str x5,[sp,#8]
    str x6,[sp,#16]
    str x7,[sp,#24]
    str x8,[sp,#32]
    str x10,[sp,#40]

    // Dibuja la luna (círculo blanco) en (x6, x5)
    mov x8,80
    mul x7,x8,x8
    movz w10,#0xFFFF
    movk w10,#0xFFFF, lsl 16
    bl draw_circle

    // Cráter 1 (gris claro)
    sub x5,x5,30         // Y = centroY - 30
    add x6,x6,20         // X = centroX + 20
    mov x8,18
    mul x7,x8,x8
    movz w10,#0xCCCC
    movk w10,#0xCCCC, lsl 16
    bl draw_circle

    // Cráter 2 (gris medio)
    add x5,x5,50         // Y = centroY + 20
    sub x6,x6,30         // X = centroX - 10
    mov x8,12
    mul x7,x8,x8
    movz w10,#0xAAAA
    movk w10,#0xAAAA, lsl 16
    bl draw_circle

    // Cráter 3 (gris oscuro)
    sub x5,x5,30         // Y = centroY - 10
    sub x6,x6,10         // X = centroX - 20
    mov x8,10
    mul x7,x8,x8
    movz w10,#0x8888
    movk w10,#0x8888, lsl 16
    bl draw_circle

    // Cráter 4 (gris muy claro)
    add x5,x5,20         // Y = centroY + 10
    add x6,x6,50         // X = centroX + 30
    mov x8,8
    mul x7,x8,x8
    movz w10,#0xEEEE
    movk w10,#0xEEEE, lsl 16
    bl draw_circle

    ldr lr,[sp]
    ldr x5,[sp,#8]
    ldr x6,[sp,#16]
    ldr x7,[sp,#24]
    ldr x8,[sp,#32]
    ldr x10,[sp,#40]
    add sp,sp,#48
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
    bl draw_line_hr                            //
    sub x15,x15,1                               //
    bl draw_line_hr                            //
    sub x15,x15,1                               //
    bl draw_line_hr                            //
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

    //----------------------------------------------- paint fore_ground
    //
    //  en base a line_hr se colorean progresivamente lineas para formar el terreno
    //
fore_ground:
    sub sp,sp,#64                               // mem alloc

    str lr,[sp]                                 // push to sp 
    str x10,[sp,#8]                             // push to sp 
    str x8,[sp,#16]                             // push to sp 
    str x9,[sp,#24]                             // push to sp 
    str x15,[sp,#32]                            // push to sp
    str x16,[sp,#40]                            // push to sp color 
    str x20,[sp,#80]                            // push to sp 


    movz w10, #0x0026,lsl 16                    // color
    movk w10, #0x5430                           // --


    mov x16,600                                 // movemos a x16(start X) el valor 600
    mov x20,640                                 // movemos a x20(end X)   el valor 640
    mov x15,270                                 // movemos Y1 a x15(altura de linea)

    mov x8,6                                    // contador filas
    mov x9,70                                   // offset inicial start X

loop_fore_ground_0:
    cmp x15,480                                 // while x15 != ultima fila
    b.eq det_lines_R                            // si x15 == 480 fin loop
    bl draw_line_hr                            // colorea linea
    add x15,x15,1                               // siguiente fila
    sub x8,x8,1                                 // decrementa contador filas
    cbnz x8,loop_fore_ground_0                  // while x8 != vuelvo al inicio
    mov x8,6                                    // reinicio contador filas
    sub x16,x16,x9                              // restamos el offset a start X
    cmp x9,0                                    //  --
    b.le loop_fore_ground_0                     // si el offset es <= 0 no lo seguimos reduciendo
    sub x9,x9,4                                 // reducimos el offset
    b loop_fore_ground_0                        // fin loop

det_lines_R:                                    // pinta lineas de color distinto para gregar detalle

    mov x16,600                                 // movemos a x16(start X) el valor 600
    mov x20,640                                 // movemos a x20(end X)   el valor 640
    mov x15,270                                 // movemos Y1 a x15(altura de linea)

    movz w10, #0x0038,lsl 16                    //  cambio color
    movk w10, #0x7144                           //  --

    mov x8,6                                    // contador filas
    mov x9,70                                   // offset inicial start X

det_lines_0:                                    // idem loop anterior, que colorea una linea cada x8
    cmp x15,480                                 //  --  
    b.eq cont_foreground                        //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --  
    cbnz x8,det_lines_0                         //  --  
    bl draw_line_hr                            //  -- 
    mov x8,6                                    //  --  
    sub x16,x16,x9                              //  --  
    cmp x9,0                                    //  --
    b.le det_lines_0                            //  -- 
    sub x9,x9,4                                 //  -- 
    b det_lines_0                               //  -- 

cont_foreground:

    movz w10, #0x0038,lsl 16                    // cambio color
    movk w10, #0x7144                           //  --

    mov x16,0                                   // movemos a x16(start X) el valor 0
    mov x20,2                                   // movemos a x20(end X)   el valor 2
    mov x15,280                                 // movemos Y1 a x15(altura de linea)

    mov x8,5                                    // contador filas
    mov x9,60                                   // offset inicial start X

loop_fore_ground_1:                             // idem loop_fore_ground_0
    cmp x15,480                                 //  --
    b.eq det_lines_L                            //  --
    bl draw_line_hr                            //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --
    cbnz x8,loop_fore_ground_1                  //  --
    mov x8,5                                    //  --
    add x20,x20,x9                              //  --
    cmp x9,0                                    //  --
    b.le loop_fore_ground_1                     //  --
    sub x9,x9,2                                 // cambia el factor de reduccion
    b loop_fore_ground_1                        //  --

det_lines_L:                                    // idem det_lines_R

    mov x16,600                                 // movemos a x16(start X) el valor 600
    mov x20,640                                 // movemos a x20(end X)   el valor 640
    mov x15,270                                 // movemos Y1 a x15(altura de linea)

    movz w10, #0x0026,lsl 16                    // color
    movk w10, #0x5430                           //  --

    mov x8,6                                    // contador filas
    mov x9,70                                   // offset inicial start X

det_lines_1:                                    // idem det_lines_0
    cmp x15,480                                 //  --
    b.eq end_foreground                         //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --
    cbnz x8,det_lines_1                         //  --
    bl draw_line_hr                            //  --
    mov x8,6                                    //  --
    add x20,x20,x9                              //  --
    cmp x9,0                                    //  --
    b.le det_lines_1                            //  --
    sub x9,x9,2                                 //  --
    b det_lines_1                               //  --

end_foreground:
    ldr lr,[sp]                                 // pop from sp
    ldr x10,[sp,#8]                             // pop from sp                             
    ldr x8,[sp,#16]                             // pop from sp                             
    ldr x9,[sp,#24]                             // pop from sp                             
    ldr x15,[sp,#32]                            // pop from sp                             
    ldr x16,[sp,#40]                            // pop from sp                             
    ldr x20,[sp,#48]                            // pop from sp                             

    add sp,sp,#64                               // free mem
    ret
    //----------------------------------------------- end paint_fore_ground

    //----------------------------------------------- paint_casita
paint_casita:
    sub sp,sp,#40
    str lr,[sp]                                     // push to sp
    str x10,[sp,#8]                                 // push to sp
    str x15,[sp,#16]                                // push to sp
    str x16,[sp,#24]                                // push to sp
    str x20,[sp,#32]                                // push to sp

    mov x16,500                                     // start_line X
    mov x20,580                                     // end_line X
    mov x15,260                                     // altura inicial Y

    movz w10,#0x00bb,lsl 16                         //
    movk w10,#0x9766                                //

loop_casita_princ:                                  //
    cmp x15,300                                     //
    b.eq end_casita_princ                           //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_princ                             //
end_casita_princ:                                   //

    movz w10,#0x0095,lsl 16                         //
    movk w10,#0x7850                                //

    mov x16,480                                     // start_line X
    mov x20,500                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_front:                                  //
    cmp x15,300                                     //
    b.eq end_casita_front                           //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_front                             //

end_casita_front:                                   //

    movz w10,#0x0097,lsl 16                         //
    movk w10,#0x641f                                //

    mov x16,485                                     // start_line X
    mov x20,495                                     // end_line X
    mov x15,280                                     // altura inicial Y

loop_casita_puerta:                                 //
    cmp x15,300                                     //
    b.eq end_casita_puerta                          //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_puerta                            //

end_casita_puerta:                                  //

    movz w10,#0x00ff,lsl 16                         //
    movk w10,#0xffff                                //

    mov x16,510                                     // start_line X
    mov x20,530                                     // end_line X
    mov x15,275                                     // altura inicial Y

loop_casita_ventana_0:                              //
    cmp x15,295                                     //
    b.eq end_casita_ventana_0                       //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_ventana_0                         //

end_casita_ventana_0:                               //

    mov x16,550                                     // start_line X
    mov x20,570                                     // end_line X
    mov x15,275                                     // altura inicial Y

loop_casita_ventana_1:                              //
    cmp x15,295                                     //
    b.eq end_casita_ventana_1                       //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_ventana_1                         //

end_casita_ventana_1:                               //

    movz w10,#0x005a,lsl 16                         //
    movk w10,#0x1f15                                //

    mov x16,480                                     // start_line X
    mov x20,500                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_techo_back:                             //
    cmp x15,260                                     //
    b.eq end_casita_techo_back                      //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    sub x16,x16,1                                   //
    sub x20,x20,1                                   //
    b loop_casita_techo_back                        //

end_casita_techo_back:                              //

    movz w10,#0x0097,lsl 16                         //
    movk w10,#0x2f1f                                //

    mov x16,480                                     // start_line X
    mov x20,580                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_techo_princ:                            //
    cmp x15,260                                     //
    b.eq end_casita_techo_princ                     //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    add x16,x16,1                                   //
    add x20,x20,1                                   //
    b loop_casita_techo_princ                       //

end_casita_techo_princ:                             //

    mov x16,560                                     // start_line X
    mov x20,570                                     // end_line X
    mov x15,225                                     // altura inicial Y

    movz w10,#0x0050,lsl 16                         //
    movk w10,#0x4645                                //

loop_casita_chim:                                   //
    cmp x15,250                                     //
    b.eq end_casita_chim                            //
    bl draw_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_chim                              //

end_casita_chim:                                    //

    ldr lr,[sp]                                     //
    ldr x10,[sp,#8]                                 //
    ldr x15,[sp,#16]                                //
    ldr x16,[sp,#24]                                //
    ldr x20,[sp,#32]                                //

    add sp,sp,#40                                   //
    ret
    //----------------------------------------------- end paint_casita


// x5 = y centro, x6 = x centro
restore_background_at:
    sub sp, sp, #16
    str lr, [sp]
    str x10, [sp, #8]

    // Color sólido del cielo (ajusta si tu color de fondo cambia)
    movz w10, #0x17, lsl 16
    movk w10, #0x0972

    // Dibuja un círculo del color del cielo en la posición de la luna anterior
    mov x8, 80
    mul x7, x8, x8
    bl draw_circle

    ldr lr, [sp]
    ldr x10, [sp, #8]
    add sp, sp, #16
    ret

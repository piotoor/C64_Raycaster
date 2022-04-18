*=$1000

ray_start=$C000
ray_end=$C040

screen_width=#40
screen_height=#25
square_size=#16
map_width=#16
map_height=#16

incasm  utils.asm


;;---------------------------------------------
;; main
;;---------------------------------------------
main           
                jsr setup
                jsr game_loop
                rts
   
;;---------------------------------------------
;; setup
;;---------------------------------------------             
setup
                lda #$d8
                sta A_16_H
                lda #$00
                sta A_16_L
                jsr init_screen
                rts

;;---------------------------------------------
;; init_screen
;;---------------------------------------------
init_screen     
                ldx #0 ;{
loop                    lda #$A0

                        sta $0400,x
                        sta $0500,x
                        sta $0600,x
                        sta $06e8,x                        
                       
                        inx
                        bne loop        ; x != 0
                ;}
                rts

;;---------------------------------------------
;; compute_frame
;;---------------------------------------------
compute_frame
                ldx #0 ;{
@h                      lda screen_height  
                        sec
                        sbc heights,x
                        lsr a
                        sta ray_start,x
                        clc
                        adc heights,x
                        sta ray_end,x
                        clc
                        inx
                        cpx screen_width
                        bne @h
                ;}
                ldx #0 ;{
                rts


;;---------------------------------------------
;; draw_frame
;;---------------------------------------------
draw_frame      
@rows
                        ldy #0 ;{
@cols
                                clc
                                txa
                                cmp ray_start,y
                                bcs @x_ge_ray_start
                                lda #0
                                jmp @draw
@x_ge_ray_start                 clc
                                cmp ray_end,y
                                lda color,y
                                bcc @draw
                                lda #0
                        
@draw                           sta (A_16),y

                                iny
                                cpy screen_width
                                bne @cols
                        ;}

                        lda A_16_L
                        clc
                        adc #$28
                        sta A_16_L
                        lda A_16_H
                        adc #0
                        sta A_16_H

                        inx
                        cpx screen_height
                        bne @rows
                ;}
                rts

;;---------------------------------------------
;; game_loop
;;---------------------------------------------
game_loop
                jsr compute_frame
                jsr draw_frame
                jmp game_loop

                rts

game_map        byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                byte 1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1
                byte 1,1,1,0,1,1,0,1,1,1,1,1,0,0,0,1
                byte 1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1
                byte 1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1
                byte 1,1,1,0,1,1,1,0,1,1,1,1,1,1,0,1
                byte 1,0,0,0,0,0,1,0,1,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,1,0,1,0,1,0,1,1,0,1
                byte 1,0,0,0,0,0,1,0,1,0,1,0,0,1,1,1
                byte 1,0,0,0,0,0,1,0,1,0,1,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
                byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

heights         byte 10,10,10,10,12,13,14,16,17,19,20,21,20,19,19,19,19,19,19,18,18,17,17,17,16,16,16,15,15,9,9,9,10,10,10,11,11,11,12,11
color           byte 8,8,8,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,8

incasm          lookuptables.asm
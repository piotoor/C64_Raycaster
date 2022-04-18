*=$1000

ray_start=$C000
ray_end=$C040
screen_width=#40
screen_height=#25

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
                sta $fc
                lda #$00
                sta $fb
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
                        
@draw                           sta ($fb),y

                                iny
                                cpy screen_width
                                bne @cols
                        ;}

                        lda $fb
                        clc
                        adc #$28
                        sta $fb
                        lda $fc
                        adc #0
                        sta $fc

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

heights byte 10,10,10,10,12,13,14,16,17,19,20,21,20,19,19,19,19,19,19,18,18,17,17,17,16,16,16,15,15,9,9,9,10,10,10,11,11,11,12,11
color byte 8,8,8,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,8
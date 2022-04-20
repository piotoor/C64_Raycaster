*=$1000

screen_width=#40
screen_height=#25
half_fov=#20

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
                sta F_16_H
                lda #$00
                sta F_16_L
                jsr player_setup
                jsr init_screen
                rts

;;---------------------------------------------
;; player_setup
;;---------------------------------------------             
player_setup
                lda #$6a
                sta posX
                lda #$85
                sta posY
                lda #0
                sta theta
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
                ldx #0
@loop           txa
                pha

                sta ray_id
                lda theta
                sec
                sbc half_fov
                adc ray_id
                sta rayTheta

                jsr init_ray_params
                jsr cast_ray
                jsr compute_line

                pla
                tax
                inx
                cpx screen_width
                bne @loop
                
                rts


;;---------------------------------------------
;; draw_frame
;;---------------------------------------------
draw_frame      
                lda #$00
                sta F_16_L
                lda #$d8
                sta F_16_H
                ldx #0 ;{
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
                                lda ray_color,y
                                bcc @draw
                                lda #0
                        
@draw                           sta (F_16),y

                                iny
                                cpy screen_width
                                bne @cols
                        ;}

                        lda F_16_L
                        clc
                        adc #$28
                        sta F_16_L
                        lda F_16_H
                        adc #0
                        sta F_16_H

                        inx
                        cpx screen_height
                        bne @rows
                ;}
                rts

;;---------------------------------------------
;; game_loop
;;---------------------------------------------
game_loop
                lda theta
                adc #4
                sta theta
                jsr compute_frame
                jsr draw_frame
                jmp game_loop

                rts


incasm  utils.asm
incasm  lookuptables.asm
incasm  gameMap.asm
incasm  player.asm
incasm  ray.asm
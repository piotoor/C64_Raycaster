*=$1000

ray_start=$C000
ray_end=$C040
screen_width=#40
screen_height=#25

main            lda #$d8
                sta $fc
                lda #$00
                sta $fb

                ldx #0
                jsr init_screen
                ;jsr ompute_lines
                jsr draw_lines
                
                jmp *
                rts
                

init_screen     lda #$A0        ; spacebar ascii
                sta $0400,x     ; fill 4 areas with space
                sta $0500,x
                sta $0600,x
                sta $06e8,x                        
                
                lda #9
                sta $0d800,x
                sta $0d900,x
                sta $0da00,x
                sta $0dae8,x

                inx
                bne init_screen       ; x == 0
                rts

;;---------------------------------------------
;; draw frame
;;---------------------------------------------
draw_lines      clc
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

                ldx #0
@rows

                ldy #0
@cols
                clc
                txa
                cmp ray_start,y
                bcs @x_ge_ray_start
                lda #0
                jmp @draw
@x_ge_ray_start  clc
                cmp ray_end,y
                lda color,y
                bcc @draw
                lda #0
                
@draw            sta ($fb),y


                iny
                cpy screen_width
                bne @cols

                        
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
                rts
;;---------------------------------------------


heights byte 10,10,10,10,12,13,14,16,17,19,20,21,20,19,19,19,19,19,19,18,18,17,17,17,16,16,16,15,15,9,9,9,10,10,10,11,11,11,12,11
color byte 8,8,8,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,8
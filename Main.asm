*=$1000

screen_width=#40
screen_height=#25
half_fov=#20
pra=$dc00     ; CIA#1 (Port Register A)
prb=$dc01     ; CIA#1 (Port Register B)
ddra=$dc02     ; CIA#1 (Data Direction Register A)
ddrb=$dc03     ; CIA#1 (Data Direction Register B)

;;---------------------------------------------
;; main
;;---------------------------------------------
main           
                jsr setup
                jmp *       ; infinite loop
                
;;---------------------------------------------
;; irq
;;---------------------------------------------
irq             dec $d019               ; acknowledge IRQ / clear register for next interrupt
                jsr check_keyboard 
                jsr compute_frame
                jsr draw_frame
                jmp $ea31               ; kernel irq routine

;;---------------------------------------------
;; check_keyboard
;;---------------------------------------------
check_keyboard  lda #%11111111  ; CIA#1 Port A set to output 
                sta ddra             
                lda #%00000000  ; CIA#1 Port B set to input
                sta ddrb 
                
d_pressed       lda #%11111011
                sta pra
                lda prb
                and #%00000100  
                beq rotate_right

a_pressed       lda #%11111101
                sta pra
                lda prb
                and #%00000100
                beq rotate_left

w_pressed       lda #%11111101
                sta pra
                lda prb
                and #%00000010
                beq move_forward

s_pressed       lda #%11111101
                sta pra
                lda prb
                and #%00100000
                beq move_back
                rts

;;---------------------------------------------
;; rotate_right
;;---------------------------------------------
rotate_right    lda theta
                adc #6
                sta theta
                rts

;;---------------------------------------------
;; rotate_left
;;---------------------------------------------
rotate_left     lda theta
                sec
                sbc #6
                sta theta
                rts

;;---------------------------------------------
;; move_forward
;;---------------------------------------------
move_forward    ldx theta
                ldy reducedTheta,x
                lda cosX16,y
                lsr ; TODO add speed
                sta stepX

                ldy mirrorReducedTheta,x
                lda cosX16,y
                lsr ; TODO add speed
                sta stepY

                ldx theta
                ldy xPlusTheta,x
                bne @x_end
@x_minus        lda stepX
                eor #$ff
                adc #1
                sta stepX
@x_end          ldy yPlusTheta,x
                bne @y_end
@y_minus        lda stepY
                eor #$ff
                adc #1
                sta stepY

@y_end          
                lda posX
                adc stepX
                sta posX
                
                lda posY
                adc stepY
                sta posY

                lsr
                lsr
                lsr
                lsr
                sta mapY
                lda posX
                lsr
                lsr
                lsr
                lsr
                sta mapX

                lda mapY 
                asl
                asl
                asl
                asl
                clc
                adc mapX
                tax
                lda game_map,x
                beq @end
                lda posX
                sec
                sbc stepX
                sta posX
                lda posY
                sec
                sbc stepY
                sta posY
@end
                rts

;;---------------------------------------------
;; move_back
;;---------------------------------------------
move_back       ldx theta
                ldy reducedTheta,x
                lda cosX16,y
                lsr ; TODO add speed
                sta stepX

                ldy mirrorReducedTheta,x
                lda cosX16,y
                lsr ; TODO add speed
                sta stepY

                ldx theta
                ldy xPlusTheta,x
                beq @x_end
@x_plus         lda stepX
                eor #$ff
                adc #1
                sta stepX
@x_end          ldy yPlusTheta,x
                beq @y_end
@y_plus         lda stepY
                eor #$ff
                adc #1
                sta stepY

@y_end          
                lda posX
                adc stepX
                sta posX
                
                lda posY
                adc stepY
                sta posY

                lsr
                lsr
                lsr
                lsr
                sta mapY
                lda posX
                lsr
                lsr
                lsr
                lsr
                sta mapX

                lda mapY 
                asl
                asl
                asl
                asl
                clc
                adc mapX
                tax
                lda game_map,x
                beq @end
                lda posX
                sec
                sbc stepX
                sta posX
                lda posY
                sec
                sbc stepY
                sta posY
@end
                rts

;;---------------------------------------------
;; irq_setup
;;---------------------------------------------             
irq_setup
                sei

                ldy #$7f
                sty $dc0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                sty $dd0d   ; 
                lda $dc0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
                lda $dd0d   ;

                lda #$01    ; set interrupt request mask
                sta $d01a   ; rasterbeam irq %00000001)

                lda #<irq   ; set custom irq routine address
                ldx #>irq 
                sta $0314   
                stx $0315   

                lda #$00    ; trigger interrupt at row zero
                sta $d012

                cli
                rts

;;---------------------------------------------
;; setup
;;---------------------------------------------             
setup
                jsr player_setup
                jsr screen_setup
                jsr irq_setup
                rts

;;---------------------------------------------
;; player_setup
;;
;; Loads player's initial pos and theta
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
;; screen_setup
;;
;; Fills the entire screen with A0 char
;;---------------------------------------------
screen_setup     
                ldx #0 
@loop                   lda #$A0
                        sta $0400,x
                        sta $0500,x
                        sta $0600,x
                        sta $06e8,x                        
                inx
                bne @loop 
                rts

;;---------------------------------------------
;; compute_frame
;;
;; Raycasting is done there, in three steps
;;---------------------------------------------
compute_frame   
                ldx #0
@loop                   txa
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
;;
;; Renders frame row by row.
;; Uses:
;; - F_16
;; - ray_start
;; - ray_end
;; - ray_color
;;---------------------------------------------
draw_frame      
                lda #$00
                sta F_16_L
                lda #$d8
                sta F_16_H
                ldx #0
@rows                   ldy #0
@cols                           clc
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
                rts


incasm  utils.asm
incasm  lookuptables.asm
incasm  gameMap.asm
incasm  player.asm
incasm  ray.asm
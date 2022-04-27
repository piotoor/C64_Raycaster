;;---------------------------------------------
;; check_keyboard
;;---------------------------------------------
check_keyboard  
                lda #%11111111  ; CIA#1 Port A set to output 
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

w_pressed       ;lda #%11111101
                ;sta pra
                lda prb
                and #%00000010
                beq move_forward

s_pressed       ;lda #%11111101
                ;sta pra
                lda prb
                and #%00100000
                beq move_back
                rts

;;---------------------------------------------
;; rotate_right
;;---------------------------------------------
rotate_right    
                lda theta
                adc #6
                sta theta
                rts

;;---------------------------------------------
;; rotate_left
;;---------------------------------------------
rotate_left     
                lda theta
                sec
                sbc #6
                sta theta
                rts

;;---------------------------------------------
;; move_forward
;;---------------------------------------------
move_forward    
                ldx theta
                ldy reducedTheta,x
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepX

                ldy mirrorReducedTheta,x
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepY

                ldx theta
                ldy xPlusTheta,x
                bne @x_end
@x_minus                lda stepX
                        eor #$ff
                        adc #1
                        sta stepX
@x_end          ldy yPlusTheta,x
                bne @y_end
@y_minus                lda stepY
                        eor #$ff
                        adc #1
                        sta stepY
@y_end          lda posX
                sta tmp_posX
                adc stepX
                sta posX

                tax
                lda posToMapCoords,x
                sta mapX                
                lda posY

                sta tmp_posY
                adc stepY
                sta posY

                tax
                lda posToMapCoords,x
                sta mapY

                tax
                lda mapCoordsToPos,x

                clc
                adc mapX
                tax
                lda game_map,x
                beq @end
                        lda tmp_posX
                        sta posX
                        lda tmp_posY
                        sta posY
@end            rts

;;---------------------------------------------
;; move_back
;;---------------------------------------------
move_back       
                ldx theta
                ldy reducedTheta,x
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepX

                ldy mirrorReducedTheta,x
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepY

                ldx theta
                ldy xPlusTheta,x
                beq @x_end
@x_plus                 lda stepX
                        eor #$ff
                        adc #1
                        sta stepX
@x_end          ldy yPlusTheta,x
                beq @y_end
@y_plus                 lda stepY
                        eor #$ff
                        adc #1
                        sta stepY
@y_end          lda posX
                sta tmp_posX
                adc stepX
                sta posX

                tax
                lda posToMapCoords,x
                sta mapX
                
                lda posY
                sta tmp_posY
                adc stepY
                sta posY

                tax
                lda posToMapCoords,x
                sta mapY

                tax
                lda mapCoordsToPos,x

                clc
                adc mapX
                tax
                lda game_map,x
                beq @end
                        lda tmp_posX
                        sta posX
                        lda tmp_posY
                        sta posY
@end            rts
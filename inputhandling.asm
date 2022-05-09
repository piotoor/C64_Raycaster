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
                adc #4
                sta theta
                rts

;;---------------------------------------------
;; rotate_left
;;---------------------------------------------
rotate_left     
                lda theta
                sec
                sbc #4
                sta theta
                rts

;;---------------------------------------------
;; move_forward
;;---------------------------------------------
move_forward    
                ldy theta
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepX

                lda sinX16,y
                ;lsr ; TODO add speed
                sta stepY

                lda posX
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
                ldy theta
                lda cosX16,y
                ;lsr ; TODO add speed
                sta stepX

                lda sinX16,y
                ;lsr ; TODO add speed
                sta stepY
     
                lda posX
                sta tmp_posX
                sec
                sbc stepX
                sta posX

                tax
                lda posToMapCoords,x
                sta mapX
                
                lda posY
                sta tmp_posY
                sec
                sbc stepY
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
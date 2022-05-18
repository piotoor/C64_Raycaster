ROTATION_SPEED=#4
ROTATION_SPEED_RUNNING=#6

;;---------------------------------------------
;; check_keyboard
;;---------------------------------------------
check_keyboard  
                lda #%11111111  ; CIA#1 Port A set to output 
                sta ddra             
                lda #%00000000  ; CIA#1 Port B set to input
                sta ddrb 
                
@d_pressed      lda #%11111011
                sta pra
                lda prb
                and #%00000100  
                beq rotate_right

@a_pressed      lda #%11111101
                sta pra
                lda prb
                and #%00000100
                beq rotate_left

@w_pressed      ;lda #%11111101
                ;sta pra
                lda prb
                and #%00000010
                beq move_forward

@s_pressed      ;lda #%11111101
                ;sta pra
                lda prb
                and #%00100000
                beq move_back

@q_pressed      lda #%01111111
                sta pra
                lda prb
                and #%01000000
                bne @e_pressed
                jmp strafe_left

@e_pressed      lda #%11111101
                sta pra
                lda prb
                and #%01000000
                bne @r_pressed
                jmp strafe_right

@r_pressed      lda #%11111011
                sta pra
                lda prb
                and #%00000010
                bne @end_input
                jmp toggle_run
@end_input      rts

;;---------------------------------------------
;; rotate_right
;;---------------------------------------------
rotate_right    
                lda playerTheta
                clc
                adc rotationSpeed
                sta playerTheta
                rts

;;---------------------------------------------
;; rotate_left
;;---------------------------------------------
rotate_left     
                lda playerTheta
                sec
                sbc rotationSpeed
                sta playerTheta
                rts

;;---------------------------------------------
;; move_forward
;;---------------------------------------------
move_forward    
                ldy playerTheta
                lda cosX6,y
                sta stepX
                lda sinX6,y
                sta stepY

                lda playerState
                and #%00000001
                beq @not_running        ; todo: separete luts (cosX8, sinX8)
@running        asl stepX
                asl stepY
@not_running

                lda posX
                sta tmpPosX
                clc
                adc stepX
                sta posX      
                
                lda posY
                sta tmpPosY
                clc
                adc stepY
                sta posY
                

                tay
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tax
                lda game_map,x
                beq @end
                        lda tmpPosX
                        sta posX
                        lda tmpPosY
                        sta posY
@end            rts

;;---------------------------------------------
;; move_back
;;---------------------------------------------
move_back       
                ldy playerTheta
                lda cosX6,y
                sta stepX
                lda sinX6,y
                sta stepY

                lda playerState
                and #%00000001
                beq @not_running        ; todo: separete luts (cosX8, sinX8)
@running        asl stepX
                asl stepY
@not_running
     
                lda posX
                sta tmpPosX
                sec
                sbc stepX
                sta posX
                
                lda posY
                sta tmpPosY
                sec
                sbc stepY
                sta posY
                
                tay
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tax
                lda game_map,x
                beq @end
                        lda tmpPosX
                        sta posX
                        lda tmpPosY
                        sta posY
@end            rts

;;---------------------------------------------
;; strafe_left
;;---------------------------------------------
strafe_left
                lda playerTheta
                sec
                sbc #64
                tay
                lda cosX6,y
                sta stepX
                lda sinX6,y
                sta stepY

                lda playerState
                and #%00000001
                beq @not_running        ; todo: separete luts (cosX8, sinX8)
@running        asl stepX
                asl stepY
@not_running

                lda posX
                sta tmpPosX
                clc
                adc stepX
                sta posX      
                
                lda posY
                sta tmpPosY
                clc
                adc stepY
                sta posY
                

                tay
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tax
                lda game_map,x
                beq @end
                        lda tmpPosX
                        sta posX
                        lda tmpPosY
                        sta posY
@end            rts

;;---------------------------------------------
;; strafe_right
;;---------------------------------------------
strafe_right
                lda playerTheta
                clc
                adc #64
                tay
                lda cosX6,y
                sta stepX
                lda sinX6,y
                sta stepY
                
                lda playerState
                and #%00000001
                beq @not_running        ; todo: separete luts (cosX8, sinX8)
@running        asl stepX
                asl stepY
@not_running
                lda posX
                sta tmpPosX
                clc
                adc stepX
                sta posX      
                
                lda posY
                sta tmpPosY
                clc
                adc stepY
                sta posY
                

                tay
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tax
                lda game_map,x
                beq @end
                        lda tmpPosX
                        sta posX
                        lda tmpPosY
                        sta posY
@end             rts

;;---------------------------------------------
;; toggle_run
;;---------------------------------------------
toggle_run
                lda #ROTATION_SPEED
                sta rotationSpeed
                lda playerState
                eor #%00000001
                sta playerState
             
                and #%00000001
                beq @not_running
@running        lda #ROTATION_SPEED_RUNNING
                sta rotationSpeed
                lda #'R'
                sta $0427
                rts
@not_running    lda DEFAULT_SCREEN_CHARACTER
                sta $0427
                rts

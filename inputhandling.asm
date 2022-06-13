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

                lda playerState ; disable running (bit 0)
                and #%11111110  ;
                sta playerState ; 

@rshift_pressed lda #%10111111
                sta pra
                lda prb
                and #%00010000
                bne @slash_pressed

                lda playerState ; enable running for
                ora #$00000001  ; the current frame
                sta playerState ;
                          
@slash_pressed  lda #%10111111  ; check if strafing is enabled
                sta pra         ; if yes, A & D work as strafe left & right
                lda prb
                and #%10000000
                bne @rotation
@strafing
@d_pressed_str          lda #%11111011
                        sta pra
                        lda prb
                        and #%00000100  
                        bne @a_pressed_str
                        jsr strafe_right

@a_pressed_str          lda #%11111101
                        sta pra
                        lda prb
                        and #%00000100
                        bne @w_pressed
                        jsr strafe_left
                        jmp @end_rotation

@rotation
@d_pressed_rot          lda #%11111011
                        sta pra
                        lda prb
                        and #%00000100  
                        bne @a_pressed_rot
                        jsr rotate_right

@a_pressed_rot          lda #%11111101
                        sta pra
                        lda prb
                        and #%00000100
                        bne @w_pressed
                        jsr rotate_left
@end_rotation

@w_pressed      lda #%11111101
                sta pra
                lda prb
                and #%00000010
                bne @s_pressed 
                jsr move_forward

@s_pressed      lda #%11111101
                sta pra
                lda prb
                and #%00100000
                bne @dot_pressed
                jsr move_back

@dot_pressed    lda #%11011111
                sta pra
                lda prb
                and #%00010000
                bne @space_pressed
                jsr update_weapon

@space_pressed  lda #%01111111
                sta pra
                lda prb
                and #%00010000
                bne @end_input
                jsr handle_doors

@end_input      rts


;;---------------------------------------------
;; handle_doors
;;
;; 0 = closed
;; 1 = opening
;; 2 = open
;; 3 = closing
;;---------------------------------------------
handle_doors
                lda doorState
                cmp #DOOR_CLOSED
                beq @door_closed
                cmp #DOOR_OPEN
                beq @door_open
                rts
@door_closed
                lda #DOOR_OPENING
                sta doorState
                lda #DOOR_OPEN_TIME
                sta stayOpenRemainingTime
                rts
@door_open
                lda #DOOR_CLOSING
                sta doorState
                lda #0
                sta stayOpenRemainingTime
                rts

;;---------------------------------------------
;; rotate_right
;;---------------------------------------------
rotate_right    
                lda playerState
                and #%00000001
                beq @not_running        
@running        lda playerTheta
                clc
                adc ROTATION_SPEED_RUNNING
                sta playerTheta
                rts
@not_running    lda playerTheta
                clc
                adc ROTATION_SPEED
                sta playerTheta
                rts

;;---------------------------------------------
;; rotate_left
;;---------------------------------------------
rotate_left     
                lda playerState
                and #%00000001
                beq @not_running        
@running        lda playerTheta
                sec
                sbc ROTATION_SPEED_RUNNING
                sta playerTheta
                rts
@not_running    lda playerTheta
                sec
                sbc ROTATION_SPEED
                sta playerTheta
                rts
                
;;---------------------------------------------
;; move_forward
;;---------------------------------------------
move_forward           
                lda playerTheta
                tay

                jmp move_common

;;---------------------------------------------
;; move_back
;;---------------------------------------------
move_back       
                lda playerTheta
                clc
                adc #128
                tay
                
                jmp move_common
;;---------------------------------------------
;; strafe_left
;;---------------------------------------------
strafe_left
                lda playerTheta
                sec
                sbc #64
                tay
                
                jmp move_common

;;---------------------------------------------
;; strafe_right
;;---------------------------------------------
strafe_right
                lda playerTheta
                clc
                adc #64
                tay
                
                jmp move_common

;;---------------------------------------------
;; move_common
;;---------------------------------------------
move_common
                lda playerState
                and #%00000001
                beq @not_running        
                
@running      
                lda posX
                sta tmpPosX
                clc
                adc cosX12,y
                sta posX
                
                lda posY
                sta tmpPosY
                clc
                adc sinX12,y
                sta posY
                
                jmp @endif
@not_running
                lda posX
                sta tmpPosX
                clc
                adc cosX6,y
                sta posX
                
                lda posY
                sta tmpPosY
                clc
                adc sinX6,y
                sta posY                
@endif

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


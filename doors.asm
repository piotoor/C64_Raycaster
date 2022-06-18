;threshold=$2d
;doorState=$2e           ; 0 = closed
;                        ; 1 = opening
;                        ; 2 = open
;                        ; 3 = closing
;doorMapOffset=$30

; doors arrays (4 doors at one map)
;doorThresholds=$c715
;doorStates=$c719
;doorTimers=$c71d
;doorMapOffsets=$c722

; doors arrays (8 doors at one map)
doorThresholds=$c715
doorStates=$c71d
doorTimers=$c725
doorMapOffsets=$c72d
; what door player's looking at
doorInSight=$2d


DOOR_OPEN_TIME=#40
DOOR_CLOSED=#0
DOOR_OPENING=#1
DOOR_OPEN=#2
DOOR_CLOSING=#3
MAX_DOOR_THRESHOLD=#16
MIN_DOOR_THRESHOLD=#0
NUM_OF_DOORS=#8
DOOR_TEXTURE_ID=#17

;;---------------------------------------------
;; doors_setup
;;---------------------------------------------
doors_setup
        ldx #NUM_OF_DOORS-1 ; door id
@loop                
                lda #MAX_DOOR_THRESHOLD
                sta doorThresholds,x
                lda #DOOR_CLOSED
                sta doorStates,x
                lda #0
                sta doorTimers,x
        dex
        bpl @loop

        lda #-1
        sta doorInSight
        rts

;;---------------------------------------------
;; handle_door_switch
;;
;; 0 = closed
;; 1 = opening
;; 2 = open
;; 3 = closing
;;---------------------------------------------
handle_door_switch
                ldx doorInSight
                ;stx $428
                cpx #-1
                beq @end
                
                ldy posY
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tay
                lda doorSwitchLocations,y
                ;sta $429
                cmp doorInSight
                bne @end
                

                lda doorStates,x
                cmp #DOOR_CLOSED
                beq @door_closed
;                cmp #DOOR_OPEN
;                beq @door_open
                rts
@door_closed
                lda #DOOR_OPENING
                ;sta $42a
                sta doorStates,x
                lda #DOOR_OPEN_TIME
                sta doorTimers,x
                rts
;@door_open
;                lda #DOOR_CLOSING
;                sta doorStates,x
;                lda #0
;                sta doorTimers,x

@end
                rts

;;---------------------------------------------
;; update_doors
;;---------------------------------------------
update_doors
 ;               lda threshold
;                sta $428
;                lda stayOpenRemainingTime
;                sta $429
                
                ldx #NUM_OF_DOORS-1 ; door id
@loop
;                        stx $460
;                        lda doorThresholds,x
;                        sta $450,x
;                        lda doorStates,x
;                        sta $478,x
;                        lda doorTimers,x
;                        sta $4a0,x

                        lda doorStates,x
                        cmp #DOOR_OPENING
                        beq @door_opening
                        cmp #DOOR_CLOSING
                        beq @door_closing
                        cmp #DOOR_OPEN
                        beq @decrease_timer
                        jmp @end
@door_opening   
                        ;ldy doorThresholds,x
;                        dey
;                        tya
;                        sta doorThresholds,x
                        ;lda #1
                        ;sta $42b
                        dec doorThresholds,x
                        beq @door_open
                        jmp @end
@door_open      
                        lda #DOOR_OPEN
                        sta doorStates,x
                        ldy doorMapOffsets,x
                        lda #0
                        sta game_map,y
                        jmp @end
@door_closing
                        ldy doorMapOffsets,x
                        lda #DOOR_TEXTURE_ID
                        sta game_map,y

                        ;ldy doorThresholds,x
;                        iny
;                        tya
;                        sta doorThresholds,x
                        inc doorThresholds,x
                        lda doorThresholds,x
                        cmp #MAX_DOOR_THRESHOLD
                        beq @door_closed
                        jmp @end
@door_closed    
                        lda #DOOR_CLOSED
                        sta doorStates,x
                        ;dec threshold
                        jmp @end
@decrease_timer
                        dec doorTimers,x
                        ;lda doorTimers,x
                        bne @end
                        lda #DOOR_CLOSING
                        sta doorStates,x
@end
                dex
                bpl @loop
                rts
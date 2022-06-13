threshold=$2d
doorState=$2e           ; 0 = closed
                        ; 1 = opening
                        ; 2 = open
                        ; 3 = closing
stayOpenRemainingTime=$2f
doorMapOffset=$30

DOOR_OPEN_TIME=#40
DOOR_CLOSED=#0
DOOR_OPENING=#1
DOOR_OPEN=#2
DOOR_CLOSING=#3
MAX_DOOR_THRESHOLD=#16
MIN_DOOR_THRESHOLD=#0

;;---------------------------------------------
;; doors_setup
;;---------------------------------------------
doors_setup
        lda #16
        sta threshold
        lda #0
        sta doorState
        lda #DOOR_OPEN_TIME
        sta stayOpenRemainingTime
        lda #35
        sta doorMapOffset
        rts

;;---------------------------------------------
;; update_doors
;;---------------------------------------------
update_doors
                lda threshold
                sta $428
                lda stayOpenRemainingTime
                sta $429
                lda doorState
                cmp #DOOR_OPENING
                beq @door_opening
                cmp #DOOR_CLOSING
                beq @door_closing
                cmp #DOOR_OPEN
                beq @decrease_timer
                rts
@door_opening   
                ldx threshold
                dex
                stx threshold
                beq @door_open
                rts
@door_open      
                lda #DOOR_OPEN
                sta doorState
                ldx doorMapOffset
                lda #0
                sta game_map,x
                rts
@door_closing
                ldx doorMapOffset
                lda #21
                sta game_map,x

                ldx threshold
                inx
                stx threshold
                cpx #MAX_DOOR_THRESHOLD
                beq @door_closed
                rts
@door_closed    
                lda #DOOR_CLOSED
                sta doorState
                ;dec threshold
                rts
@decrease_timer
                dec stayOpenRemainingTime
                lda stayOpenRemainingTime
                bne @end
                lda #DOOR_CLOSING
                sta doorState
@end
                rts
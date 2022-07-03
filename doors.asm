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
doorRequiredKeyMasks=$c735          ; check with playerState
doorRequiredTriggers=$c73d
doorMapIds=$c745


DOOR_OPEN_TIME=#80
TRIGGERED_DOOR_OPEN_TIME=#79
DOOR_CLOSED=#0
DOOR_OPENING=#1
DOOR_OPEN=#2
DOOR_CLOSING=#3
MAX_DOOR_THRESHOLD=#17
MIN_DOOR_THRESHOLD=#0
NUM_OF_DOORS=#8
DOOR_MAP_ID_START=#65
TRIGGER_DOOR_MAP_ID_START=#97


;;---------------------------------------------
;; doors_setup
;;---------------------------------------------
doors_setup
        jsr doors_setup_general
        jsr doors_setup_map_specific


;;---------------------------------------------
;; doors_setup_general
;;
;; initializes:
;; - doorStates
;; - doorThresholds
;; - doorTimers
;;---------------------------------------------
doors_setup_general
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
;; doors_setup_map_specific
;;
;; initializes:
;; - doorMapOffsets
;; - doorMap
;; - doorRequiredKeyMasks
;; - doorRequiredTriggers
;; - doorMapIds
;;---------------------------------------------
doors_setup_map_specific
                jsr doors_setup_switch_locations
        
                ldy #0          ; keeps door id
                ldx #0          ; could be optimized and start not on the map border
@loop
                lda game_map,x
                clc
                cmp #DOOR_MAP_ID_START
                bcc @continue
                sta doorMapIds,y
                cmp #65
                beq @red_key
                cmp #81
                beq @red_key

                cmp #69
                beq @blue_key
                cmp #85
                beq @blue_key

                cmp #73
                beq @yellow_key
                cmp #89
                beq @yellow_key

                cmp #77
                beq @no_key
                cmp #93
                beq @no_key
                
                cmp #TRIGGER_DOOR_MAP_ID_START
                bcs @trigger_door

@red_key
                lda #PLAYER_STATE_RED_KEY_MASK
                sta doorRequiredKeyMasks,y
                jmp @end_door_trigger_type
@blue_key
                lda #PLAYER_STATE_BLUE_KEY_MASK
                sta doorRequiredKeyMasks,y
                jmp @end_door_trigger_type
@yellow_key
                lda #PLAYER_STATE_GREEN_KEY_MASK
                sta doorRequiredKeyMasks,y
                jmp @end_door_trigger_type
@no_key
                lda #PLAYER_STATE_NO_KEY_MASK
                sta doorRequiredKeyMasks,y
                jmp @end_door_trigger_type
                
@trigger_door
                clc
                sbc #TRIGGER_DOOR_MAP_ID_START
                lsr
                lsr
                sta doorRequiredTriggers,y

@end_door_trigger_type
                txa
                sta doorMapOffsets,y
                tya
                sta doorMap,x
                iny
@continue
                inx
                bne @loop
                rts

;;---------------------------------------------
;; doors_setup_switch_locations
;;---------------------------------------------
doors_setup_switch_locations
currDoorId=$2f
                ldx #0
                stx currDoorId
@loop
                lda game_map,x
                clc
                cmp #DOOR_MAP_ID_START
                bcc @continue
                
                dex
                lda currDoorId
                sta doorSwitchLocations,x       ; L
                inx
                inx
                sta doorSwitchLocations,x       ; R
                dex
                
                
                txa     
                tay     ; saved x in y

                sec
                sbc #16
                tax
                lda currDoorId
                sta doorSwitchLocations,x       ; U
                
                txa
                clc
                adc #32
                tax
                lda currDoorId
                sta doorSwitchLocations,x       ; D
                tya
                tax     ; restored x

                inc currDoorId
@continue
                inx
                bne @loop


;                ldx #0
;@loop2
;                lda doorSwitchLocations,x
;                sta $4c8,x
;                inx
;                bne @loop2

                rts



; handle_door_trigger - just like switch, but for triggers only, with different TRIGGERED_DOOR_OPEN_TIME
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
                cpx #-1
                beq @end
                
                ldy posY
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                tay
                lda doorSwitchLocations,y
                cmp doorInSight
                bne @end
                

                lda doorStates,x
                cmp #DOOR_CLOSED
                beq @door_closed
;                cmp #DOOR_OPEN
;                beq @door_open
                rts
@door_closed
                lda playerState                 ; check if player has the required key
                and doorRequiredKeyMasks,x      ;
                beq @end                        ;

                lda #DOOR_OPENING
                
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
                
                ldx #NUM_OF_DOORS-1 ; door id
@loop
                        lda doorStates,x
                        cmp #DOOR_OPENING
                        beq @door_opening
                        cmp #DOOR_CLOSING
                        beq @door_closing
                        cmp #DOOR_OPEN
                        beq @decrease_timer
                        jmp @end
@door_opening   
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
                        lda doorMapIds,x
                        sta game_map,y

                        inc doorThresholds,x
                        lda doorThresholds,x
                        cmp #MAX_DOOR_THRESHOLD
                        beq @door_closed
                        jmp @end
@door_closed    
                        lda #DOOR_CLOSED
                        sta doorStates,x
                        jmp @end
@decrease_timer
                        dec doorTimers,x
                        dec doorTimers,x ; twice, to distinguish between one-time and multi-time doors
                        bne @end
                        lda #DOOR_CLOSING
                        sta doorStates,x
@end
                dex
                bpl @loop
                rts
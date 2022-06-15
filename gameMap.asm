SQUARE_SIZE_X2=#32
SQUARE_SIZE=#16
MAP_WIDTH=#16
MAP_HEIGHT=#16

game_map        byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
                byte 9,0,0,0,0,0,0,9,0,0,0,0,0,9,0,9
                byte 9,9,9,17,9,9,17,9,9,9,9,9,0,0,0,9
                byte 9,0,0,0,0,9,0,0,17,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1
                byte 1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1
                byte 1,1,1,0,1,1,1,0,5,5,5,5,5,5,0,5
                byte 13,0,0,0,0,0,13,0,5,0,0,0,0,5,0,5
                byte 13,0,0,0,0,0,13,0,5,0,5,0,5,5,0,5
                byte 13,0,13,0,0,0,13,0,5,0,5,0,0,5,5,5
                byte 13,0,0,0,0,0,13,0,5,0,5,0,0,5,0,5
                byte 13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5
                byte 13,13,13,13,13,5,5,5,5,5,5,5,5,5,5,5

; texture codes
;
; 1 - red
; 5 - blue
; 9 - green
; 13 - orange / yellow
; 17 - c64
; 21 - door
;
; increment = 4 in order to easily produce (add or subtract 1 to get light or dark version) 
; indices (0, 2, 4 etc.) for the texturesVect
;


;;---------------------------------------------
;; map_setup
;;
;; Computes doorSwitchLocations and doorMap LUTs
;;---------------------------------------------   
map_setup
                jsr compute_doorMapOffsets_and_gameMap
                jsr compute_doorSwitchLocations
                rts

;;---------------------------------------------
;; compute_doorMapOffsets_and_gameMap
;;---------------------------------------------
compute_doorMapOffsets_and_gameMap
                ldy #0   ; keeps door id
                ldx #0 ; could be optimized and start not on the map border
@loop
                lda game_map,x
                cmp #DOOR_TEXTURE_ID
                bne @continue
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
;; compute_doorSwitchLocations
;;---------------------------------------------
compute_doorSwitchLocations
                ldx #0
@loop
                lda game_map,x
                cmp #DOOR_TEXTURE_ID
                bne @continue
                
                dex
                inc doorSwitchLocations,x       ; L
                inx
                inx
                inc doorSwitchLocations,x       ; R
                dex
                
                txa     
                tay     ; saved x in y

                sec
                sbc #16
                tax
                inc doorSwitchLocations,x       ; U
                
                clc
                adc #32
                tax
                inc doorSwitchLocations,x       ; D
                tya
                tax     ; restored x


@continue
                inx
                bne @loop


;                ldx #0
;@loop2
;                lda doorSwitchLocations,x
;                sta $450,x
;                inx
;                bne @loop2



                rts
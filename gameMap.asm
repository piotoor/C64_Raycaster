SQUARE_SIZE_X2=#32
SQUARE_SIZE=#16
MAP_WIDTH=#16
MAP_HEIGHT=#16

game_map        byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
                byte 9,0,0,0,0,0,0,9,0,0,0,0,0,9,0,9
                byte 9,9,9,77,9,9,73,9,9,9,9,9,0,0,0,9
                byte 9,0,0,0,0,9,0,0,77,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,1,0,0,0,0,0,73,0,0,0,0,65,0,1
                byte 1,0,1,0,1,0,0,0,5,0,0,0,0,1,0,1
                byte 1,1,1,69,1,1,1,0,5,5,5,5,5,5,0,5
                byte 13,0,0,0,0,0,13,0,5,0,0,0,0,5,0,5
                byte 13,0,0,0,0,0,13,0,5,0,5,0,5,5,0,5
                byte 13,0,13,0,0,0,13,0,5,0,5,0,0,5,65,5
                byte 13,0,0,0,0,0,13,5,5,0,5,0,0,5,0,5
                byte 13,0,0,0,0,0,0,69,0,0,0,0,0,0,0,5
                byte 13,13,13,13,13,5,5,5,5,5,5,5,5,5,5,5


;   1,   5,   9,  13,  17,  21,  25,  29 - regular walls
;  33,  37,  41,  45,  49,  53,  57,  61 - pillar  walls
;
;  --- automatic ---   ---- manual  ----
;  rk   bk   gk   nk   rk   bk   gk   nk
;  65,  69,  73,  77,  81,  85,  89,  93 - regular doors
;
;  97, 101, 105, 109, 113, 117, 121, 125 - triggered doors
; 129, 133, 137, 141, 145, 149, 153, 157 - triggered doors


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
;; compute_doorMapOffsets_and_doorMap
;;---------------------------------------------
compute_doorMapOffsets_and_doorMap
                ldy #0   ; keeps door id
                ldx #0 ; could be optimized and start not on the map border
@loop
                lda game_map,x
                clc
                cmp #DOOR_MAP_ID_START
                bcc @continue
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
;currDoorId=$2f
;compute_doorSwitchLocations
;                ldx #0
;                stx currDoorId
;@loop
;                ;lda #-1
;                ;sta doorSwitchLocations,x
;                lda game_map,x
;                clc
;                cmp #DOOR_MAP_ID_START
;                bcc @continue
;                
;                dex
;                lda currDoorId
;                sta doorSwitchLocations,x       ; L
;                inx
;                inx
;                sta doorSwitchLocations,x       ; R
;                dex
;                
;                
;                txa     
;                tay     ; saved x in y

;                sec
;                sbc #16
;                tax
;                lda currDoorId
;                sta doorSwitchLocations,x       ; U
;                
;                txa
;                clc
;                adc #32
;                tax
;                lda currDoorId
;                sta doorSwitchLocations,x       ; D
;                tya
;                tax     ; restored x

;                inc currDoorId
;@continue
;                inx
;                bne @loop


;;                ldx #0
;;@loop2
;;                lda doorSwitchLocations,x
;;                sta $4c8,x
;;                inx
;;                bne @loop2



;                rts

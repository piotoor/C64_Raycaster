SQUARE_SIZE_X2=#32
SQUARE_SIZE=#16
MAP_WIDTH=#16
MAP_HEIGHT=#16

game_map        byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
                byte 9,0,0,0,0,0,0,9,0,0,0,0,0,9,0,9
                byte 9,9,9,0,9,9,0,9,9,9,9,9,0,0,0,9
                byte 9,0,0,0,0,17,0,0,0,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,1,1,1,0,0,0,1,0,1
                byte 1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,1
                byte 1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1
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
;
; increment = 4 in order to easily produce (add or subtract 1 to get light or dark version) 
; indices (0, 2, 4 etc.) for the texturesVect
;

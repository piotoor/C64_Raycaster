SQUARE_SIZE_X2=#32
SQUARE_SIZE=#16
MAP_WIDTH=#16
MAP_HEIGHT=#16


game_map        byte  5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
                byte  5, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5, 0, 5
                byte  5, 5, 5,39, 5, 5,37, 5, 5, 5, 5, 5, 0, 0, 0, 5
                byte  5, 0, 0, 0, 0, 5, 0, 0,39, 0, 0, 0, 0, 1, 0, 1
                byte  1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1
                byte  1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1
                byte  1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1
                byte  1, 0, 1, 0, 0, 0, 0, 0,37, 0, 0, 0, 0,33, 0, 1
                byte  1, 0, 1, 0, 1, 0, 0, 0, 3, 0, 0, 0, 0, 1, 0, 1
                byte  1, 1, 1,35, 1, 1, 1, 0, 3, 3, 3, 3, 3, 3, 0, 5
                byte  7, 0, 0, 0, 0, 0, 7, 0, 3, 0, 0, 0, 0, 3, 0, 5
                byte  7, 0, 0, 0, 0, 0, 7, 0, 3, 0, 3, 0, 3, 3, 0, 5
                byte  7, 0, 7, 0, 0, 0, 7, 0, 3, 0, 3, 0, 0, 3,33, 5
                byte  7, 0, 0, 0, 0, 0, 7, 3, 3, 0, 3, 0, 0, 3, 0, 5
                byte  7, 0, 0, 0, 0, 0, 0,35, 0 ,0 ,0 ,0 ,0 ,0 ,0, 5
                byte  7, 7, 7, 7, 7, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5


;   1,   3,   5,   7,   9,  11,  13,  15 - regular walls
;  17,  19,  21,  23,  25,  27,  29,  31 - pillar  walls
;
;  --- automatic ---   ---- manual  ----
;  rk   bk   gk   nk   rk   bk   gk   nk
;  33,  35,  37,  39,  41,  43,  45,  47 - regular doors
;
;  49, 51, 53, 55, 57, 59, 61, 63 - triggered doors
;  65, 67, 69, 71, 73, 75, 77, 79 - triggered doors
;
; trigger_id = (map_id - 49) << 1

; increment = 2 in order to easily produce (leave initial value or subtract 1 to get light or dark version) 
;
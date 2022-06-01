enemyPosX=$6b
enemyPosY=$6c
;enemyMapX=$87
;enemyMapY=$88
ENEMY_SIZE=#8

;;---------------------------------------------
;; enemy_setup
;;
;; Loads enemy's initial pos and theta
;;---------------------------------------------             
enemy_setup
                lda #88
                sta enemyPosX
                lda #72
                sta enemyPosY
                ; calculate enemyMapX and enemyMapY
                ; for now hardcoded here and on gameMap
                rts


ENEMY_SPRITE_COLOR=#11
ENEMY_FRAMES=#2
enemyCurrentFrame=$28
MASKING_SPRITE_PTR=#WEAPON_SPRITE_PTR+#WEAPON_FRAMES  
ENEMY_SPRITE_PTR=#MASKING_SPRITE_PTR+1

;;---------------------------------------------
;; enemy_sprites_setup
;;---------------------------------------------  
enemy_sprites_setup
                lda #0
                sta enemyCurrentFrame
                lda #MASKING_SPRITE_PTR         
                sta $07fa

                
                lda $d015               ; enable sprites 2 and 3
                ora #%00001100
                sta $d015               
                
                lda $d01c               ; sprite 3 multicolor
                ora #%00001000
                sta $d01c

                lda $d01b               ; sprite 3 over bg
                ora #%00000100          ; sprite 2 not
                sta $d01b   

                lda #ENEMY_SPRITE_COLOR       
                sta $d02a               ; sprite 3 color
                lda #BG_COLOR
                STA $d029

                rts

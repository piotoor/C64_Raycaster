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
                lda #128
                sta enemyPosX
                lda #128
                sta enemyPosY
                ; calculate enemyMapX and enemyMapY
                ; for now hardcoded here and on gameMap
                rts
enemyPosX=$6b
enemyPosY=$6c
;enemyMapX=$87
;enemyMapY=$88


;;---------------------------------------------
;; enemy_setup
;;
;; Loads enemy's initial pos and theta
;;---------------------------------------------             
enemy_setup
                lda #20
                sta enemyPosX
                lda #20
                sta enemyPosY
                rts
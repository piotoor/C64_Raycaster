enemySpriteCurrDist=$81
enemySpriteCurrDist_L=$81
enemySpriteCurrDist_H=$82

enemySpriteCurrDistDx=$83
enemySpriteCurrDistDx_L=$83
enemySpriteCurrDistDx_H=$84

enemyRayTheta=$85


;;---------------------------------------------
;; init_enemy_ray_params
;;---------------------------------------------
init_enemy_ray_params
                lda posX
                cmp enemyPosX
                bcs @posX_ge
@posX_ge
                ;sec already setm bcs taken
                sbc enemyPosX
                
                jmp @endif_x
@posX_lt
                sec
                lda enemyPosX
                sbc posX
@endif_x
                sta $0430
                lsr ; table
                lsr ; must be x2 to properly index
                asl
                tax

                lda posY
                cmp enemyPosY
                bcs @posY_ge
@posY_ge
                ;sec already setm bcs taken
                sbc enemyPosY
                jmp @endif_y
@posY_lt
                sec
                lda enemyPosY
                sbc posY
@endif_y
                sta $0431
                lsr ; table
                lsr
                asl
                tay
                
                atan
                sta enemyRayTheta
                sta $0428
                rts

;;---------------------------------------------
;; cast_enemy_ray
;;---------------------------------------------
cast_enemy_ray
                
                
                rts
enemyPerpDistance=$81
enemyHalfAngleSize=$83


enemyRayTheta=$85
enemyRayThetaRed=$84
deltaTheta=$89
enemyFirstRayId=$82
enemyLastRayId=$8a
enemyRayId=$26
renderEnemyFlags=$27            ; in case of more enemies, 
                                ; 1 - render, 
                                ; 0 - don't, it's out of sight
enemyRayThetaQuadrant=$7c       ; 0 - quadrant iii
                                ; 1 - quadrant iv
                                ; 2 - quadrant ii
                                ; 3 - quadrant i

QUADRANT_I=#3
QUADRANT_II=#2
QUADRANT_III=#0
QUADRANT_IV=#1

enemyPlyPosDeltaX=$87
enemyPlyPosDeltaY=$88
;texMapCoordsIdx=$7c

;;---------------------------------------------
;; init_enemy_ray_params
;;---------------------------------------------
init_enemy_ray_params
        
                lda #0
                sta enemyRayThetaQuadrant
                sta renderEnemyFlags


                lda posX                        ; calculating enemy-player abs deltaX
                cmp enemyPosX                   
                bcs @posX_ge                    
@posX_lt                                        ; enemyRay goes right                
                sec
                lda enemyPosX
                sbc posX
                sta enemyPlyPosDeltaX
                sta f_8
                
                lda enemyRayThetaQuadrant
                ora #%00000001
                sta enemyRayThetaQuadrant
                jmp @endif_x
@posX_ge                                        ; enemyRay goes left
                ;sec already setm bcs taken
                sbc enemyPosX
                sta enemyPlyPosDeltaX
                sta f_8
@endif_x



                lda posY                        ; calculating enemy-player abs deltaY
                cmp enemyPosY
                bcs @posY_ge
@posY_lt                                        ; enemyRay goes down
                sec
                lda enemyPosY
                sbc posY
                sta enemyPlyPosDeltaY
                sta g_8

                lda enemyRayThetaQuadrant
                ora #%00000010
                sta enemyRayThetaQuadrant
                jmp @endif_y
@posY_ge                                        ; enemyRay goes up
                ;sec already setm bcs taken
                sbc enemyPosY
                sta enemyPlyPosDeltaY
                sta g_8
@endif_y



                lda enemyPlyPosDeltaY           ; scaling to improve atan accuracy
                ora enemyPlyPosDeltaX           ; instead of always dividing by 4
                tax
                and #$80                ; >= 128 ?
                bne @ge_128
                txa
                and #$C0                ; >= 64
                bne @ge_64
                lda f_8
                jmp @endif_atan
@ge_128
                lda f_8
                lsr
                lsr
                lsr g_8
                lsr g_8
                jmp @endif_atan
@ge_64
                lda f_8
                lsr
                lsr g_8

@endif_atan
                asl
                tax
                ldy g_8

                atan                            ; reduced enemyRayTheta in [0; 64]
                sta enemyRayTheta
                sta enemyRayThetaRed


                
                ldx enemyRayThetaQuadrant       ; calculating full enemyRayTheta
                cpx QUADRANT_I
                beq @q_end
                cpx QUADRANT_II
                beq @q_ii
                cpx QUADRANT_III
                beq @q_iii
@q_iv          
                lda #0
                sec
                sbc enemyRayTheta
                jmp @q_end

@q_ii
                lda #128
                sec
                sbc enemyRayTheta
                jmp @q_end

@q_iii
                lda enemyRayTheta
                clc
                adc #128
                jmp @q_end

@q_end          
                sta enemyRayTheta               ; full enemyRayTheta in [0; 256)
                tax                             ; to save ldx later



                cmp playerTheta                 ; |playerTheta - enemyRayTheta|
                bcs @enemy_ge_ply               ; TODO: to macro
@enemy_lt_ply   lda playerTheta                 ;
                sec                             ;
                sbc enemyRayTheta               ;
                                                ;
                jmp @endif                      ;
@enemy_ge_ply   sec                             ;
                sbc playerTheta                 ;
                                                ;
@endif                                          ;
                                                ;       if delta > 180
                cmp #128                        ;       360 - delta
                bcc @done                       ;
                eor #$ff                        ;
                clc                             ;
                adc #1                          ;
                
@done                                           
                sta deltaTheta

                cmp #22                         ; if deltaTheta >= 64 (90)
                bcc @continue                   ; don't render enemy.

                lda #MASKING_SPRITE_PTR+7       ; cover enemy sprite entirely
                sta $07fa                       ; sprite 2 (masking) pointer
                rts                             ; 
        
@continue       inc renderEnemyFlags            ; for now. With more enemies, it should set relevant bit flag                                      
                lda playerTheta                 ; calculating enemyRayId
                clc                             ; could be negative, when to the left
                adc deltaTheta                  ; of the left-most rayId
                cmp enemyRayTheta
                beq @to_the_right
@to_the_left    lda #20
                sec
                sbc deltaTheta
                jmp @ray_id_end
@to_the_right   lda #20
                clc
                adc deltaTheta
@ray_id_end
                sta enemyRayId
                
                ldy enemyPlyPosDeltaX
                cpy #2                          ; atan inaccuracy workaround
                bcc @posDeltaX_0
                lda minusThetaInitCoordX2,y
        
                ldx enemyRayThetaRed
                ldy reducedTheta_x2,x
                mxOverCos rayCurrDistX_L,rayCurrDistX_H
                
                ldx enemyRayThetaRed
                ldy reducedTheta_x2,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 
                rts

@posDeltaX_0    lda enemyPlyPosDeltaY
                lsr; *64 -> / 128 = /2
                sta enemyPerpDistance
                rts

;;---------------------------------------------
;; cast_enemy_ray
;;---------------------------------------------
cast_enemy_ray
                ldx enemyPlyPosDeltaX
                cpx #2
                bcc @posDeltaX_0

                ldy posToMapCoords,x
@loop           beq @endloop
                
                clc                     ; 
                lda rayCurrDistX_L      ; 
                adc rayDistDx_L         ; 
                sta rayCurrDistX_L      ; 
                lda rayCurrDistX_H      ; 
                adc rayDistDx_H         ; 
                sta rayCurrDistX_H      ; 

                dey
                jmp @loop
@endloop
                lda deltaTheta
                asl 
                tax
                
                lda rayCurrDistX_L      ; dividing distance by 128
                asl                     ; bit 7 -> 0
                lda #0                  ;
                adc #0                  ;
                aso rayCurrDistX_H      ; asl rayCurrDistY_H
                                        ; ora rayCurrDistY_H              
                perpDistance
                sta enemyPerpDistance
@posDeltaX_0
                rts
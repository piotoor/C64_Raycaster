enemySpriteCurrDist=$81
enemySpriteCurrDist_L=$81
enemySpriteCurrDist_H=$82

enemySpriteCurrDistDx=$83
enemySpriteCurrDistDx_L=$83
enemySpriteCurrDistDx_H=$84

enemyRayTheta=$85
deltaTheta=$89
playerThetaEnemyThetaDiff=$8a
enemyRayId=$26
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

                lda posX                        ; calculating enemy-player abs deltaX
                cmp enemyPosX                   
                bcs @posX_ge                    
@posX_lt                                        ; enemyRay goes right                
                sec
                lda enemyPosX
                sbc posX
                sta enemyPlyPosDeltaX
                lda enemyRayThetaQuadrant
                ora #%00000001
                sta enemyRayThetaQuadrant
                jmp @endif_x
@posX_ge                                        ; enemyRay goes left
                ;sec already setm bcs taken
                sbc enemyPosX
                sta enemyPlyPosDeltaX
@endif_x
                lda enemyPlyPosDeltaX
                lsr
                lsr ; must be x2 to properly index
                asl
                tax



                lda posY                        ; calculating enemy-player abs deltaY
                cmp enemyPosY
                bcs @posY_ge
@posY_lt                                        ; enemyRay goes down
                sec
                lda enemyPosY
                sbc posY
                sta enemyPlyPosDeltaY
                lda enemyRayThetaQuadrant
                ora #%00000010
                sta enemyRayThetaQuadrant
                jmp @endif_y

@posY_ge                                        ; enemyRay goes up
                ;sec already setm bcs taken
                sbc enemyPosY
                sta enemyPlyPosDeltaY
@endif_y
                lda enemyPlyPosDeltaY
                lsr
                lsr
                asl
                tay
                
                atan                            ; reduced enemyRayTheta in [0; 64]
                ; tay                           
                ; lda unreduceTheta,y
                sta enemyRayTheta
                sta $0428

                
                ldx enemyRayThetaQuadrant       ; calculating full enemyRayTheta
                stx $0431
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
                sta $0429


                cmp playerTheta                 ; |playerTheta - enemyRayTheta|
                bcs @enemy_ge_ply               ; TODO: to macro
@enemy_lt_ply   lda playerTheta                 ;
                sec                             ;
                sbc enemyRayTheta               ;
                                                ;
                jmp @endif                      ;
@enemy_ge_ply   sec                             ;
                sbc playerTheta                 ;

@endif         
                sta deltaTheta                  ;
                cmp #128                        ;
                bcc @done                       ;
                lda #0                          ;
                sec                             ;
                sbc deltaTheta                  ;
                sta deltaTheta                  ;
@done                                           ;
                
                
                rts

;;---------------------------------------------
;; cast_enemy_ray
;;---------------------------------------------
cast_enemy_ray
                
                
                rts
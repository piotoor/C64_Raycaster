;enemySpriteCurrDist=$81
;enemySpriteCurrDist_L=$81
;enemySpriteCurrDist_H=$82

;enemySpriteCurrDistDx=$83
;enemySpriteCurrDistDx_L=$83
;enemySpriteCurrDistDx_H=$84

enemyRayTheta=$85
deltaTheta=$89
playerThetaEnemyThetaDiff=$8a
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
                sta deltaTheta                  ; if delta > 180
                cmp #128                        ; 360 - delta
                bcc @done                       ;
                lda #0                          ;
                sec                             ;
                sbc deltaTheta                  ;
                sta deltaTheta                  ;
@done                                           ;
                
                cmp #64                         ; if deltaTheta > 64 (90)
                bcc @continue                   ; don't render enemy.
                rts                             ; It's out of sight.
        
@continue       inc renderEnemyFlags            ; for now. With more enemies, it should set relevant bit flag                                      

                lda playerTheta                 ; calculating enemyRayId
                clc                             ; could be negative, when to the left
                adc deltaTheta                  ; of the left-most rayId
                cmp enemyRayTheta
                beq @to_the_right
@to_the_left    lda #20
                sec
                sbc deltaTheta
                sta enemyRayId
                jmp @ray_id_end
@to_the_right   lda #20
                clc
                adc deltaTheta
                sta enemyRayId
@ray_id_end

                
          
;zawsze w prawo, bo licze tylko dlugosc, a mam abs dx i abs dy
;wyliczyc to co wystaje poza siatke w prawo
;wyliczyc ile mam pol mapy i tyle petla leci
;koniec

;posCoordsToOffset
;posMod16
                
                
                ldy enemyPlyPosDeltaX
                lda minusThetaInitCoordX2,y
        
                ldx enemyRayTheta
                ldy reducedTheta_x2,x
                mxOverCos rayCurrDistX_L,rayCurrDistX_H
                

                ldx enemyRayTheta
                ldy reducedTheta_x2,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 

;                ldy posY
;                lda posCoordsToOffset,y
;                ldy posX
;                clc
;                adc posToMapCoords,y
;                sta gameMapOffset

                ;ldx enemyRayTheta              ; tax done before
;                ldy enemyPosX
;                lda xPlusTheta,x
;                beq @x_minus
;@x_plus                 
;                        lda plusThetaInitCoordX2,y      ; x2 to index word array
;                        ;sta absWallHitXDistX2           ; x2 to index word array
;                        ldy #1
;                        sty stepX
;                jmp @x_end
;@x_minus                
;                        lda minusThetaInitCoordX2,y     ; x2 to index word array
;                        ;sta absWallHitXDistX2           ; x2 to index word array
;                        ldy #-1
;                        sty stepX
;@x_end          
;                ldy reducedTheta_x2,x
;                mxOverCos rayCurrDistX_L,rayCurrDistX_H

;                
;                ldy enemyPosY
;                ldx enemyRayTheta
;                lda yPlusTheta,x
;                beq @y_minus
;@y_plus                 
;                        lda plusThetaInitCoordX2,y
;                        ldy #MAP_HEIGHT
;                        sty stepY
;                jmp @y_end
;@y_minus                
;                        lda minusThetaInitCoordX2,y
;                        ldy #-16
;                        sty stepY
;@y_end          
;                ldy mirrorReducedTheta_x2,x
;                mxOverCos rayCurrDistY_L,rayCurrDistY_H

;                
;                ldx enemyRayTheta
;                ldy reducedTheta_x2,x 
;                mxOverCosX16 rayDistDx_L,rayDistDx_H 
;                
;                ldy mirrorReducedTheta_x2,x
;                mxOverCosX16 rayDistDy_L,rayDistDy_H  


                rts

;;---------------------------------------------
;; cast_enemy_ray
;;---------------------------------------------
cast_enemy_ray
                ldx enemyPlyPosDeltaX
                
                ldy posDiv16,x
                bne
                rts
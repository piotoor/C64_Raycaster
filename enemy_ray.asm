enemyPerpDistance=$81
enemyLineStartRow=$82
enemyHalfAngleSize=$83
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
                lda enemyPlyPosDeltaY           ; scaling to [0;32]
                lsr                             ; x2 to index
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

                rts

;;---------------------------------------------
;; cast_enemy_ray
;;---------------------------------------------
cast_enemy_ray
                ldx enemyPlyPosDeltaX

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
                

                lda rayCurrDistX_L      ; dividing distance by 128
                asl                     ; bit 7 -> 0
                lda #0                  ;
                adc #0                  ;
                aso rayCurrDistX_H      ; asl rayCurrDistY_H
                                        ; ora rayCurrDistY_H
                
                ldx deltaTheta
                perpDistance
                sta enemyPerpDistance
                tax
                lda sprtStartRowLut,x
                sta enemyLineStartRow
                lda sprtHalfAngSize,x
                sta enemyHalfAngleSize

                rts
enemyPerpDistance=$81
;enemyHalfAngleSize=$83 FREE MEM


objectRayTheta=$85
enemyRayThetaRed=$84
deltaTheta=$89
;enemyFirstRayId=$82            FREE MEM
;enemyLastRayId=$8a             FREE MEM
enemyRayId=$26
renderEnemyFlags=$27            ; in case of more enemies, 
                                ; 1 - render, 
                                ; 0 - don't, it's out of sight
enemyRayThetaQuadrant=$7c       ; 0 - quadrant iii
                                ; 2 - quadrant iv
                                ; 4 - quadrant ii
                                ; 6 - quadrant i

QUADRANT_I=#3
QUADRANT_II=#2
QUADRANT_III=#0
QUADRANT_IV=#1

enemyPlyPosDeltaX=$87
enemyPlyPosDeltaY=$88
;texMapCoordsIdx=$7c

;;---------------------------------------------
;; init_object_ray_params
;;---------------------------------------------
init_object_ray_params
        
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
                ora #%00000010
                sta enemyRayThetaQuadrant
                jmp @endif_x
@posX_ge                                        ; enemyRay goes left
                ;sec already setm bcs taken
                sbc enemyPosX
                sta enemyPlyPosDeltaX
                
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
                ora #%00000100
                sta enemyRayThetaQuadrant
                jmp @endif_y
@posY_ge                                        ; enemyRay goes up
                ;sec already setm bcs taken
                sbc enemyPosY
                sta enemyPlyPosDeltaY
                sta g_8
@endif_y

                lda enemyPlyPosDeltaY
                tay
                ora enemyPlyPosDeltaX
                and #$C0
                beq @lt_64

                lda lsr_lsr,y
                ldy enemyPlyPosDeltaX
                ldx lsr_lsr_X2,y
                tay
                jmp @endif_atan

@lt_64
                lda enemyPlyPosDeltaX
                asl
                tax
                
@endif_atan
                ;ldy g_8
                atan                            ; reduced enemyRayTheta in [0; 64]
                ;sta enemyRayTheta              ; no need to save now
                sta enemyRayThetaRed            ;

                ldx enemyRayThetaQuadrant       ; full enemyRayTheta in [0; 256)
                ;lda enemyRayTheta;             ; already in a after atan
                fullObjectRayTheta              ;
                sta objectRayTheta               ;                
                



                cmp playerTheta                 ; |playerTheta - enemyRayTheta|
                bcs @enemy_ge_ply               ; TODO: to macro
@enemy_lt_ply   lda playerTheta                 ;
                sec                             ;
                sbc objectRayTheta               ;
                                                ;
                jmp @endif                      ;
@enemy_ge_ply   sec                             ;
                sbc playerTheta                 ;
                                                ;
@endif               

                tax
                lda reduceDeltaThetaToHalfAngle,x
                sta deltaTheta
                 
                ; short circuit
                cmp #22                         ; if deltaTheta >= 64 (90)
                bcc @continue                   ; don't render enemy.

                lda #MASKING_SPRITE_PTR+7       ; cover enemy sprite entirely
                sta $07fa                       ; sprite 2 (masking) pointer

                rts                             ; 
        
@continue       inc renderEnemyFlags            ; for now. With more enemies, it should set relevant bit flag                                      

                
; <LUTize>
                lda playerTheta                 ; calculating enemyRayId
                clc                             ; could be negative, when to the left
                adc deltaTheta                  ; of the left-most rayId
                cmp objectRayTheta
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
; </LUTize>                
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
;; cast_object_ray
;;---------------------------------------------
cast_object_ray
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

objectRayTheta=$85
objectRayThetaRed=$84
deltaTheta=$89
objectRayThetaQuadrant=$7c       ; 0 - quadrant iii
                                ; 2 - quadrant iv
                                ; 4 - quadrant ii
                                ; 6 - quadrant i

QUADRANT_I=#3
QUADRANT_II=#2
QUADRANT_III=#0
QUADRANT_IV=#1

objectPlyPosDeltaX=$87
objectPlyPosDeltaY=$88

objectId=$26
; object arrays (3 object at a given time)
objectRayId=$c700
objectPerpDistance=$c703
objectPosX=$c706
objectPosY=$c709
objectAlive=$c70c
objectSpriteColor=$c70f
objectInFOV=$c712

maxPerpDist=$6b 
minPerpDist=$6c
maxPerpId=$81
minPerpId=$82


;;---------------------------------------------
;; init_object_ray_params
;;---------------------------------------------
init_object_ray_params
                lda #0
                sta objectRayThetaQuadrant
                ;sta renderObjectsFlags
                ldy objectId
                sta objectInFOV,y
                ;sta $450,y


                lda posX                        ; calculating enemy-player abs deltaX
                cmp objectPosX,y                  
                bcs @posX_ge                    
@posX_lt                                        ; enemyRay goes right                
                sec
                lda objectPosX,y
                sbc posX
                sta objectPlyPosDeltaX
                
                lda objectRayThetaQuadrant
                ora #%00000010
                sta objectRayThetaQuadrant
                jmp @endif_x
@posX_ge                                        ; enemyRay goes left
                ;sec already setm bcs taken
                sbc objectPosX,y
                sta objectPlyPosDeltaX
                
@endif_x

                lda posY                        ; calculating enemy-player abs deltaY
                cmp objectPosY,y
                bcs @posY_ge
@posY_lt                                        ; enemyRay goes down
                sec
                lda objectPosY,y
                sbc posY
                sta objectPlyPosDeltaY

                lda objectRayThetaQuadrant
                ora #%00000100
                sta objectRayThetaQuadrant
                jmp @endif_y
@posY_ge                                        ; enemyRay goes up
                ;sec already setm bcs taken
                sbc objectPosY,y
                sta objectPlyPosDeltaY
@endif_y


                lda objectPlyPosDeltaY           ; if dx and dy >= 64
                tay                             ;       rescale
                ora objectPlyPosDeltaX           ; else
                and #$C0                        ;       use original values
                beq @lt_64                      ;

                lda lsr_lsr,y                   ;
                ldy objectPlyPosDeltaX           ;
                ldx lsr_lsr_X2,y                ;
                tay                             ;
                jmp @endif_atan                 ;

@lt_64                                          ;
                lda objectPlyPosDeltaX           ;
                asl                             ;
                tax                             ;
                
@endif_atan     
                                
                atan                            ; reduced enemyRayTheta in [0; 64]
                
                ;sta enemyRayTheta              ; no need to save now
                sta objectRayThetaRed            ;
                

                ldx objectRayThetaQuadrant       ; full enemyRayTheta in [0; 256)
                ;lda enemyRayTheta;             ; already in a after atan
                fullObjectRayTheta              ;
                sta objectRayTheta              ;                
                



                cmp playerTheta                  ; |playerTheta - enemyRayTheta|
                bcs @enemy_ge_ply                ; TODO: to macro
@enemy_lt_ply   lda playerTheta                  ;
                sec                              ;
                sbc objectRayTheta               ;
                                                 ;
                jmp @endif                       ;
@enemy_ge_ply   ;sec                             ; already set after bcs
                sbc playerTheta                  ;
                                                 ;
@endif                                           ;
                tax                              ;
                lda reduceDeltaThetaToHalfAngle,x;
                sta deltaTheta                   ;
                 
                ; short circuit
                cmp #24                         ; if deltaTheta >= 24
                bcc @continue                   ; don't render enemy.
                rts                             ; 
        
@continue       ;inc renderObjectsFlags            ; for now. With more enemies, it should set relevant bit flag                                      
                ldx objectId
                inc objectInFOV,x

                ;lda objectInFOV,x
                ;sta $450,x

                lda playerTheta                 ; calculating enemyRayId
                ;clc                            ; could be negative, when to the left
                adc deltaTheta                  ; of the left-most rayId
                cmp objectRayTheta              ; clc clear after bcc
                beq @to_the_right
@to_the_left    lda #20
                sec
                sbc deltaTheta
                jmp @ray_id_end
@to_the_right   lda #20
                clc                            
                adc deltaTheta
@ray_id_end
                ;ldy objectId objectId is still in x
                sta objectRayId,x
                ;sta $450,y       


                ldx objectRayThetaRed
                cpx #32
                bcs @ge_32
@lt_32
                ldy objectPlyPosDeltaX
                lda minusThetaInitCoordX2,y
                ldy reducedTheta_x2,x
                mxOverCos rayCurrDistX_L,rayCurrDistX_H
                ldx objectRayThetaRed
                ldy reducedTheta_x2,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 
                rts
@ge_32
                ldy objectPlyPosDeltaY
                lda minusThetaInitCoordX2,y
                ldy mirrorReducedTheta_x2,x
                mxOverCos rayCurrDistX_L,rayCurrDistX_H

                ldx objectRayThetaRed
                ldy mirrorReducedTheta_x2,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 
                rts

;;---------------------------------------------
;; cast_object_ray
;;---------------------------------------------
cast_object_ray
                ldx objectRayThetaRed
                cpx #32
                bcs @ge_32
@lt_32
                ldx objectPlyPosDeltaX
                jmp @endif_rtr
@ge_32
                ldx objectPlyPosDeltaY
@endif_rtr

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
                ldy objectId
                sta objectPerpDistance,y
                ;sta $428,y
                
                cmp maxPerpDist
                bcs @curr_gt_max
                jmp @minimum
@curr_gt_max    sta maxPerpDist
                ;ldy objectId
                ;sty maxPerpId

@minimum
                
                cmp minPerpDist
                bcc @curr_lt_min
                rts

@curr_lt_min    sta minPerpDist
                ;ldy objectId
                ;sty minPerpId
                rts

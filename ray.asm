rayTheta=$6a

mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e

rayId=$6f
stepYCnt=$70

texture=$75
texture_L=$75
texture_H=$76

rayCurrDistX=$fb
rayCurrDistX_L=$fb
rayCurrDistX_H=$fc

rayCurrDistY=$fd
rayCurrDistY_L=$fd
rayCurrDistY_H=$fe

rayDistDx=$61
rayDistDx_L=$61
rayDistDx_H=$62

rayDistDy=$63
rayDistDy_L=$63
rayDistDy_H=$64

absWallHitXDistX2=$67
absWallHitYDistX2=$68

calculatedAbsWallHitDist=$79
textureMapCode=$7A

rayStart=$C000
rayTextureId=$C028
texColumnOffsets=$C050
prevRayStart=$C078
backBuffer=$C800

CEIL_FLOOR_COLOR=#0


;;---------------------------------------------
;; init_ray_params
;;---------------------------------------------
init_ray_params
                ldy posX
                lda posToMapCoords,y
                sta mapX   
                ldx rayTheta
                lda xPlusTheta,x
                beq @x_minus
@x_plus                 
                        lda plusThetaInitCoordX2,y      ; x2 to index word array
                        sta absWallHitXDistX2           ; x2 to index word array
                        ldy #1
                        sty stepX
                jmp @x_end
@x_minus                
                        lda minusThetaInitCoordX2,y     ; x2 to index word array
                        sta absWallHitXDistX2           ; x2 to index word array
                        ldy #-1
                        sty stepX
@x_end          
                ldy reducedTheta_x2,x
                mxOverCos rayCurrDistX_L,rayCurrDistX_H

                ldy posY
                lda posToMapCoords,y
                sta mapY
                ldx rayTheta
                lda yPlusTheta,x
                beq @y_minus
@y_plus                 
                        lda plusThetaInitCoordX2,y
                        sta absWallHitYDistX2
                        ldy #1
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoordX2,y
                        sta absWallHitYDistX2
                        ldy #-1
                        sty stepY
@y_end          
                ldy mirrorReducedTheta_x2,x
                mxOverCos rayCurrDistY_L,rayCurrDistY_H

                
                ldx rayTheta
                ldy reducedTheta_x2,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 
                
                ldy mirrorReducedTheta_x2,x
                mxOverCosX16 rayDistDy_L,rayDistDy_H 

                rts


;;---------------------------------------------
;; cast_ray
;;---------------------------------------------
cast_ray
                ldy #0
                sty stepYCnt
@loop                   lda rayCurrDistY_H
                        cmp rayCurrDistX_H
                        bcc @y_lt_x
                        bne @y_ge_x
                                lda rayCurrDistY_L
                                cmp rayCurrDistX_L
                        bcs @y_ge_x
@y_lt_x                        
                                ;clc            ; carry not set. bcs not taken
                                lda mapY        ; increase map coordinates
                                adc stepY       ; 
                                sta mapY        ; 
                                
                                tax                     ; check if hit on a horizontal
                                lda mapCoordsToPos,x    ; gridline
                                clc                     ; 
                                adc mapX                ; 
                                tax                     ; 
                                lda game_map,x          ; 
                                sta textureMapCode      ; save texture code
                                bne @final_res_b        ; 

                                clc                     ; if not hit
                                lda rayCurrDistY_L      ; increase rayCurrDistY
                                adc rayDistDy_L         ; 
                                sta rayCurrDistY_L      ; 
                                lda rayCurrDistY_H      ; 
                                adc rayDistDy_H         ; 
                                sta rayCurrDistY_H      ; 

                                ;lda absWallHitYDistX2   ; increase absWallHitYDist
                                ;clc                    ; previous addition should never overflow
                                ;adc #SQUARE_SIZE_X2     ; 
                                ;sta absWallHitYDistX2   ; 
                                inc stepYCnt
                                jmp @loop    
@y_ge_x                         
                                clc             ; increase map coordinates
                                lda mapX        ; 
                                adc stepX       ;
                                sta mapX        ;
                               
                                clc                     ; check if hit on a vertical
                                ldx mapY                ; gridline
                                adc mapCoordsToPos,x    ;
                                tax                     ;
                                lda game_map,x          ;
                                sta textureMapCode      ; save texture code
                                bne @final_res_a        ;

                                clc                     ; if not hit
                                lda rayCurrDistX_L      ; increase rayCurrDistX
                                adc rayDistDx_L         ; 
                                sta rayCurrDistX_L      ; 
                                lda rayCurrDistX_H      ; 
                                adc rayDistDx_H         ; 
                                sta rayCurrDistX_H      ; 
                                iny                     ; counts number of x steps
                                ;lda absWallHitXDistX2   ; increase absWallHitXDist
                                ;clc                    ; previous addition should never overlfow
                                ;adc #SQUARE_SIZE_X2     ;
                                ;sta absWallHitXDistX2   ;
                                jmp @loop

; vertical gridline hit
@final_res_b    
                ldy rayId                ; absolute difference between rayTheta and
                ldx absThetaDistX2,y     ; playerTheta x2 (indexes word vector)
                

                lda rayCurrDistY_L      ; coputing vertical line starting point
                asl                     ; bit 7 -> 0
                lda #0                  ;
                adc #0                  ;
                aso rayCurrDistY_H      ; asl rayCurrDistY_H
                                        ; ora rayCurrDistY_H
                lineStartRow            ;

                lda absWallHitYDistX2           ; calculating absWallHitDist
                clc
                ldx stepYCnt
                adc yTimesSquareSizeX2,x        ; initial absWallHitYDistX2 + 
                ldx rayTheta                    ; SquareSizeX2 * num of y-steps
                ldy reducedTheta,x              ; 
                xOverTan                        ; 
                sta calculatedAbsWallHitDist    ; 

                ldx rayTheta                    ; add or subtract calculatedAbsWallHitDist
                lda xPlusTheta,x                ; to / from posX
                beq @x_minus
@x_plus                 
                lda posX
                clc
                adc calculatedAbsWallHitDist
                jmp @x_end
@x_minus                
                lda posX
                sec
                sbc calculatedAbsWallHitDist
@x_end   
                tax                             ; calculate offset in texture to
                ldy posMod16,x                  ; the start of vertical strip hit by the ray
                ldx rayId                       ; 
                lda texColumnOffset,y           ; 
                sta texColumnOffsets,x          ; 
                lda textureMapCode              ; subtract 1 to get dark version of the texture
                sec                             ;
                sbc #1                          ;
                sta rayTextureId,x              ; store texture id
                rts

; horizontal gridline hit
@final_res_a    
                lda absWallHitXDistX2           ; calculating absWallHitDist
                clc
                adc yTimesSquareSizeX2,y        ; initial absWallHitXDistX2 + 
                ldx rayTheta                    ; SquareSizeX2 * num of x-steps
                ldy mirrorReducedTheta,x        ; 
                xOverTan                        ;
                sta calculatedAbsWallHitDist    ;
                ldy rayId                ; absolute difference between rayTheta and
                ldx absThetaDistX2,y     ; playerTheta x2 (indexes word vector)

                lda rayCurrDistX_L      ; computing vertical line starting point
                asl                     ; bit 7 -> 0
                lda #0                  ;
                adc #0                  ;
                aso rayCurrDistX_H      ; asl rayCurrDistX_H
                                        ; ora rayCurrDistX_H
                lineStartRow            ;

                ldx rayTheta                    ; add or subtract calculatedAbsWallHitDist
                lda yPlusTheta,x                ; to / from posY
                beq @y_minus                    
@y_plus                 
                lda posY
                clc
                adc calculatedAbsWallHitDist
                jmp @y_end
@y_minus                
                lda posY
                sec
                sbc calculatedAbsWallHitDist
@y_end   

                tax                             ; calculate offset in texture to
                ldy posMod16,x                  ; the start of vertical strip hit by the ray
                ldx rayId                       ;                            
                lda texColumnOffset,y           ;
                sta texColumnOffsets,x          ;
                lda textureMapCode              ; add 1 to get light version of the texture
                clc                             ;
                adc #1                          ;
                sta rayTextureId,x              ; store texture id
                rts





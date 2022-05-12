rayTheta=$6a

mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e

rayId=$6f
thetaRayZero=$70

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

absWallHitXDist=$67
absWallHitYDist=$68

calculatedAbsWallHitDist=$79

rayStart=$C000
rayTextureId=$C028
texColumnOffsets=$C050
backBuffer=$C800

TEXTURE_1_ID=#0
TEXTURE_2_ID=#2
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
                        lda plusThetaInitCoord,y
                        sta absWallHitXDist
                        lsr absWallHitXDist
                        ldy #1
                        sty stepX
                jmp @x_end
@x_minus                
                        lda minusThetaInitCoord,y
                        sta absWallHitXDist
                        lsr absWallHitXDist
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
                        lda plusThetaInitCoord,y
                        sta absWallHitYDist
                        lsr absWallHitYDist
                        ldy #1
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoord,y
                        sta absWallHitYDist
                        lsr absWallHitYDist
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
@loop                   lda rayCurrDistY_H
                        cmp rayCurrDistX_H
                        bcc @y_lt_x
                        bne @y_ge_x
                                lda rayCurrDistY_L
                                cmp rayCurrDistX_L
                        bcs @y_ge_x
@y_lt_x                        
                                clc
                                lda mapY
                                adc stepY
                                sta mapY
                                
                                tax
                                lda mapCoordsToPos,x
                                
                                clc
                                adc mapX
                                tax
                                lda game_map,x
                                bne @final_res_b

                                clc
                                lda rayCurrDistY_L
                                adc rayDistDy_L
                                sta rayCurrDistY_L
                                lda rayCurrDistY_H
                                adc rayDistDy_H
                                sta rayCurrDistY_H

                                lda absWallHitYDist
                                clc
                                adc #16
                                sta absWallHitYDist
                                jmp @loop    
@y_ge_x                         
                                clc
                                lda mapX
                                adc stepX
                                sta mapX
                                
                                clc
                                ldx mapY
                                adc mapCoordsToPos,x
                                
                                tax
                                lda game_map,x
                                bne @final_res_a

                                clc
                                lda rayCurrDistX_L
                                adc rayDistDx_L
                                sta rayCurrDistX_L
                                lda rayCurrDistX_H
                                adc rayDistDx_H
                                sta rayCurrDistX_H

                                lda absWallHitXDist
                                clc
                                adc #16
                                sta absWallHitXDist
                                jmp @loop                   

@final_res_b    lda rayTheta
                sec
                sbc playerTheta
                tay
                ldx absThetaDist,y

                lda rayCurrDistY_L
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                
                aso rayCurrDistY_H
                ;asl E_16_H
                ;ora E_16_H
                lineStartRow

                lda absWallHitYDist
                asl
                ldx rayTheta
                ldy reducedTheta,x
                xOverTan
                sta calculatedAbsWallHitDist
                ldx rayTheta
                lda xPlusTheta,x
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
                tax
                lda posMod16,x
                ldx rayId
                
                tay
                lda texColumnOffset,y
                sta texColumnOffsets,x
                lda TEXTURE_1_ID
                sta rayTextureId,x
                ; load texture
                rts

@final_res_a    lda rayTheta
                sec
                sbc playerTheta
                tay
                ldx absThetaDist,y

                lda rayCurrDistX_L      ; final dist max 0x7fff
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                aso rayCurrDistX_H
                ;asl E_16_H
                ;ora E_16_H
                lineStartRow 
               
                lda absWallHitXDist
                asl
                ldx rayTheta
                ldy mirrorReducedTheta,x
                xOverTan
                sta calculatedAbsWallHitDist
                ldx rayTheta
                lda yPlusTheta,x
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

                tax
                lda posMod16,x
                ldx rayId
                
                tay
                lda texColumnOffset,y
                sta texColumnOffsets,x
                ; load texture
                lda TEXTURE_2_ID
                sta rayTextureId,x
                rts

















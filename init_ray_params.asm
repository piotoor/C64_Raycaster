;;---------------------------------------------
;; init_ray_params
;;---------------------------------------------
;init_ray_params
                ldy posY
                lda posCoordsToOffset,y
                ldy posX
                clc
                adc posToMapCoords,y
                sta gameMapOffset
                
                ldx rayTheta
                lda xPlusTheta,x
                beq @x_minus
@x_plus                 
                        lda plusThetaInitCoord,y
                        sta absWallHitXDist
                        ldy #1
                        sty stepX
                jmp @x_end
@x_minus                
                        lda minusThetaInitCoord,y
                        sta absWallHitXDist
                        ldy #-1
                        sty stepX
@x_end          
                ldy reducedTheta_x2,x
                
                mxOverCos rayCurrDistX_L,rayCurrDistX_H

                ldy posY
                ldx rayTheta
                lda yPlusTheta,x
                beq @y_minus
@y_plus                 
                        lda plusThetaInitCoord,y
                        sta absWallHitYDist
                        ldy #MAP_HEIGHT
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoord,y
                        sta absWallHitYDist
                        ldy #-16
                        sty stepY
@y_end          
                ldy mirrorReducedTheta_x2,x
                
                mxOverCos rayCurrDistY_L,rayCurrDistY_H

                
                ldx rayTheta
                ldy reducedTheta,x 
                mxOverCosX16 rayDistDx_L,rayDistDx_H 
                
                ldy mirrorReducedTheta,x
                mxOverCosX16 rayDistDy_L,rayDistDy_H 
                ; rts
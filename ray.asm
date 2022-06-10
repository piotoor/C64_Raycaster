rayTheta=$6a

stepX=$6d
stepY=$6e

rayId=$6f
stepYCnt=$70
gameMapOffset=$7e

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
;textureMapCode=$7A             FREE MEM

rayStart=$C500
rayTextureId=$C528
texColumnOffsets=$C550
prevRayStart=$C578
rayPerpDistance=$C5A0
; virual rays used to simplify enemy sprite visibility calculations at screen borders
; C5C8, C5C9, C5CA, C5CB (virtual rays 40, 41, 42, 43)
; C69F, C6A0, C6A1, C6A2 (wirtual rays -1, -2, -3, -4)
;
backBuffer=$C800

CEIL_FLOOR_COLOR=#0


;;---------------------------------------------
;; init_ray_params
;;---------------------------------------------
init_ray_params
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
                ldx rayTheta
                lda yPlusTheta,x
                beq @y_minus
@y_plus                 
                        lda plusThetaInitCoordX2,y
                        sta absWallHitYDistX2
                        ldy #MAP_HEIGHT
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoordX2,y
                        sta absWallHitYDistX2
                        ldy #-16
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
                                lda gameMapOffset       
                                clc
                                adc stepY
                                tax
                                sta gameMapOffset
                                
                                lda game_map,x          ; 
                                bne @final_res_b        ; 

                                clc                     ; if not hit
                                lda rayCurrDistY_L      ; increase rayCurrDistY
                                adc rayDistDy_L         ; 
                                sta rayCurrDistY_L      ; 
                                lda rayCurrDistY_H      ; 
                                adc rayDistDy_H         ; 
                                sta rayCurrDistY_H      ; 

                                inc stepYCnt            ; counts number of y steps
                                jmp @loop    
@y_ge_x                         
                                lda gameMapOffset
                                clc
                                adc stepX
                                tax
                                sta gameMapOffset

                                lda game_map,x          ;
                                bne @final_res_a        ;

                                clc                     ; if not hit
                                lda rayCurrDistX_L      ; increase rayCurrDistX
                                adc rayDistDx_L         ; 
                                sta rayCurrDistX_L      ; 
                                lda rayCurrDistX_H      ; 
                                adc rayDistDx_H         ; 
                                sta rayCurrDistX_H      ; 
                                
                                iny                     ; counts number of x steps
                                jmp @loop

; vertical gridline hit
@final_res_b    
                ;sta textureMapCode             ; save texture code
                ;lda textureMapCode             ; subtract 1 to get dark version of the texture
                sec                             ;
                sbc #1                          ;
                ldy rayId                       ;
                sta rayTextureId,y              ; store texture id
        
                ;ldy rayId               ; absolute difference between rayTheta and
                ldx absThetaDistX2,y     ; playerTheta x2 (indexes word vector)
                

                asl rayCurrDistY_L      ; coputing vertical line starting point
                                        ; bit 7 -> 0
                lda #0                  ;
                adc #0                  ;
                aso rayCurrDistY_H      ; asl rayCurrDistY_H
                                        ; ora rayCurrDistY_H
                lineStartRow            ;

                lda absWallHitYDistX2           ; calculating absWallHitDist
                
                ldx stepYCnt
                adc yTimesSquareSizeX2,x        ; initial absWallHitYDistX2 + 
                ldx rayTheta                    ; SquareSizeX2 * num of y-steps
                ldy reducedTheta,x              ; 
                xOverTan                        ; 
                sta calculatedAbsWallHitDist    ; 

                ldx rayTheta                   ; add or subtract calculatedAbsWallHitDist
                lda posX                        ; extracted from branch to save 1 byte
                ldy xPlusTheta,x                ; to / from posX
                beq @x_minus
@x_plus                 
                ;lda posX
                clc
                adc calculatedAbsWallHitDist
                jmp @x_end
@x_minus                
                ;lda posX
                sec
                sbc calculatedAbsWallHitDist
@x_end   
                tax                             ; calculate offset in texture to
                ldy posMod16,x                  ; the start of vertical strip hit by the ray
                ldx rayId                       ; 
                lda texColumnOffset,y           ; 
                sta texColumnOffsets,x          ; 
                rts

; horizontal gridline hit
@final_res_a    
                ;sta textureMapCode              ; save texture code
                ;lda textureMapCode              ; add 1 to get light version of the texture
                clc                             ;
                adc #1                          ;
                ldx rayId                       ;
                sta rayTextureId,x              ; store texture id

                lda absWallHitXDistX2           ; calculating absWallHitDist
                clc
                adc yTimesSquareSizeX2,y        ; initial absWallHitXDistX2 + 
                ldx rayTheta                    ; SquareSizeX2 * num of x-steps
                ldy mirrorReducedTheta,x        ; 
                xOverTan                        ;
                sta calculatedAbsWallHitDist    ;
                ldy rayId                ; absolute difference between rayTheta and
                ldx absThetaDistX2,y     ; playerTheta x2 (indexes word vector)
                
                asl rayCurrDistX_L      ; computing vertical line starting point
                ;asl                     ; bit 7 -> 0
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
                rts





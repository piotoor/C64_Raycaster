rayTheta=$6a
mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e
ray_id=$6f
theta_ray_zero=$70
ray_start=$C000
ray_color=$C028
back_buff=$C800
color1=#8
color2=#9
ceil_color=#0
floor_color=#11

;;---------------------------------------------
;; init_ray_params
;;
;; A_16 - currDistX
;; B_16 - currDistY
;; C_16 - dx
;; D_16 - dy
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
                        ldy #1
                        sty stepX
                jmp @x_end
@x_minus                
                        lda minusThetaInitCoord,y
                        ldy #-1
                        sty stepX
@x_end          
                ldy reducedTheta_x2,x
                mxOverCos A_16_L,A_16_H

                ldy posY
                lda posToMapCoords,y
                sta mapY
                ldx rayTheta
                lda yPlusTheta,x
                beq @y_minus
@y_plus                 
                        lda plusThetaInitCoord,y
                        ldy #1
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoord,y
                        ldy #-1
                        sty stepY
@y_end          
                ldy mirrorReducedTheta_x2,x
                mxOverCos B_16_L,B_16_H

                
                ldx rayTheta
                ldy reducedTheta_x2,x 
                mxOverCosX16 C_16_L,C_16_H 
                
                ldy mirrorReducedTheta_x2,x
                mxOverCosX16 D_16_L,D_16_H 

                rts


;;---------------------------------------------
;; cast_ray
;;
;; A_16 - currDistX
;; B_16 - currDistY
;; E_16 - finalDist
;; C_16 - dx
;; D_16 - dy
;;---------------------------------------------
cast_ray
@loop                   lda B_16_H
                        cmp A_16_H
                        bcc @y_lt_x
                        bne @y_ge_x
                                lda B_16_L
                                cmp A_16_L
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
                                lda B_16_L
                                adc D_16_L
                                sta B_16_L
                                lda B_16_H
                                adc D_16_H
                                sta B_16_H
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
                                lda A_16_L
                                adc C_16_L
                                sta A_16_L
                                lda A_16_H
                                adc C_16_H
                                sta A_16_H
                                jmp @loop                   

@final_res_a    lda A_16_L
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                aso A_16_H
                ;asl E_16_H
                ;ora E_16_H
                tay
                lda lineStartRow,y

                ldx ray_id
                sta ray_start,x

                lda color2
                sta ray_color,x
                rts

@final_res_b    lda B_16_L
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                
                aso B_16_H
                ;asl E_16_H
                ;ora E_16_H
                tay
                lda lineStartRow,y

                ldx ray_id
                sta ray_start,x

                lda color1
                sta ray_color,x
                rts
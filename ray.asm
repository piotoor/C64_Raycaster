rayTheta=$6a
mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e
ray_id=$6f
horizontal=$70
ray_start=$C000
ray_color=$C050
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
                lda #1
                sta stepX
                sta stepY
                
                ldx posX
                lda posToMapCoords,x
                sta mapX   
                ldx rayTheta
                ldy xPlusTheta,x
                beq @x_minus
@x_plus                 ldx posX
                        lda plusThetaInitCoord,x
                jmp @x_end
@x_minus                ldx #-1
                        stx stepX
                        ldx posX
                        lda minusThetaInitCoord,x
@x_end          ldx rayTheta
                ldy reducedTheta,x
                mxOverCos A_16_L,A_16_H

                ldx posY
                lda posToMapCoords,x
                sta mapY
                ldx rayTheta
                ldy yPlusTheta,x
                beq @y_minus
@y_plus                 ldx posY
                        lda plusThetaInitCoord,x
                jmp @y_end
@y_minus                ldx #-1
                        stx stepY
                        ldx posY
                        lda minusThetaInitCoord,x
@y_end          ldx rayTheta
                ldy mirrorReducedTheta,x
                mxOverCos B_16_L,B_16_H

                lda square_size
                ldx rayTheta
                ldy reducedTheta,x 
                mxOverCos C_16_L,C_16_H 
                lda square_size
                ldx rayTheta
                ldy mirrorReducedTheta,x
                mxOverCos D_16_L,D_16_H 

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
                                
                                ldx mapY
                                lda mapCoordsToPos,x
                                
                                clc
                                adc mapX
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

@final_res_a    lda color2
                ldx ray_id
                sta ray_color,x

                lda A_16_H
                sta E_16_H
                lda A_16_L
                sta E_16_L

                rts
@final_res_b    lda color1
                ldx ray_id
                sta ray_color,x

                lda B_16_H
                sta E_16_H
                lda B_16_L
                sta E_16_L
                rts

;;---------------------------------------------
;; compute_line
;;
;; E_16 - finalDist
;; ray_start
;; ray_color
;; a - lineHeight
;;---------------------------------------------
compute_line
                ;lda E_16_L
                asl     ; bit 7 -> 0
                lda #0  ;
                adc #0  ;
                
                aso E_16_H
                ;asl E_16_H
                ;ora E_16_H
                tax

                lda lineStartRow,x

                ldx ray_id
                sta ray_start,x
                rts
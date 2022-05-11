rayTheta=$6a
mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e
ray_id=$6f
theta_ray_zero=$70

ray_start=$C000
ray_color=$C028
tex_column_offsets=$C050
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
;;
;; c_8  - abs(wallHitXDist)
;; d_8  - abs(wallHitYDist)
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
                        sta c_8
                        lsr c_8
                        ldy #1
                        sty stepX
                jmp @x_end
@x_minus                
                        lda minusThetaInitCoord,y
                        sta c_8
                        lsr c_8
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
                        sta d_8
                        lsr d_8
                        ldy #1
                        sty stepY
                jmp @y_end
@y_minus                
                        lda minusThetaInitCoord,y
                        sta d_8
                        lsr d_8
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

                                lda d_8
                                clc
                                adc #16
                                sta d_8
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

                                lda c_8
                                clc
                                adc #16
                                sta c_8
                                jmp @loop                   

@final_res_b    lda rayTheta
                sec
                sbc theta
                tay
                ldx absThetaDist,y

                lda B_16_L
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                
                aso B_16_H
                ;asl E_16_H
                ;ora E_16_H
                lineStartRow

                ;lda color1
                ;sta ray_color,x
                
                ;lda c_8
;                ldx ray_id
;                sta $400,x
;                lda d_8
;                sta $428,x
                lda d_8
                asl
                ldx rayTheta
                ldy reducedTheta,x
                xOverTan
                sta e_8
;                ;debug----------
;                ldx ray_id
;                sta $400,x
;                tya
;                sta $428,x
;                ;debug----------
                ldx rayTheta
                lda xPlusTheta,x
                beq @x_minus
@x_plus                 
                lda posX
                clc
                adc e_8
                jmp @x_end
@x_minus                
                lda posX
                sec
                sbc e_8
@x_end   
                ;ldx mapX
                ;sec
                ;sbc mapCoordsToPos,x
                tax
                lda posMod16,x
                ldx ray_id
                ;sta $400,x
                tay
                lda texColumnOffset,y
                sta tex_column_offsets,x
                ;sta $400,x
                rts

@final_res_a    lda rayTheta
                sec
                sbc theta
                tay
                ldx absThetaDist,y

                lda A_16_L      ; final dist max 0x7fff
                asl             ; bit 7 -> 0
                lda #0          ;
                adc #0          ;
                aso A_16_H
                ;asl E_16_H
                ;ora E_16_H
                lineStartRow 
               
                ;lda color2
                ;sta ray_color,x

;                lda c_8
;                ldx ray_id
;                sta $400,x
;                lda d_8
;                sta $428,x
                lda c_8
                asl
                ldx rayTheta
                ldy mirrorReducedTheta,x
                xOverTan
                sta e_8
;                ;debug----------
;                ldx ray_id
;                sta $400,x
;                tya
;                sta $428,x
;                ;debug----------
                ldx rayTheta
                lda yPlusTheta,x
                beq @y_minus
@y_plus                 
                lda posY
                clc
                adc e_8
                jmp @y_end
@y_minus                
                lda posY
                sec
                sbc e_8
@y_end   
;                ldx mapY
;                sec
;                sbc mapCoordsToPos,x
                tax
                lda posMod16,x
                ldx ray_id
                
                tay
                lda texColumnOffset,y
                sta tex_column_offsets,x
                ;sta $400,x
                rts



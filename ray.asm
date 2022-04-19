rayTheta=$6a
mapX=$6b
mapY=$6c
stepX=$6d
stepY=$6e
ray_id=$6f
horizontal=$70
ray_start=$C000
ray_end=$C028
ray_color=$C050


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
                
                lda posX
                lsr
                lsr
                lsr
                lsr
                sta mapX   
                ldx rayTheta
                ldy xPlusTheta,x
                beq @x_minus
@x_plus         clc
                adc #1
                asl
                asl
                asl
                asl
                sec
                sbc mapX
                jmp @x_end
@x_minus        dec stepX
                dec stepX
                asl
                asl
                asl
                asl
                sta b_8
                lda mapX
                sec
                sbc b_8
@x_end          ldy rayTheta
                ldx reducedTheta,y
                mxOverCos A_16_L,A_16_H

                lda posY
                lsr
                lsr
                lsr
                lsr
                sta mapY
                ldx rayTheta
                ldy yPlusTheta,x
                beq @y_minus
@y_plus         clc
                adc #1
                asl
                asl
                asl
                asl
                sec
                sbc mapY
                jmp @y_end
@y_minus        dec stepY
                dec stepY
                asl
                asl
                asl
                asl
                sta b_8
                lda mapY
                sec
                sbc b_8
                
@y_end          ldy rayTheta
                ldx mirrorReducedTheta,y
                mxOverCos B_16_L,B_16_H

                lda square_size
                ldy rayTheta
                ldx reducedTheta,y 
                mxOverCos C_16_L,C_16_H 
                lda square_size
                ldy rayTheta
                ldx mirrorReducedTheta,y 
                mxOverCos D_16_L,D_16_H 

                rts


;;---------------------------------------------
;; init_ray_params
;;
;; A_16 - currDistX
;; B_16 - currDistY
;; E_16 - finalDist
;; C_16 - dx
;; D_16 - dy
;;---------------------------------------------
cast_ray
                lda #8
                sta horizontal
@loop           lda B_16_H
                cmp A_16_H
                bcc @y_lt_x
                bne @y_ge_x
                lda B_16_L
                cmp A_16_L
                bcs @y_ge_x

@y_lt_x         lda #8
                sta horizontal

                lda B_16_H
                sta E_16_H
                lda B_16_L
                sta E_16_L

                clc
                lda B_16_L
                adc D_16_L
                sta B_16_L
                lda B_16_H
                adc D_16_H
                sta B_16_H

                clc
                lda mapY
                adc stepY
                sta mapY

                jmp @end
@y_ge_x         lda #9
                sta horizontal

                lda A_16_H
                sta E_16_H
                lda A_16_L
                sta E_16_L

                clc
                lda A_16_L
                adc C_16_L
                sta A_16_L
                lda A_16_H
                adc C_16_H
                sta A_16_H

                clc
                lda mapX
                adc stepX
                sta mapX
               
@end            lda mapY
                asl
                asl
                asl
                asl
                clc
                adc mapX
                tax
                lda game_map,x
                beq @loop
                rts

;;---------------------------------------------
;; compute_line
;;
;; E_16 - finalDist
;; ray_start
;; ray_end
;; ray_color
;; a - lineHeight
;;---------------------------------------------
compute_line
                ldx #7
@loop           lda E_16_H
                clc
                lsr
                sta E_16_H
                lda E_16_L
                ror
                sta E_16_L
                dex
                bne @loop

                lda E_16_H
                beq @lineHeight1
                ldx E_16_L
                lda halfLineHeight,x
                jmp @lineHeightDone
@lineHeight1    adc #1               

@lineHeightDone clc
                adc #12
                ldx ray_id
                sta ray_end,x

                ldx E_16_L
                sec
                sbc halfLineHeight,x
                sbc halfLineHeight,x
                ldx ray_id
                sta ray_start,x
                lda horizontal

                sta ray_color,x
                rts
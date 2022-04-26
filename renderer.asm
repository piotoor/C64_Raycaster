;;---------------------------------------------
;; compute_frame
;;
;; Raycasting is done there, in three steps
;;---------------------------------------------
compute_frame   
                ldx #39; screen_width - 1
@loop                   stx ray_id
                        lda theta
                        sec
                        sbc half_fov
                        adc ray_id
                        sta rayTheta

                        jsr init_ray_params
                        jsr cast_ray
                        jsr compute_line

                        ldx ray_id
                dex 
                bpl @loop
                rts

;;---------------------------------------------
;; draw_frame
;;
;; Renders frame row by row.
;; Only upper half of the screen is calculated
;; Lower part is just a mirror.
;; Uses:
;; - F_16 - pointer to "upper-part" of the color_buffer
;; - G_16 - pointer to "lower-part" of the color_buffer
;; - ray_start
;; - ray_color
;;---------------------------------------------
draw_frame      
                
                ldx #12
@rows                   ; update lower half pointer
                        lda colorRamLowerL,x
                        sta G_16_L
                        lda colorRamLowerH,x
                        sta G_16_H

                        ; update upper part pointer
                        lda colorRamUpperL,x
                        sta F_16_L
                        lda colorRamUpperH,x
                        sta F_16_H

                        ldy #39 ; screen_width - 1
@cols                           clc
                                txa
                                cmp ray_start,y
                                bcs @draw_walls
@draw_ceil_and_floor            lda ceil_color
                                sta (F_16),y
                                lda floor_color
                                sta (G_16),y
                                jmp @end
@draw_walls                     lda ray_color,y  
                                sta (F_16),y
                                sta (G_16),y
@end                           

                        dey
                        bpl @cols
                        


                dex
                bpl @rows
                rts

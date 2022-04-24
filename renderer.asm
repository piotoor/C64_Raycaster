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
;; Uses:
;; - F_16
;; - ray_start
;; - ray_end
;; - ray_color
;;---------------------------------------------
draw_frame      
                lda #$00
                sta F_16_L
                lda #$d8
                sta F_16_H
                ldx #0
@rows                   ldy #0
@cols                           clc
                                txa
                                cmp ray_start,y
                                bcs @x_ge_ray_start
                                lda ceil_color
                                jmp @draw
@x_ge_ray_start                 clc
                                cmp ray_end,y
                                lda ray_color,y
                                bcc @draw
                                lda floor_color
@draw                           sta (F_16),y

                        iny
                        cpy screen_width
                        bne @cols
                        
                        lda F_16_L
                        clc
                        adc #$28
                        sta F_16_L
                        lda F_16_H
                        adc #0
                        sta F_16_H

                inx
                cpx screen_height
                bne @rows
                rts

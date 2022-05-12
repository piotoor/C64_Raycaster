A_16=$fb
A_16_L=$fb
A_16_H=$fc

B_16=$fd
B_16_L=$fd
B_16_H=$fe

C_16=$61
C_16_L=$61
C_16_H=$62

D_16=$63
D_16_L=$63
D_16_H=$64

E_16=$65
E_16_L=$65
E_16_H=$66



c_8=$67
d_8=$68
e_8=$79
f_8=$74
g_8=$77


;F_16=$68
;F_16_L=$68
;F_16_H=$69

;G_16=$74
;G_16_L=$74
;G_16_H=$75


;;---------------------------------------------
;; mxOverCos target_L,target_H 
;; x in a
;; theta in y
;;--------------------------------------------- 
defm mxOverCos 
        tax
        lda mxOverCosVect,x
        sta E_16_L
        inx
        lda mxOverCosVect,x
        sta E_16_H
        
        lda (E_16),y
        sta /1
        iny
        lda (E_16),y
        sta /2
        endm


;;---------------------------------------------
;; mxOverCosX16 target_L,target_H 
;; special case
;; x = 16
;; theta in y
;;--------------------------------------------- 
defm mxOverCosX16        
        lda mxOverCos_16,y
        sta /1
        iny
        lda mxOverCos_16,y
        sta /2
        endm

;;---------------------------------------------
;; lineStartRow target
;; dist in a
;; theta in x
;; returns line height with fisheye distortion correction
;;--------------------------------------------- 
defm lineStartRow 

        ldy lineStartRowVect,x
        sty E_16_L
        inx
        ldy lineStartRowVect,x
        sty E_16_H
        
        tay
        ldx ray_id

        lda (E_16),y        
        sta ray_start,x
        
        endm

;;---------------------------------------------
;; xOverTan target
;; x in a
;; theta in y
;; result in a
;;--------------------------------------------- 
defm xOverTan 
        tax
        lda xOverTanVect,x
        sta E_16_L
        inx
        lda xOverTanVect,x
        sta E_16_H
        
        lda (E_16),y
        ;sta /1
        endm

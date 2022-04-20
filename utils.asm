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

b_8=$67

F_16=$68
F_16_L=$68
F_16_H=$69

;zero page locations safe to use:
;$02-$06
;$fb-$fe

;;---------------------------------------------
;; Adds B_16 to A_16
;;--------------------------------------------- 
defm adc_a16_b16
        clc
        lda A_16_L
        adc B_16_L
        sta A_16_L
        lda A_16_H
        adc B_16_H
        sta A_16_H

        endm

;;---------------------------------------------
;; mxOverCos target_L,target_H 
;; x in a
;; theta in y
;;--------------------------------------------- 
defm mxOverCos 
        asl
        tax
        lda mxOverCosVect,x
        sta F_16_L
        inx
        lda mxOverCosVect,x
        sta F_16_H
        
        tya
        asl
        tay
        lda (F_16),y
        sta /1
        iny
        lda (F_16),y
        sta /2
        endm


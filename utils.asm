A_16=$fb
A_16_L=$fb
A_16_H=$fc

B_16=$fd
B_16_L=$fd
B_16_H=$fe

TMP_16=$02
TMP_16_L=$02
TMP_16_H=$03


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
;; mxOverCos x,theta into A_16
;;--------------------------------------------- 
defm mxOverCos 
        lda /1
        asl
        tax
        lda mxOverCosVect,x
        sta TMP_16_L
        inx
        lda mxOverCosVect,x
        sta TMP_16_H
        
        lda /2
        asl
        tay
        lda (TMP_16),y
        sta A_16_L
        iny
        lda (TMP_16),y
        sta A_16_H
        endm

incasm          lookuptables.asm
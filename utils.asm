A_16=$fb
A_16_L=$fb
A_16_H=$fc

B_16=$fd
B_16_L=$fd
B_16_H=$fe

defm add_a16_b16
        clc
        lda A_16_L
        adc B_16_L
        sta A_16_L
        lda A_16_H
        adc B_16_H
        sta A_16_H

        endm
E_16=$65
E_16_L=$65
E_16_H=$66

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
;defm lineStartRow 

;        ldy lineStartRowVect,x
;        sty E_16_L
;        inx
;        ldy lineStartRowVect,x
;        sty E_16_H
;        
;        tay
;        ldx rayId
;        lda rayStart,x
;        sta prevRayStart,x
;        lda (E_16),y        
;        sta rayStart,x
;        
;        endm

defm lineStartRow 
        ldy perpDistanceVect,x
        sty E_16_L
        inx
        ldy perpDistanceVect,x
        sty E_16_H
        
        tay
        ldx rayId
        lda rayStart,x
        sta prevRayStart,x
        lda (E_16),y 
        sta rayPerpDistance,x
        tay
        lda lineStartRowLut,y
        sta rayStart,x
        
        endm

;;---------------------------------------------
;; perpDistance
;; dist in a
;; theta in x
;; returns perpendicular distance (/2)
;;--------------------------------------------- 
defm perpDistance 
        ldy perpDistanceVect,x
        sty E_16_L
        inx
        ldy perpDistanceVect,x
        sty E_16_H
        
        tay
        lda (E_16),y 
        endm


;;---------------------------------------------
;; xOverTan
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


;;---------------------------------------------
;; atan
;; x in x
;; y in y
;; result in a
;;--------------------------------------------- 
defm atan 
        lda atanVect,x
        sta E_16_L
        inx
        lda atanVect,x
        sta E_16_H
        
        lda (E_16),y
        endm

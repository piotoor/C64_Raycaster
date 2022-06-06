E_16=$65
E_16_L=$65
E_16_H=$66

;;---------------------------------------------
;; mxOverCos target_L,target_H 
;; x in a
;; theta in y   ; must be x2
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
;; theta in y   ; must be x2
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
;; theta in x   ; must be x2
;; 
;; returns line height with fisheye distortion correction
;; result in a
;;--------------------------------------------- 
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
;; theta in x   ; must be x2
;;
;; returns perpendicular distance (/2)
;; result in a
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
;; x in a       ; must be x2
;; theta in y
;;
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
        endm

;;---------------------------------------------
;; atan
;; x in x       ; must be x2
;; y in y
;;
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


;;---------------------------------------------
;; fullObjectRayTheta
;; 
;; quadrant in x        must be x2
;; theta in a
;;
;; returns full object ray angle 
;; result in a
;;--------------------------------------------- 
defm fullObjectRayTheta 
        ldy fullObjectRayThetaVect,x
        sty E_16_L
        inx
        ldy fullObjectRayThetaVect,x
        sty E_16_H
        
        tay
        lda (E_16),y 
        endm
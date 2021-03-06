E_16=$65
E_16_L=$65
E_16_H=$66

f_8=$74
g_8=$77
;;---------------------------------------------
;; mxOverCos target_L,target_H 
;; x in a
;; theta in y
;;--------------------------------------------- 
defm mxOverCos 
        tax
        lda mxOverCosVectL,x
        sta E_16_L
        lda mxOverCosVectH,x
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
        lda mxOverCos_16_L,y
        sta /1
        lda mxOverCos_16_H,y
        sta /2
        endm

;;---------------------------------------------
;; mxOverCosX8 target_L,target_H 
;; special case
;; x = 8
;; theta in y   ; must be x2
;;--------------------------------------------- 
defm mxOverCosX8      
        lda mxOverCos_8_L,y
        sta /1
        lda mxOverCos_8_H,y
        sta /2
        endm

;;---------------------------------------------
;; lineStartRow
;; dist in a
;; theta in x
;; 
;; returns line height with fisheye distortion correction
;; result in a
;;--------------------------------------------- 
defm lineStartRow 
        ldy perpDistanceVectL,x
        sty E_16_L
        ldy perpDistanceVectH,x
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
;;
;; returns perpendicular distance (/2)
;; result in a
;;--------------------------------------------- 
defm perpDistance 
        ldy perpDistanceVectL,x
        sty E_16_L
        ldy perpDistanceVectH,x
        sty E_16_H
        
        tay
        lda (E_16),y 
        endm

;;---------------------------------------------
;; xOverTan
;; x in a
;; theta in y
;;
;; result in a
;;--------------------------------------------- 
defm xOverTan 
        tax
        lda xOverTanVectL,x
        sta E_16_L
        lda xOverTanVectH,x
        sta E_16_H
        
        lda (E_16),y
        endm


;;;---------------------------------------------
;;; xOverTanX8
;;; x = 8        
;;; theta in x
;;;
;;; result in a
;;;--------------------------------------------- 
;defm xOverTanX8
;        lda xOverTan_8,x
;        endm

;;---------------------------------------------
;; atan
;; x in x
;; y in y
;;
;; result in a
;;--------------------------------------------- 
defm atan 
        lda atanVectL,x
        sta E_16_L
        lda atanVectH,x
        sta E_16_H
        
        lda (E_16),y
        endm


;;---------------------------------------------
;; fullObjectRayTheta
;; 
;; quadrant in x
;; theta in a
;;
;; returns full object ray angle 
;; result in a
;;--------------------------------------------- 
defm fullObjectRayTheta
        ldy fullObjectRayThetaVectL,x
        sty E_16_L
        ldy fullObjectRayThetaVectH,x
        sty E_16_H
        
        tay
        lda (E_16),y 
        endm

;;---------------------------------------------
;; objectSpriteXd010
;; 
;; sprite offset in y
;; objectRayId in a
;;
;; result in a
;;--------------------------------------------- 
defm objectSpriteXd010
        ldx objectSpriteXd010Vect,y
        stx E_16_L
        iny
        ldx objectSpriteXd010Vect,y
        stx E_16_H
        
        tay
        lda (E_16),y 
        endm

;;---------------------------------------------
;; stretchedObjectSpriteXd010
;; 
;; sprite offset in y
;; objectRayId in a
;;
;; result in a
;;--------------------------------------------- 
defm stretchedObjectSpriteXd010
        ldx stretchedObjectSpriteXd010Vect,y
        stx E_16_L
        iny
        ldx stretchedObjectSpriteXd010Vect,y
        stx E_16_H
        
        tay
        lda (E_16),y 
        endm
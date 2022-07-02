playerTheta=$02
posX=$03
posY=$04
tmpPosX=$05
tmpPosY=$06
playerState=$7f
;00000000
;   |||||
;   ||||+- run
;   |||+-- red key
;   ||+--- blue key
;   |+---- yellow key
;   +----- no key (always set to 1 - optimization)

;;---------------------------------------------
;; player_setup
;;
;; Loads player's initial pos and theta
;;---------------------------------------------             
player_setup
                lda #$6a
                sta posX
                lda #$85
                sta posY
                lda #0
                sta playerTheta
                lda #%00010000
                sta playerState
                rts
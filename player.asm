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

PLAYER_STATE_RUN_MASK=#%00000001
PLAYER_STATE_RED_KEY_MASK=#%00000010
PLAYER_STATE_BLUE_KEY_MASK=#%00000100
PLAYER_STATE_YELLOW_KEY_MASK=#%00001000
PLAYER_STATE_NO_KEY_MASK=#%00010000

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
                lda #PLAYER_STATE_NO_KEY_MASK
                sta playerState
                rts
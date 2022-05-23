SPRITE_BG_COLOR=#01
SPRITE_M1_COLOR=#12
SPRITE_M2_COLOR=#15

NO_OF_WEAPON_SPRITES=#4

SPRITES_ADDRESS=$2000
SCREEN_RAM=$0400
SPRITES_RAM=$07f8

;;---------------------------------------------
;; sprites_setup
;;---------------------------------------------  
sprites_setup
                jsr common_sprites_setup
                jsr weapons_sprites_setup
                rts


;;---------------------------------------------
;; common_sprites_setup
;;---------------------------------------------  
common_sprites_setup
                lda #SPRITE_BG_COLOR                 
                sta $d021
                lda #SPRITE_M1_COLOR
                sta $d025
                lda #SPRITE_M2_COLOR 
                sta $d026
                rts


SPRITE_BG_COLOR=#01
SPRITE_M0_COLOR=#12
SPRITE_M1_COLOR=#15

SPRITE_BG_COLOR_ADDRESS=$d021
SPRITE_M0_COLOR_ADDRESS=$d025
SPRITE_M1_COLOR_ADDRESS=$d026

SPRITE_0_COLOR_ADDRESS=$d027
SPRITE_1_COLOR_ADDRESS=$d028
SPRITE_2_COLOR_ADDRESS=$d029
SPRITE_3_COLOR_ADDRESS=$d02a
SPRITE_4_COLOR_ADDRESS=$d02b
SPRITE_5_COLOR_ADDRESS=$d02c
SPRITE_6_COLOR_ADDRESS=$d02d
SPRITE_7_COLOR_ADDRESS=$d02e

; sprites indexed by bit-numbers
SPRITES_ENABLE_ADDRESS=$d015
SPRITES_COLOR_MODE_ADDRESS=$d01c
SPRITES_STRETCH_X_ADDRESS=$d01d
SPRITES_STRETCH_Y_ADDRESS=$d017
SPRITES_PRIORITY_ADDRESS=$d01b
SPRITES_X_COORD_BIT_8_ADDRESS=$d010

SPRITE_0_PTR_ADDRESS=$07f8
SPRITE_1_PTR_ADDRESS=$07f9
SPRITE_2_PTR_ADDRESS=$07fa
SPRITE_3_PTR_ADDRESS=$07fb
SPRITE_4_PTR_ADDRESS=$07fc
SPRITE_5_PTR_ADDRESS=$07fd
SPRITE_6_PTR_ADDRESS=$07fe
SPRITE_7_PTR_ADDRESS=$07ff

SPRITE_0_COORD_X_ADDRESS=$d000
SPRITE_0_COORD_Y_ADDRESS=$d001
SPRITE_1_COORD_X_ADDRESS=$d002
SPRITE_1_COORD_Y_ADDRESS=$d003
SPRITE_2_COORD_X_ADDRESS=$d004
SPRITE_2_COORD_Y_ADDRESS=$d005
SPRITE_3_COORD_X_ADDRESS=$d006
SPRITE_3_COORD_Y_ADDRESS=$d007
SPRITE_4_COORD_X_ADDRESS=$d008
SPRITE_4_COORD_Y_ADDRESS=$d009
SPRITE_5_COORD_X_ADDRESS=$d00a
SPRITE_5_COORD_Y_ADDRESS=$d00b
SPRITE_6_COORD_X_ADDRESS=$d00c
SPRITE_6_COORD_Y_ADDRESS=$d00d
SPRITE_7_COORD_X_ADDRESS=$d00e
SPRITE_7_COORD_Y_ADDRESS=$d00f
;;---------------------------------------------
;; sprites_setup
;;---------------------------------------------  
sprites_setup
                jsr common_sprites_setup
                jsr weapons_sprites_setup
                jsr objects_sprites_setup
                rts


;;---------------------------------------------
;; common_sprites_setup
;;---------------------------------------------  
common_sprites_setup

                lda #$00    ; x coord high bit to 0 for all sprites
                sta SPRITES_X_COORD_BIT_8_ADDRESS

                lda #SPRITE_BG_COLOR                 
                sta SPRITE_BG_COLOR_ADDRESS

                lda #SPRITE_M0_COLOR
                sta SPRITE_M0_COLOR_ADDRESS

                lda #SPRITE_M1_COLOR 
                sta SPRITE_M1_COLOR_ADDRESS


                lda SPRITES_ENABLE_ADDRESS
                ora #%11111111
                sta SPRITES_ENABLE_ADDRESS  
                rts


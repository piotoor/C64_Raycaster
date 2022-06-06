WEAPON_SPRITE_COLOR=#11

WEAPON_FRAMES=#2
WEAPON_SPRITE_ANIM_FRAMES=#4

WEAPON_SPRITE_PTR=$80
WEAPON_LEFT_SPRITE_PTR=$80
WEAPON_RIGHT_SPRITE_PTR=$82

weaponCurrentFrame=$80
;;---------------------------------------------
;; weapons_sprites_setup
;;---------------------------------------------  
weapons_sprites_setup
                lda #0
                sta weaponCurrentFrame

                lda #WEAPON_LEFT_SPRITE_PTR
                sta SPRITE_0_PTR_ADDRESS

                lda #WEAPON_RIGHT_SPRITE_PTR
                sta SPRITE_1_PTR_ADDRESS
                
                lda SPRITES_ENABLE_ADDRESS
                ora #%00000011
                sta SPRITES_ENABLE_ADDRESS  
                
                lda SPRITES_COLOR_MODE_ADDRESS 
                ora #%00000011
                sta SPRITES_COLOR_MODE_ADDRESS

                lda SPRITES_PRIORITY_ADDRESS
                ora #%00000000
                sta SPRITES_PRIORITY_ADDRESS

                lda #WEAPON_SPRITE_COLOR       
                sta SPRITE_0_COLOR_ADDRESS
                sta SPRITE_1_COLOR_ADDRESS

                ; sprite 0 position
                lda #160
                sta SPRITE_0_COORD_X_ADDRESS
                lda #208
                sta SPRITE_0_COORD_Y_ADDRESS

                ; sprite 1 position
                lda #184
                sta SPRITE_1_COORD_X_ADDRESS
                lda #208
                sta SPRITE_1_COORD_y_ADDRESS

                ; stretching
                lda #$03
                sta SPRITES_STRETCH_Y_ADDRESS
                rts

;;---------------------------------------------
;; update_weapon
;;---------------------------------------------
update_weapon
                             
                inc SPRITE_0_PTR_ADDRESS
                inc SPRITE_1_PTR_ADDRESS
                ldx weaponCurrentFrame
                inx
                cpx #WEAPON_FRAMES
                bne @endif
                        lda #WEAPON_LEFT_SPRITE_PTR
                        sta SPRITE_0_PTR_ADDRESS
                        lda #WEAPON_RIGHT_SPRITE_PTR
                        sta SPRITE_1_PTR_ADDRESS
                        ldx #0                 
@endif
                stx weaponCurrentFrame
                rts
WEAPON_SPRITE_COLOR=#11
WEAPON_FRAMES=#2
weaponCurrentFrame=$80
WEAPON_SPRITE_PTR=$80
WEAPON_SPRITES_RAM=$07f8

;;---------------------------------------------
;; weapons_sprites_setup
;;---------------------------------------------  
weapons_sprites_setup
                lda #0
                sta weaponCurrentFrame
                lda #WEAPON_SPRITE_PTR          ; weapong left part (sprite 0)
                sta $07f8

                lda #WEAPON_SPRITE_PTR+2        ; weapon right part (sprite 1)
                sta $07f9

                lda #%00000011          ; enable sprites 0 and 1
                sta $d015 
                lda #%00000011          ; sprites 0 and 1 multicolor
                sta $d01c
                lda #%00000000          ; sprites 0 and 1 over bg
                sta $d01b               


                lda #WEAPON_SPRITE_COLOR       
                sta $d027               ; sprite 0 color
                sta $d028               ; sprite 1 color


                lda #$00    ; x coord high bit to 0 for all sprites
                sta $d010

                ; sprite 0 position
                lda #160
                sta $d000   ; sprite 0 x-coord
                lda #208    ; 
                sta $d001   ; sprite 0 y-coord

                ; sprite 1 position
                lda #184
                sta $d002   ; sprite 0 x-coord
                lda #208    ; 
                sta $d003   ; sprite 0 y-coord


                ; stretching
                lda #$03
                ;sta $d01d              ; w
                sta $d017               ; h
                rts
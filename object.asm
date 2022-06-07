;objectPosX=$6b
;objectPosY=$6c
;enemyMapX=$87
;enemyMapY=$88
ENEMY_SIZE=#8

;;---------------------------------------------
;; objects_setup
;;
;; Loads objects' initial positions
;;---------------------------------------------             
objects_setup
                
                ldy #0

                lda #64
                sta objectPosX,y
                lda $96
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #2
                sta objectSpriteColor,y
             

                iny
                lda #64
                sta objectPosX,y
                lda $112
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #3
                sta objectSpriteColor,y

                iny
                lda #96
                sta objectPosX,y
                lda $128
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #6
                sta objectSpriteColor,y
                               
                rts


MASKING_SPRITE_COLOR=#0
MASKING_SPRITE_ANIM_FRAMES=#8
OBJECT_SPRITE_ANIM_FRAMES=#6

MASKING_SPRITE_PTR=#WEAPON_SPRITE_PTR+#WEAPON_SPRITE_ANIM_FRAMES
OBJECT_SPRITE_PTR=#MASKING_SPRITE_PTR+#MASKING_SPRITE_ANIM_FRAMES

OBJECT_SPRITE_3_COLOR=#1
OBJECT_SPRITE_5_COLOR=#3
OBJECT_SPRITE_7_COLOR=#4

objectFrameOffset=$28; common for all for now
;;---------------------------------------------
;; objects_sprites_setup
;;---------------------------------------------  
objects_sprites_setup
                lda #0
                sta objectFrameOffset

                lda #MASKING_SPRITE_PTR
                sta SPRITE_2_PTR_ADDRESS
                sta SPRITE_4_PTR_ADDRESS
                sta SPRITE_6_PTR_ADDRESS

                lda #OBJECT_SPRITE_PTR
                sta SPRITE_3_PTR_ADDRESS
                sta SPRITE_5_PTR_ADDRESS
                sta SPRITE_7_PTR_ADDRESS

                lda SPRITES_COLOR_MODE_ADDRESS 
                ora #%10101000
                sta SPRITES_COLOR_MODE_ADDRESS

                lda SPRITES_PRIORITY_ADDRESS
                ora #%01010100
                sta SPRITES_PRIORITY_ADDRESS

                lda #MASKING_SPRITE_COLOR
                sta SPRITE_2_COLOR_ADDRESS
                sta SPRITE_4_COLOR_ADDRESS
                sta SPRITE_6_COLOR_ADDRESS

                ldy #0
                lda #OBJECT_SPRITE_3_COLOR
                sta objectSpriteColor,y
                iny
                lda #OBJECT_SPRITE_5_COLOR
                sta objectSpriteColor,y
                iny
                lda #OBJECT_SPRITE_7_COLOR
                sta objectSpriteColor,y
;                lda #OBJECT_SPRITE_3_COLOR
;                sta SPRITE_3_COLOR_ADDRESS
;                lda #OBJECT_SPRITE_5_COLOR
;                sta SPRITE_5_COLOR_ADDRESS
;                lda #OBJECT_SPRITE_7_COLOR
;                sta SPRITE_7_COLOR_ADDRESS

                rts

;;---------------------------------------------
;; update_enemy
;;---------------------------------------------  
update_enemy
                lda objectFrameOffset
                eor #%00000110
                sta objectFrameOffset
                rts


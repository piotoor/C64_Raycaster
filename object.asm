;objectPosX=$6b
;objectPosY=$6c
;enemyMapX=$87
;enemyMapY=$88
ENEMY_SIZE=#8
SPRITE_COLUMN_R=#0
SPRITE_COLUMN_C=#1
SPRITE_COLUMN_L=#2
OBJECT_MASTER_ID=#-1
;;---------------------------------------------
;; objects_setup
;;
;; Loads objects' initial positions
;;---------------------------------------------    
objects_setup
                lda #0
                sta $8a
                ldy #2

                lda #24
                sta objectPosX,y
                lda #56
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #0
                sta objectSpriteColor,y
                lda #OBJECT_MASTER_ID
                sta objectMasterId,y
                lda #2
                sta objectSpriteRow,y
                lda #SPRITE_COLUMN_C
                sta objectSpriteCol,y
                lda #0
                sta objectInFOV,y
                lda #100                                ; workaround to the bug with slave sprites appearing on the screen at start
                sta objectRayId,y
                
                dey
                lda #24
                sta objectPosX,y
                ;lda #112
                lda #56
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #3
                sta objectSpriteColor,y
                lda #2
                sta objectMasterId,y
                lda #3
                sta objectSpriteRow,y
                lda #SPRITE_COLUMN_L
                sta objectSpriteCol,y    
                lda #0
                sta objectInFOV,y            

                dey
                ;lda #96
                lda #24
                sta objectPosX,y
                ;lda #128
                lda #56
                sta objectPosY,y
                lda #1
                sta objectAlive,y
                lda #13
                sta objectSpriteColor,y
                lda #2
                sta objectMasterId,y
                lda #4
                sta objectSpriteRow,y
                lda #SPRITE_COLUMN_C
                sta objectSpriteCol,y
                lda #0
                sta objectInFOV,y
                               
                rts


MASKING_SPRITE_COLOR=#0
MASKING_SPRITE_ANIM_FRAMES=#22
;OBJECT_SPRITE_ANIM_FRAMES=#6

MASKING_SPRITE_PTR=#WEAPON_SPRITE_PTR+#WEAPON_SPRITE_ANIM_FRAMES
OBJECT_SPRITE_PTR=#MASKING_SPRITE_PTR+#MASKING_SPRITE_ANIM_FRAMES

OBJECT_SPRITE_3_COLOR=#1
OBJECT_SPRITE_5_COLOR=#3
OBJECT_SPRITE_7_COLOR=#4

;NORMAL_SPRITE_LEVEL_0_COORD_Y=#
;STRETCHED_SPRITE_LEVEL_0_COORD_Y=#
;NORMAL_SPRITE_LEVEL_1_COORD_Y=#
;STRETCHED_SPRITE_LEVEL_1_COORD_Y=#
;NORMAL_SPRITE_LEVEL_2_COORD_Y=#
;STRETCHED_SPRITE_LEVEL_2_COORD_Y=#
;NORMAL_SPRITE_LEVEL_3_COORD_Y=#
;STRETCHED_SPRITE_LEVEL_3_COORD_Y=#
;NORMAL_SPRITE_LEVEL_4_COORD_Y=#
;STRETCHED_SPRITE_LEVEL_4_COORD_Y=#

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
                ;lda #OBJECT_SPRITE_3_COLOR
                ;lda #WEAPON_SPRITE_COLOR
;                lda #1
;                sta objectSpriteColor,y
;                iny
;                lda #OBJECT_SPRITE_5_COLOR
;                sta objectSpriteColor,y
;                iny
;                lda #OBJECT_SPRITE_7_COLOR
;                sta objectSpriteColor,y
;                lda #OBJECT_SPRITE_3_COLOR
;                sta SPRITE_3_COLOR_ADDRESS
;                lda #OBJECT_SPRITE_5_COLOR
;                sta SPRITE_5_COLOR_ADDRESS
;                lda #OBJECT_SPRITE_7_COLOR
;                sta SPRITE_7_COLOR_ADDRESS

                
                lda #140
                sta SPRITE_2_COORD_Y_ADDRESS
                sta SPRITE_3_COORD_Y_ADDRESS
                sta SPRITE_4_COORD_Y_ADDRESS
                sta SPRITE_5_COORD_Y_ADDRESS
                sta SPRITE_6_COORD_Y_ADDRESS
                sta SPRITE_7_COORD_Y_ADDRESS
                rts

;;---------------------------------------------
;; update_objects
;;---------------------------------------------  
update_objects
;                lda objectFrameOffset
;                eor #%00001001
;                sta objectFrameOffset
                rts




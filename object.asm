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

enemyFrameOffset=$28
;;---------------------------------------------
;; objects_sprites_setup
;;---------------------------------------------  
objects_sprites_setup
;                lda #0
;                sta enemyFrameOffset
;                ;sta enemyCurrentFrame

;                lda #MASKING_SPRITE_PTR         
;                sta $07fa               ; SPRITE 2 POINTER
;                lda #OBJECT_SPRITE_PTR         
;                sta $07fb               ; SPRITE 3 POINTER    
;                
;                lda $d01c               ; sprite 3 multicolor
;                ora #%00001000
;                sta $d01c

;                lda $d01b               ; sprite 3 over bg
;                ora #%00000100          ; sprite 2 not
;                sta $d01b   

;                lda #ENEMY_SPRITE_COLOR       
;                sta $d02a               ; sprite 3 color
;                lda #BG_COLOR
;                sta $d029               ; sprite 2 color

;                lda #150                    
;                sta $d005                       ; sprite 2 y
;                sta $d007                       ; sprite 3 y

                rts

;;---------------------------------------------
;; update_enemy
;;---------------------------------------------  
update_enemy
;                lda enemyFrameOffset
;                eor #%00000110
;                sta enemyFrameOffset
                rts


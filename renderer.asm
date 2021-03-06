prevTextureId=$78
rayStartX=$7b
currTexColumnOffset=$7d

spriteDataBitMask=$27
spriteDataBitMaskNeg=$2c
spriteDataOffset=$83
maskingSpriteDataOffset=$86
currObjectRayId=$29
currObjectPerpDist=$2a
objectSpriteXd10bitsCurr=$2b

MAX_NUM_OF_OBJECTS=#3
OBJECT_SPRITE_STRETCHING_THRESHOLD=#19
;;---------------------------------------------
;; compute_frame
;;
;; Raycasting is done there, in two steps
;;---------------------------------------------
compute_frame   
                lda #-1
                sta doorInSight
                lda playerTheta
                clc
                adc HALF_FOV
                sta rayTheta

                ldx #SCREEN_WIDTH -1
                stx rayId
@loop                   
                        ;jsr init_ray_params
                        incasm init_ray_params.asm
                        jsr cast_ray
                        dec rayTheta
                dec rayId 
                bmi @end
                jmp @loop
@end
                rts


;;---------------------------------------------
;; compute_objects
;;
;;---------------------------------------------
compute_objects
                lda #255
                sta minPerpDist
                ;sta maxPerpId
                ;sta minPerpId
             
                lda #0
                sta maxPerpDist

                ldx #MAX_NUM_OF_OBJECTS-1
                stx objectId
@loop                   
                        ldx objectId
                        lda objectAlive,x
                        beq @skip_object
                        jsr init_object_ray_params

                        ldx objectId
                        lda objectInFOV,x
                        beq @skip_object
                        jsr cast_object_ray
@skip_object                        
                dec objectId 
                bpl @loop
                rts


;;-----------------------------
;; sort_objects
;;
;; simple comparision against max and min perpDist values
;; calculated during object casting
;;-----------------------------
assign_sprites

                        lda objectPerpDistance,x
                        sta currObjectPerpDist
                        
                        cmp maxPerpDist
                        beq @obj_is_max
                        cmp minPerpDist
                        beq @obj_is_min
@obj_is_mid             
                        lda SPRITES_ENABLE_ADDRESS
                        ora #%00110000
                        sta SPRITES_ENABLE_ADDRESS
                        lda #%11001111
                        ldy #4
                        jmp @endif

@obj_is_max
                        lda SPRITES_ENABLE_ADDRESS
                        ora #%11000000
                        sta SPRITES_ENABLE_ADDRESS
                        inc maxPerpDist
                        lda #%00111111
                        ldy #6
                        jmp @endif
@obj_is_min
                        lda SPRITES_ENABLE_ADDRESS
                        ora #%00001100
                        sta SPRITES_ENABLE_ADDRESS
                        dec minPerpDist
                        lda #%11110011
                        ldy #2
@endif
                        sty maskingSpriteDataOffset
                        iny
                        sty spriteDataOffset
                        sta spriteDataBitMask
                        eor #$ff
                        sta spriteDataBitMaskNeg

                rts


;;---------------------------------------------
;; prepare_masking_sprite
;;---------------------------------------------
prepare_masking_sprite
                lda currObjectPerpDist
                cmp #OBJECT_SPRITE_STRETCHING_THRESHOLD
                bcc @stretch_object_sprite
                lda #0
                ldx currObjectRayId
                dex
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @second_ray
                ora #%00000100                  ; ray dist < enemy dist
@second_ray
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @third_ray
                ora #%00000010                  ; ray dist < enemy dist
@third_ray
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @end
                ora #%00000001                  ; ray dist < enemy dist                      
@end                
                clc
                tax
                lda regularSpriteMaskIdx,x
                adc #MASKING_SPRITE_PTR
                ldy maskingSpriteDataOffset
                sta SPRITES_PTR_ADDRESS_START,y
                rts

@stretch_object_sprite
                lda #0
                ldx currObjectRayId
                dex
                dex
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @second_ray_
                ora #%00100000                  ; ray dist < enemy dist
@second_ray_
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @third_ray_
                ora #%00010000                  ; ray dist < enemy dist
@third_ray_
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @fourth_ray_
                ora #%00001000                  ; ray dist < enemy dist  

@fourth_ray_               
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @fifth_ray_
                ora #%00000100                  ; ray dist < enemy dist
@fifth_ray_
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @sixth_ray_
                ora #%00000010                  ; ray dist < enemy dist
@sixth_ray_
                inx
                ldy rayPerpDistance,x
                cpy currObjectPerpDist
                bcs @end_
                ora #%00000001                  ; ray dist < enemy dist    
                   
@end_               
                clc
                tax
                lda stretchedSpriteMaskIdx,x
                adc #MASKING_SPRITE_PTR
                ldy maskingSpriteDataOffset
                sta SPRITES_PTR_ADDRESS_START,y

                rts


;;---------------------------------------------
;; calculate_sprites_positions
;;---------------------------------------------
calculate_sprites_pos_and_size

                ldx currObjectRayId
                lda currObjectPerpDist
                cmp #OBJECT_SPRITE_STRETCHING_THRESHOLD
                bcc @stretch_object_sprite_
@destretch_object_sprite_
                        lda SPRITES_STRETCH_Y_ADDRESS           ;
                        and spriteDataBitMask                   ; destretching
                        sta SPRITES_STRETCH_Y_ADDRESS           ;
                        lda SPRITES_STRETCH_X_ADDRESS           ;
                        and spriteDataBitMask                   ;
                        sta SPRITES_STRETCH_X_ADDRESS           ;

                        lda maskingSpriteDataOffset
                        asl
                        tay
                        
                        lda objectSpriteX,x
                        ldx #140
                        sta SPRITES_COORD_X_ADDRESS_START,y     ; masking
                        iny
                        iny
                        sta SPRITES_COORD_X_ADDRESS_START,y     ; sprite
                        txa 
                        sta SPRITES_COORD_Y_ADDRESS_START,y     ; sprite
                        dey
                        dey 
                        sta SPRITES_COORD_Y_ADDRESS_START,y     ; masking
                        
                        ldy maskingSpriteDataOffset
                        lda currObjectRayId
                        objectSpriteXd010
                        sta objectSpriteXd10bitsCurr
                        lda SPRITES_X_COORD_BIT_8_ADDRESS
                        and spriteDataBitMask
                        ora objectSpriteXd10bitsCurr
                        sta SPRITES_X_COORD_BIT_8_ADDRESS
                        
                        rts

@stretch_object_sprite_
                        lda SPRITES_STRETCH_Y_ADDRESS           ;
                        ora spriteDataBitMaskNeg                ; stretching
                        sta SPRITES_STRETCH_Y_ADDRESS           ;
                        lda SPRITES_STRETCH_X_ADDRESS           ;
                        ora spriteDataBitMaskNeg                ;
                        sta SPRITES_STRETCH_X_ADDRESS           ;

                        lda maskingSpriteDataOffset
                        asl
                        tay

                        lda stretchedObjectSpriteX,x
                        ldx #130
                        sta SPRITES_COORD_X_ADDRESS_START,y     ; masking
                        iny
                        iny
                        sta SPRITES_COORD_X_ADDRESS_START,y     ; sprite
                        txa 
                        sta SPRITES_COORD_Y_ADDRESS_START,y     ; sprite
                        dey
                        dey 
                        sta SPRITES_COORD_Y_ADDRESS_START,y     ; masking

                        ldy maskingSpriteDataOffset
                        lda currObjectRayId
                        stretchedObjectSpriteXd010
                        sta objectSpriteXd10bitsCurr
                        lda SPRITES_X_COORD_BIT_8_ADDRESS
                        and spriteDataBitMask
                        ora objectSpriteXd10bitsCurr
                        sta SPRITES_X_COORD_BIT_8_ADDRESS

                        rts

;;---------------------------------------------
;; draw_objects
;;---------------------------------------------
draw_objects       
                lda #%00000011
                sta SPRITES_ENABLE_ADDRESS

                ldx #MAX_NUM_OF_OBJECTS-1
                stx objectId
@loop                   
                        ldx objectId
                        lda objectAlive,x
                        beq @skip_object
                        lda objectInFOV,x
                        beq @skip_object

                        lda objectRayId,x
                        sta currObjectRayId
                        
                        jsr assign_sprites
                        ldx objectId
                        lda objectSpriteColor,x
                        ldy spriteDataOffset
                        sta SPRITES_COLOR_ADDRESS_START,y
                        jsr prepare_masking_sprite                        

                        ldx currObjectPerpDist
                        lda #OBJECT_SPRITE_PTR
                        clc
                        adc objectFrameOffset
                        adc objectSpriteScaleFrameIdx,x         
                        ldy spriteDataOffset
                        sta SPRITES_PTR_ADDRESS_START,y         

                        jsr calculate_sprites_pos_and_size
                                
@skip_object        
                
                dec objectId 
                ldx objectId
                bpl @loop
                rts

;;---------------------------------------------
;; draw_back_buffer
;;
;; Renders frame on a back buffer ($C800)
;; Only upper half of the screen is calculated
;; Lower part is just a mirror.
;;---------------------------------------------
draw_back_buffer 
                lda #$c9
                sta E_16_H
                lda #-1
                sta prevTextureId
                ldx #SCREEN_WIDTH -1
@cols
                        ldy rayTextureId,x
                        cpy prevTextureId               ; if current column uses the same texture as previous one
                        beq @same_texture               ; don't reload
                        lda texturesVectL,y             ; 
                        sta texture_L                   ; 
                        sty prevTextureId               ;
                        lda texturesVectH,y             ; 
                        sta texture_H                   ;
@same_texture
                        ; update upper part pointer
                        lda backBuffUpperL,x
                        sta E_16_L

                        cpx #MIDDLE_RAY-1
                        bne @back_buffer_h_unchanged
                        ;lda backBuffUpperH,x
                        ;sta E_16_H
                        dec E_16_H
@back_buffer_h_unchanged

                        lda #CEIL_FLOOR_COLOR   
                        ldy rayStart,x
                        sty rayStartX

                        ldy prevRayStart,x
@draw_ceil_floor        cpy rayStartX
                        bcs @end
                        
                        sta (E_16),y
                        iny
                        bpl @draw_ceil_floor
@end    
                        
                        lda texColumnOffsets,x          ; beginning of a texture vertical strip
                        sta currTexColumnOffset         ;
                        stx g_8
                        ldy rayStartX
                        lda textureMappingOffsets,y
                        
                        tax
@draw_walls
                        lda textureMappingCoords,x
                        inx
                        clc
                        adc currTexColumnOffset
                        
                        sty f_8
                        tay
                        lda (texture),y
                        ldy f_8
                        sta (E_16),y
                        
                        iny
                        cpy #HALF_SCREEN_HEIGHT
                        bne @draw_walls
                
                
                ldx g_8
                dex
                bpl @cols
                
                rts


;;---------------------------------------------
;; draw_front_buffer
;;
;; Copies back_buffer to color_buffer
;;---------------------------------------------
draw_front_buffer 
                lda $c800
                sta $d800
                sta $dbc0
                lda $c801
                sta $d828
                sta $db98
                lda $c802
                sta $d850
                sta $db70
                lda $c803
                sta $d878
                sta $db48
                lda $c804
                sta $d8a0
                sta $db20
                lda $c805
                sta $d8c8
                sta $daf8
                lda $c806
                sta $d8f0
                sta $dad0
                lda $c807
                sta $d918
                sta $daa8
                lda $c808
                sta $d940
                sta $da80
                lda $c809
                sta $d968
                sta $da58
                lda $c80a
                sta $d990
                sta $da30
                lda $c80b
                sta $d9b8
                sta $da08
                lda $c80c
                sta $d9e0
                lda $c80d
                sta $d801
                sta $dbc1
                lda $c80e
                sta $d829
                sta $db99
                lda $c80f
                sta $d851
                sta $db71
                lda $c810
                sta $d879
                sta $db49
                lda $c811
                sta $d8a1
                sta $db21
                lda $c812
                sta $d8c9
                sta $daf9
                lda $c813
                sta $d8f1
                sta $dad1
                lda $c814
                sta $d919
                sta $daa9
                lda $c815
                sta $d941
                sta $da81
                lda $c816
                sta $d969
                sta $da59
                lda $c817
                sta $d991
                sta $da31
                lda $c818
                sta $d9b9
                sta $da09
                lda $c819
                sta $d9e1
                lda $c81a
                sta $d802
                sta $dbc2
                lda $c81b
                sta $d82a
                sta $db9a
                lda $c81c
                sta $d852
                sta $db72
                lda $c81d
                sta $d87a
                sta $db4a
                lda $c81e
                sta $d8a2
                sta $db22
                lda $c81f
                sta $d8ca
                sta $dafa
                lda $c820
                sta $d8f2
                sta $dad2
                lda $c821
                sta $d91a
                sta $daaa
                lda $c822
                sta $d942
                sta $da82
                lda $c823
                sta $d96a
                sta $da5a
                lda $c824
                sta $d992
                sta $da32
                lda $c825
                sta $d9ba
                sta $da0a
                lda $c826
                sta $d9e2
                lda $c827
                sta $d803
                sta $dbc3
                lda $c828
                sta $d82b
                sta $db9b
                lda $c829
                sta $d853
                sta $db73
                lda $c82a
                sta $d87b
                sta $db4b
                lda $c82b
                sta $d8a3
                sta $db23
                lda $c82c
                sta $d8cb
                sta $dafb
                lda $c82d
                sta $d8f3
                sta $dad3
                lda $c82e
                sta $d91b
                sta $daab
                lda $c82f
                sta $d943
                sta $da83
                lda $c830
                sta $d96b
                sta $da5b
                lda $c831
                sta $d993
                sta $da33
                lda $c832
                sta $d9bb
                sta $da0b
                lda $c833
                sta $d9e3
                lda $c834
                sta $d804
                sta $dbc4
                lda $c835
                sta $d82c
                sta $db9c
                lda $c836
                sta $d854
                sta $db74
                lda $c837
                sta $d87c
                sta $db4c
                lda $c838
                sta $d8a4
                sta $db24
                lda $c839
                sta $d8cc
                sta $dafc
                lda $c83a
                sta $d8f4
                sta $dad4
                lda $c83b
                sta $d91c
                sta $daac
                lda $c83c
                sta $d944
                sta $da84
                lda $c83d
                sta $d96c
                sta $da5c
                lda $c83e
                sta $d994
                sta $da34
                lda $c83f
                sta $d9bc
                sta $da0c
                lda $c840
                sta $d9e4
                lda $c841
                sta $d805
                sta $dbc5
                lda $c842
                sta $d82d
                sta $db9d
                lda $c843
                sta $d855
                sta $db75
                lda $c844
                sta $d87d
                sta $db4d
                lda $c845
                sta $d8a5
                sta $db25
                lda $c846
                sta $d8cd
                sta $dafd
                lda $c847
                sta $d8f5
                sta $dad5
                lda $c848
                sta $d91d
                sta $daad
                lda $c849
                sta $d945
                sta $da85
                lda $c84a
                sta $d96d
                sta $da5d
                lda $c84b
                sta $d995
                sta $da35
                lda $c84c
                sta $d9bd
                sta $da0d
                lda $c84d
                sta $d9e5
                lda $c84e
                sta $d806
                sta $dbc6
                lda $c84f
                sta $d82e
                sta $db9e
                lda $c850
                sta $d856
                sta $db76
                lda $c851
                sta $d87e
                sta $db4e
                lda $c852
                sta $d8a6
                sta $db26
                lda $c853
                sta $d8ce
                sta $dafe
                lda $c854
                sta $d8f6
                sta $dad6
                lda $c855
                sta $d91e
                sta $daae
                lda $c856
                sta $d946
                sta $da86
                lda $c857
                sta $d96e
                sta $da5e
                lda $c858
                sta $d996
                sta $da36
                lda $c859
                sta $d9be
                sta $da0e
                lda $c85a
                sta $d9e6
                lda $c85b
                sta $d807
                sta $dbc7
                lda $c85c
                sta $d82f
                sta $db9f
                lda $c85d
                sta $d857
                sta $db77
                lda $c85e
                sta $d87f
                sta $db4f
                lda $c85f
                sta $d8a7
                sta $db27
                lda $c860
                sta $d8cf
                sta $daff
                lda $c861
                sta $d8f7
                sta $dad7
                lda $c862
                sta $d91f
                sta $daaf
                lda $c863
                sta $d947
                sta $da87
                lda $c864
                sta $d96f
                sta $da5f
                lda $c865
                sta $d997
                sta $da37
                lda $c866
                sta $d9bf
                sta $da0f
                lda $c867
                sta $d9e7
                lda $c868
                sta $d808
                sta $dbc8
                lda $c869
                sta $d830
                sta $dba0
                lda $c86a
                sta $d858
                sta $db78
                lda $c86b
                sta $d880
                sta $db50
                lda $c86c
                sta $d8a8
                sta $db28
                lda $c86d
                sta $d8d0
                sta $db00
                lda $c86e
                sta $d8f8
                sta $dad8
                lda $c86f
                sta $d920
                sta $dab0
                lda $c870
                sta $d948
                sta $da88
                lda $c871
                sta $d970
                sta $da60
                lda $c872
                sta $d998
                sta $da38
                lda $c873
                sta $d9c0
                sta $da10
                lda $c874
                sta $d9e8
                lda $c875
                sta $d809
                sta $dbc9
                lda $c876
                sta $d831
                sta $dba1
                lda $c877
                sta $d859
                sta $db79
                lda $c878
                sta $d881
                sta $db51
                lda $c879
                sta $d8a9
                sta $db29
                lda $c87a
                sta $d8d1
                sta $db01
                lda $c87b
                sta $d8f9
                sta $dad9
                lda $c87c
                sta $d921
                sta $dab1
                lda $c87d
                sta $d949
                sta $da89
                lda $c87e
                sta $d971
                sta $da61
                lda $c87f
                sta $d999
                sta $da39
                lda $c880
                sta $d9c1
                sta $da11
                lda $c881
                sta $d9e9
                lda $c882
                sta $d80a
                sta $dbca
                lda $c883
                sta $d832
                sta $dba2
                lda $c884
                sta $d85a
                sta $db7a
                lda $c885
                sta $d882
                sta $db52
                lda $c886
                sta $d8aa
                sta $db2a
                lda $c887
                sta $d8d2
                sta $db02
                lda $c888
                sta $d8fa
                sta $dada
                lda $c889
                sta $d922
                sta $dab2
                lda $c88a
                sta $d94a
                sta $da8a
                lda $c88b
                sta $d972
                sta $da62
                lda $c88c
                sta $d99a
                sta $da3a
                lda $c88d
                sta $d9c2
                sta $da12
                lda $c88e
                sta $d9ea
                lda $c88f
                sta $d80b
                sta $dbcb
                lda $c890
                sta $d833
                sta $dba3
                lda $c891
                sta $d85b
                sta $db7b
                lda $c892
                sta $d883
                sta $db53
                lda $c893
                sta $d8ab
                sta $db2b
                lda $c894
                sta $d8d3
                sta $db03
                lda $c895
                sta $d8fb
                sta $dadb
                lda $c896
                sta $d923
                sta $dab3
                lda $c897
                sta $d94b
                sta $da8b
                lda $c898
                sta $d973
                sta $da63
                lda $c899
                sta $d99b
                sta $da3b
                lda $c89a
                sta $d9c3
                sta $da13
                lda $c89b
                sta $d9eb
                lda $c89c
                sta $d80c
                sta $dbcc
                lda $c89d
                sta $d834
                sta $dba4
                lda $c89e
                sta $d85c
                sta $db7c
                lda $c89f
                sta $d884
                sta $db54
                lda $c8a0
                sta $d8ac
                sta $db2c
                lda $c8a1
                sta $d8d4
                sta $db04
                lda $c8a2
                sta $d8fc
                sta $dadc
                lda $c8a3
                sta $d924
                sta $dab4
                lda $c8a4
                sta $d94c
                sta $da8c
                lda $c8a5
                sta $d974
                sta $da64
                lda $c8a6
                sta $d99c
                sta $da3c
                lda $c8a7
                sta $d9c4
                sta $da14
                lda $c8a8
                sta $d9ec
                lda $c8a9
                sta $d80d
                sta $dbcd
                lda $c8aa
                sta $d835
                sta $dba5
                lda $c8ab
                sta $d85d
                sta $db7d
                lda $c8ac
                sta $d885
                sta $db55
                lda $c8ad
                sta $d8ad
                sta $db2d
                lda $c8ae
                sta $d8d5
                sta $db05
                lda $c8af
                sta $d8fd
                sta $dadd
                lda $c8b0
                sta $d925
                sta $dab5
                lda $c8b1
                sta $d94d
                sta $da8d
                lda $c8b2
                sta $d975
                sta $da65
                lda $c8b3
                sta $d99d
                sta $da3d
                lda $c8b4
                sta $d9c5
                sta $da15
                lda $c8b5
                sta $d9ed
                lda $c8b6
                sta $d80e
                sta $dbce
                lda $c8b7
                sta $d836
                sta $dba6
                lda $c8b8
                sta $d85e
                sta $db7e
                lda $c8b9
                sta $d886
                sta $db56
                lda $c8ba
                sta $d8ae
                sta $db2e
                lda $c8bb
                sta $d8d6
                sta $db06
                lda $c8bc
                sta $d8fe
                sta $dade
                lda $c8bd
                sta $d926
                sta $dab6
                lda $c8be
                sta $d94e
                sta $da8e
                lda $c8bf
                sta $d976
                sta $da66
                lda $c8c0
                sta $d99e
                sta $da3e
                lda $c8c1
                sta $d9c6
                sta $da16
                lda $c8c2
                sta $d9ee
                lda $c8c3
                sta $d80f
                sta $dbcf
                lda $c8c4
                sta $d837
                sta $dba7
                lda $c8c5
                sta $d85f
                sta $db7f
                lda $c8c6
                sta $d887
                sta $db57
                lda $c8c7
                sta $d8af
                sta $db2f
                lda $c8c8
                sta $d8d7
                sta $db07
                lda $c8c9
                sta $d8ff
                sta $dadf
                lda $c8ca
                sta $d927
                sta $dab7
                lda $c8cb
                sta $d94f
                sta $da8f
                lda $c8cc
                sta $d977
                sta $da67
                lda $c8cd
                sta $d99f
                sta $da3f
                lda $c8ce
                sta $d9c7
                sta $da17
                lda $c8cf
                sta $d9ef
                lda $c8d0
                sta $d810
                sta $dbd0
                lda $c8d1
                sta $d838
                sta $dba8
                lda $c8d2
                sta $d860
                sta $db80
                lda $c8d3
                sta $d888
                sta $db58
                lda $c8d4
                sta $d8b0
                sta $db30
                lda $c8d5
                sta $d8d8
                sta $db08
                lda $c8d6
                sta $d900
                sta $dae0
                lda $c8d7
                sta $d928
                sta $dab8
                lda $c8d8
                sta $d950
                sta $da90
                lda $c8d9
                sta $d978
                sta $da68
                lda $c8da
                sta $d9a0
                sta $da40
                lda $c8db
                sta $d9c8
                sta $da18
                lda $c8dc
                sta $d9f0
                lda $c8dd
                sta $d811
                sta $dbd1
                lda $c8de
                sta $d839
                sta $dba9
                lda $c8df
                sta $d861
                sta $db81
                lda $c8e0
                sta $d889
                sta $db59
                lda $c8e1
                sta $d8b1
                sta $db31
                lda $c8e2
                sta $d8d9
                sta $db09
                lda $c8e3
                sta $d901
                sta $dae1
                lda $c8e4
                sta $d929
                sta $dab9
                lda $c8e5
                sta $d951
                sta $da91
                lda $c8e6
                sta $d979
                sta $da69
                lda $c8e7
                sta $d9a1
                sta $da41
                lda $c8e8
                sta $d9c9
                sta $da19
                lda $c8e9
                sta $d9f1
                lda $c8ea
                sta $d812
                sta $dbd2
                lda $c8eb
                sta $d83a
                sta $dbaa
                lda $c8ec
                sta $d862
                sta $db82
                lda $c8ed
                sta $d88a
                sta $db5a
                lda $c8ee
                sta $d8b2
                sta $db32
                lda $c8ef
                sta $d8da
                sta $db0a
                lda $c8f0
                sta $d902
                sta $dae2
                lda $c8f1
                sta $d92a
                sta $daba
                lda $c8f2
                sta $d952
                sta $da92
                lda $c8f3
                sta $d97a
                sta $da6a
                lda $c8f4
                sta $d9a2
                sta $da42
                lda $c8f5
                sta $d9ca
                sta $da1a
                lda $c8f6
                sta $d9f2
                lda $c8f7
                sta $d813
                sta $dbd3
                lda $c8f8
                sta $d83b
                sta $dbab
                lda $c8f9
                sta $d863
                sta $db83
                lda $c8fa
                sta $d88b
                sta $db5b
                lda $c8fb
                sta $d8b3
                sta $db33
                lda $c8fc
                sta $d8db
                sta $db0b
                lda $c8fd
                sta $d903
                sta $dae3
                lda $c8fe
                sta $d92b
                sta $dabb
                lda $c8ff
                sta $d953
                sta $da93
                lda $c900
                sta $d97b
                sta $da6b
                lda $c901
                sta $d9a3
                sta $da43
                lda $c902
                sta $d9cb
                sta $da1b
                lda $c903
                sta $d9f3
                lda $c904
                sta $d814
                sta $dbd4
                lda $c905
                sta $d83c
                sta $dbac
                lda $c906
                sta $d864
                sta $db84
                lda $c907
                sta $d88c
                sta $db5c
                lda $c908
                sta $d8b4
                sta $db34
                lda $c909
                sta $d8dc
                sta $db0c
                lda $c90a
                sta $d904
                sta $dae4
                lda $c90b
                sta $d92c
                sta $dabc
                lda $c90c
                sta $d954
                sta $da94
                lda $c90d
                sta $d97c
                sta $da6c
                lda $c90e
                sta $d9a4
                sta $da44
                lda $c90f
                sta $d9cc
                sta $da1c
                lda $c910
                sta $d9f4
                lda $c911
                sta $d815
                sta $dbd5
                lda $c912
                sta $d83d
                sta $dbad
                lda $c913
                sta $d865
                sta $db85
                lda $c914
                sta $d88d
                sta $db5d
                lda $c915
                sta $d8b5
                sta $db35
                lda $c916
                sta $d8dd
                sta $db0d
                lda $c917
                sta $d905
                sta $dae5
                lda $c918
                sta $d92d
                sta $dabd
                lda $c919
                sta $d955
                sta $da95
                lda $c91a
                sta $d97d
                sta $da6d
                lda $c91b
                sta $d9a5
                sta $da45
                lda $c91c
                sta $d9cd
                sta $da1d
                lda $c91d
                sta $d9f5
                lda $c91e
                sta $d816
                sta $dbd6
                lda $c91f
                sta $d83e
                sta $dbae
                lda $c920
                sta $d866
                sta $db86
                lda $c921
                sta $d88e
                sta $db5e
                lda $c922
                sta $d8b6
                sta $db36
                lda $c923
                sta $d8de
                sta $db0e
                lda $c924
                sta $d906
                sta $dae6
                lda $c925
                sta $d92e
                sta $dabe
                lda $c926
                sta $d956
                sta $da96
                lda $c927
                sta $d97e
                sta $da6e
                lda $c928
                sta $d9a6
                sta $da46
                lda $c929
                sta $d9ce
                sta $da1e
                lda $c92a
                sta $d9f6
                lda $c92b
                sta $d817
                sta $dbd7
                lda $c92c
                sta $d83f
                sta $dbaf
                lda $c92d
                sta $d867
                sta $db87
                lda $c92e
                sta $d88f
                sta $db5f
                lda $c92f
                sta $d8b7
                sta $db37
                lda $c930
                sta $d8df
                sta $db0f
                lda $c931
                sta $d907
                sta $dae7
                lda $c932
                sta $d92f
                sta $dabf
                lda $c933
                sta $d957
                sta $da97
                lda $c934
                sta $d97f
                sta $da6f
                lda $c935
                sta $d9a7
                sta $da47
                lda $c936
                sta $d9cf
                sta $da1f
                lda $c937
                sta $d9f7
                lda $c938
                sta $d818
                sta $dbd8
                lda $c939
                sta $d840
                sta $dbb0
                lda $c93a
                sta $d868
                sta $db88
                lda $c93b
                sta $d890
                sta $db60
                lda $c93c
                sta $d8b8
                sta $db38
                lda $c93d
                sta $d8e0
                sta $db10
                lda $c93e
                sta $d908
                sta $dae8
                lda $c93f
                sta $d930
                sta $dac0
                lda $c940
                sta $d958
                sta $da98
                lda $c941
                sta $d980
                sta $da70
                lda $c942
                sta $d9a8
                sta $da48
                lda $c943
                sta $d9d0
                sta $da20
                lda $c944
                sta $d9f8
                lda $c945
                sta $d819
                sta $dbd9
                lda $c946
                sta $d841
                sta $dbb1
                lda $c947
                sta $d869
                sta $db89
                lda $c948
                sta $d891
                sta $db61
                lda $c949
                sta $d8b9
                sta $db39
                lda $c94a
                sta $d8e1
                sta $db11
                lda $c94b
                sta $d909
                sta $dae9
                lda $c94c
                sta $d931
                sta $dac1
                lda $c94d
                sta $d959
                sta $da99
                lda $c94e
                sta $d981
                sta $da71
                lda $c94f
                sta $d9a9
                sta $da49
                lda $c950
                sta $d9d1
                sta $da21
                lda $c951
                sta $d9f9
                lda $c952
                sta $d81a
                sta $dbda
                lda $c953
                sta $d842
                sta $dbb2
                lda $c954
                sta $d86a
                sta $db8a
                lda $c955
                sta $d892
                sta $db62
                lda $c956
                sta $d8ba
                sta $db3a
                lda $c957
                sta $d8e2
                sta $db12
                lda $c958
                sta $d90a
                sta $daea
                lda $c959
                sta $d932
                sta $dac2
                lda $c95a
                sta $d95a
                sta $da9a
                lda $c95b
                sta $d982
                sta $da72
                lda $c95c
                sta $d9aa
                sta $da4a
                lda $c95d
                sta $d9d2
                sta $da22
                lda $c95e
                sta $d9fa
                lda $c95f
                sta $d81b
                sta $dbdb
                lda $c960
                sta $d843
                sta $dbb3
                lda $c961
                sta $d86b
                sta $db8b
                lda $c962
                sta $d893
                sta $db63
                lda $c963
                sta $d8bb
                sta $db3b
                lda $c964
                sta $d8e3
                sta $db13
                lda $c965
                sta $d90b
                sta $daeb
                lda $c966
                sta $d933
                sta $dac3
                lda $c967
                sta $d95b
                sta $da9b
                lda $c968
                sta $d983
                sta $da73
                lda $c969
                sta $d9ab
                sta $da4b
                lda $c96a
                sta $d9d3
                sta $da23
                lda $c96b
                sta $d9fb
                lda $c96c
                sta $d81c
                sta $dbdc
                lda $c96d
                sta $d844
                sta $dbb4
                lda $c96e
                sta $d86c
                sta $db8c
                lda $c96f
                sta $d894
                sta $db64
                lda $c970
                sta $d8bc
                sta $db3c
                lda $c971
                sta $d8e4
                sta $db14
                lda $c972
                sta $d90c
                sta $daec
                lda $c973
                sta $d934
                sta $dac4
                lda $c974
                sta $d95c
                sta $da9c
                lda $c975
                sta $d984
                sta $da74
                lda $c976
                sta $d9ac
                sta $da4c
                lda $c977
                sta $d9d4
                sta $da24
                lda $c978
                sta $d9fc
                lda $c979
                sta $d81d
                sta $dbdd
                lda $c97a
                sta $d845
                sta $dbb5
                lda $c97b
                sta $d86d
                sta $db8d
                lda $c97c
                sta $d895
                sta $db65
                lda $c97d
                sta $d8bd
                sta $db3d
                lda $c97e
                sta $d8e5
                sta $db15
                lda $c97f
                sta $d90d
                sta $daed
                lda $c980
                sta $d935
                sta $dac5
                lda $c981
                sta $d95d
                sta $da9d
                lda $c982
                sta $d985
                sta $da75
                lda $c983
                sta $d9ad
                sta $da4d
                lda $c984
                sta $d9d5
                sta $da25
                lda $c985
                sta $d9fd
                lda $c986
                sta $d81e
                sta $dbde
                lda $c987
                sta $d846
                sta $dbb6
                lda $c988
                sta $d86e
                sta $db8e
                lda $c989
                sta $d896
                sta $db66
                lda $c98a
                sta $d8be
                sta $db3e
                lda $c98b
                sta $d8e6
                sta $db16
                lda $c98c
                sta $d90e
                sta $daee
                lda $c98d
                sta $d936
                sta $dac6
                lda $c98e
                sta $d95e
                sta $da9e
                lda $c98f
                sta $d986
                sta $da76
                lda $c990
                sta $d9ae
                sta $da4e
                lda $c991
                sta $d9d6
                sta $da26
                lda $c992
                sta $d9fe
                lda $c993
                sta $d81f
                sta $dbdf
                lda $c994
                sta $d847
                sta $dbb7
                lda $c995
                sta $d86f
                sta $db8f
                lda $c996
                sta $d897
                sta $db67
                lda $c997
                sta $d8bf
                sta $db3f
                lda $c998
                sta $d8e7
                sta $db17
                lda $c999
                sta $d90f
                sta $daef
                lda $c99a
                sta $d937
                sta $dac7
                lda $c99b
                sta $d95f
                sta $da9f
                lda $c99c
                sta $d987
                sta $da77
                lda $c99d
                sta $d9af
                sta $da4f
                lda $c99e
                sta $d9d7
                sta $da27
                lda $c99f
                sta $d9ff
                lda $c9a0
                sta $d820
                sta $dbe0
                lda $c9a1
                sta $d848
                sta $dbb8
                lda $c9a2
                sta $d870
                sta $db90
                lda $c9a3
                sta $d898
                sta $db68
                lda $c9a4
                sta $d8c0
                sta $db40
                lda $c9a5
                sta $d8e8
                sta $db18
                lda $c9a6
                sta $d910
                sta $daf0
                lda $c9a7
                sta $d938
                sta $dac8
                lda $c9a8
                sta $d960
                sta $daa0
                lda $c9a9
                sta $d988
                sta $da78
                lda $c9aa
                sta $d9b0
                sta $da50
                lda $c9ab
                sta $d9d8
                sta $da28
                lda $c9ac
                sta $da00
                lda $c9ad
                sta $d821
                sta $dbe1
                lda $c9ae
                sta $d849
                sta $dbb9
                lda $c9af
                sta $d871
                sta $db91
                lda $c9b0
                sta $d899
                sta $db69
                lda $c9b1
                sta $d8c1
                sta $db41
                lda $c9b2
                sta $d8e9
                sta $db19
                lda $c9b3
                sta $d911
                sta $daf1
                lda $c9b4
                sta $d939
                sta $dac9
                lda $c9b5
                sta $d961
                sta $daa1
                lda $c9b6
                sta $d989
                sta $da79
                lda $c9b7
                sta $d9b1
                sta $da51
                lda $c9b8
                sta $d9d9
                sta $da29
                lda $c9b9
                sta $da01
                lda $c9ba
                sta $d822
                sta $dbe2
                lda $c9bb
                sta $d84a
                sta $dbba
                lda $c9bc
                sta $d872
                sta $db92
                lda $c9bd
                sta $d89a
                sta $db6a
                lda $c9be
                sta $d8c2
                sta $db42
                lda $c9bf
                sta $d8ea
                sta $db1a
                lda $c9c0
                sta $d912
                sta $daf2
                lda $c9c1
                sta $d93a
                sta $daca
                lda $c9c2
                sta $d962
                sta $daa2
                lda $c9c3
                sta $d98a
                sta $da7a
                lda $c9c4
                sta $d9b2
                sta $da52
                lda $c9c5
                sta $d9da
                sta $da2a
                lda $c9c6
                sta $da02
                lda $c9c7
                sta $d823
                sta $dbe3
                lda $c9c8
                sta $d84b
                sta $dbbb
                lda $c9c9
                sta $d873
                sta $db93
                lda $c9ca
                sta $d89b
                sta $db6b
                lda $c9cb
                sta $d8c3
                sta $db43
                lda $c9cc
                sta $d8eb
                sta $db1b
                lda $c9cd
                sta $d913
                sta $daf3
                lda $c9ce
                sta $d93b
                sta $dacb
                lda $c9cf
                sta $d963
                sta $daa3
                lda $c9d0
                sta $d98b
                sta $da7b
                lda $c9d1
                sta $d9b3
                sta $da53
                lda $c9d2
                sta $d9db
                sta $da2b
                lda $c9d3
                sta $da03
                lda $c9d4
                sta $d824
                sta $dbe4
                lda $c9d5
                sta $d84c
                sta $dbbc
                lda $c9d6
                sta $d874
                sta $db94
                lda $c9d7
                sta $d89c
                sta $db6c
                lda $c9d8
                sta $d8c4
                sta $db44
                lda $c9d9
                sta $d8ec
                sta $db1c
                lda $c9da
                sta $d914
                sta $daf4
                lda $c9db
                sta $d93c
                sta $dacc
                lda $c9dc
                sta $d964
                sta $daa4
                lda $c9dd
                sta $d98c
                sta $da7c
                lda $c9de
                sta $d9b4
                sta $da54
                lda $c9df
                sta $d9dc
                sta $da2c
                lda $c9e0
                sta $da04
                lda $c9e1
                sta $d825
                sta $dbe5
                lda $c9e2
                sta $d84d
                sta $dbbd
                lda $c9e3
                sta $d875
                sta $db95
                lda $c9e4
                sta $d89d
                sta $db6d
                lda $c9e5
                sta $d8c5
                sta $db45
                lda $c9e6
                sta $d8ed
                sta $db1d
                lda $c9e7
                sta $d915
                sta $daf5
                lda $c9e8
                sta $d93d
                sta $dacd
                lda $c9e9
                sta $d965
                sta $daa5
                lda $c9ea
                sta $d98d
                sta $da7d
                lda $c9eb
                sta $d9b5
                sta $da55
                lda $c9ec
                sta $d9dd
                sta $da2d
                lda $c9ed
                sta $da05
                lda $c9ee
                sta $d826
                sta $dbe6
                lda $c9ef
                sta $d84e
                sta $dbbe
                lda $c9f0
                sta $d876
                sta $db96
                lda $c9f1
                sta $d89e
                sta $db6e
                lda $c9f2
                sta $d8c6
                sta $db46
                lda $c9f3
                sta $d8ee
                sta $db1e
                lda $c9f4
                sta $d916
                sta $daf6
                lda $c9f5
                sta $d93e
                sta $dace
                lda $c9f6
                sta $d966
                sta $daa6
                lda $c9f7
                sta $d98e
                sta $da7e
                lda $c9f8
                sta $d9b6
                sta $da56
                lda $c9f9
                sta $d9de
                sta $da2e
                lda $c9fa
                sta $da06
                lda $c9fb
                sta $d827
                sta $dbe7
                lda $c9fc
                sta $d84f
                sta $dbbf
                lda $c9fd
                sta $d877
                sta $db97
                lda $c9fe
                sta $d89f
                sta $db6f
                lda $c9ff
                sta $d8c7
                sta $db47
                lda $ca00
                sta $d8ef
                sta $db1f
                lda $ca01
                sta $d917
                sta $daf7
                lda $ca02
                sta $d93f
                sta $dacf
                lda $ca03
                sta $d967
                sta $daa7
                lda $ca04
                sta $d98f
                sta $da7f
                lda $ca05
                sta $d9b7
                sta $da57
                lda $ca06
                sta $d9df
                sta $da2f
                lda $ca07
                sta $da07

                rts





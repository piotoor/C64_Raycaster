; 10 SYS (4096)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

*=$1000

SCREEN_WIDTH=#40
SCREEN_HEIGHT=#25
HALF_SCREEN_HEIGHT=#13
HALF_FOV=#20
DEFAULT_SCREEN_CHARACTER=#$A0

SPRITE_BG_COLOR=#01
SPRITE_M1_COLOR=#12
SPRITE_M2_COLOR=#15
SPRITE_COLOR=#11
WEAPON_FRAMES=#2
weaponCurrentFrame=$80
SPRITES_ADDRESS=$2000  
;SPRITE_PTR_WEAPON=SPRITES_ADDRESS/#$40
SPRITE_PTR_WEAPON=$80
SCREEN_RAM=$0400
SPRITES_RAM=$07f8

pra=$dc00       ; CIA#1 (Port Register A)
prb=$dc01       ; CIA#1 (Port Register B)
ddra=$dc02      ; CIA#1 (Data Direction Register A)
ddrb=$dc03      ; CIA#1 (Data Direction Register B)

synch=$71       
main_ticks=$72
irq_ticks=$73

;;---------------------------------------------
;; main
;;---------------------------------------------
main            
                jsr setup
                lda #0
                sta synch
@mainloop
                lda synch
                bne @continue
                jsr compute_frame
                jsr draw_back_buffer
                inc main_ticks
                lda #1
                sta synch
@continue       jmp @mainloop
                
;;---------------------------------------------
;; irq
;;---------------------------------------------
irq             
                dec $d019               ; acknowledge IRQ / clear register for next interrupt
                lda synch
                beq frame_not_ready
                jsr draw_front_buffer
                jsr check_keyboard
                lda #0
                sta synch
frame_not_ready inc irq_ticks
                lda irq_ticks
                cmp #50
                bne @end
@update_fps     lda main_ticks
                sta $400
                
                lda #0
                sta irq_ticks
                sta main_ticks
@end            
                jmp $ea31               ; kernel irq routine

;;---------------------------------------------
;; irq_setup
;;---------------------------------------------             
irq_setup
                sei

                ldy #$7f
                sty $dc0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                sty $dd0d   ; 
                lda $dc0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
                lda $dd0d   ;

                lda #$01    ; set interrupt request mask
                sta $d01a   ; rasterbeam irq %00000001)

                lda #<irq   ; set custom irq routine address
                ldx #>irq 
                sta $0314   
                stx $0315   

                lda #$ff    
                sta $d012

                lda $d011
                and #$7f
                sta $d011

                cli
                rts

;;---------------------------------------------
;; setup
;;---------------------------------------------             
setup
                lda #0
                sta main_ticks
                sta irq_ticks
                
                jsr player_setup
                jsr screen_setup
                jsr irq_setup
                jsr raycaster_setup
                jsr sprites_setup
                rts

;;---------------------------------------------
;; raycaster_setup
;;---------------------------------------------  
raycaster_setup
                lda #0
                ldx #SCREEN_WIDTH -1
@loop           
                sta rayStart,x
                dex

                bpl @loop
                rts
                
;;---------------------------------------------
;; sprites_setup
;;---------------------------------------------  
sprites_setup
                lda #0
                sta weaponCurrentFrame
                lda #SPRITE_PTR_WEAPON          ; weapong left part (sprite 0)
                sta $07f8

                lda #SPRITE_PTR_WEAPON+2        ; weapon right part (sprite 1)
                sta $07f9

                lda #%00000011          ; enable sprites 0 and 1
                sta $d015 
                lda #%00000011          ; sprites 0 and 1 multicolor
                sta $d01c
                lda #%00000000          ; sprites 0 and 1 over bg
                sta $d01b               


                lda #SPRITE_BG_COLOR                 
                sta $d021
                lda #SPRITE_M1_COLOR
                sta $d025
                lda #SPRITE_M2_COLOR 
                sta $d026
                lda #SPRITE_COLOR       
                sta $d027               ; sprite 0 color
                sta $d028               ; sprite 1 color


                lda #$00    ; x coord high bit to 0 for all sprites
                sta $d010

                ; sprite 0 position
                ;lda #148    ; 
                lda #160
                sta $d000   ; sprite 0 x-coord
                lda #208    ; 
                ;lda #229
                sta $d001   ; sprite 0 y-coord

                ; sprite 1 position
                
                ;lda #196
                lda #184
                sta $d002   ; sprite 0 x-coord
                lda #208    ; 
                ;lda #229
                sta $d003   ; sprite 0 y-coord


                ; stretching tmp
                lda #$03
                
                ;sta $d01d       ; w
                sta $d017       ; h
                rts


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
                lda #0
                sta playerState
                rts

;;---------------------------------------------
;; screen_setup
;;
;; Fills the entire screen with A0 char
;;---------------------------------------------
screen_setup     
                ldx #0 
@loop                   lda #DEFAULT_SCREEN_CHARACTER
                        sta $0400,x
                        sta $0500,x
                        sta $0600,x
                        sta $06e8,x                        
                inx
                bne @loop 
                lda #1          ; set bg color 
                sta $d021       ; fps counter readability
                rts




*=$2000
incbin  chaingun_hd.spd,3

incasm  utils.asm
incasm  lookuptables.asm
incasm  gameMap.asm
incasm  player.asm
incasm  inputhandling.asm
incasm  ray.asm
incasm  renderer.asm
incasm  assets.asm


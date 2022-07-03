; 10 SYS (2069)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $39, $29, $00, $00, $00
*=$0815

SCREEN_WIDTH=#40
SCREEN_HEIGHT=#25
HALF_SCREEN_HEIGHT=#13
HALF_FOV=#20
DEFAULT_SCREEN_CHARACTER=#$A0
BG_COLOR=#1

SPRITES_MEMORY_START=$2000
SCREEN_FRAME_COLOR=#14

synch=$71       
main_ticks=$72
irq_ticks=$73

;;---------------------------------------------
;; main
;;---------------------------------------------
main            
                jsr setup
@mainloop
                        lda synch
                        bne @continue
                        jsr compute_frame
                        jsr compute_objects
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
                jsr draw_objects
                lda #SCREEN_FRAME_COLOR
                sta $D020               ; frame color
                jsr check_keyboard
                jsr update_objects
                jsr update_doors

                lda #0
                sta synch

frame_not_ready 
                dec irq_ticks
                bne @end
@update_fps     
                lda main_ticks
                sta $400
                
                lda #0
                sta main_ticks
                lda #50
                sta irq_ticks
@end            

;                ldx #0
;                dec objectPosY,x
;                inx
;                dec objectPosX,x
;                inx
;                inc objectPosY,x
;                lda $d02a               ; enemy sprite color test
;                eor #%00000100
;                sta $d02a
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
                lda #$36
                sta $0001      ; Turn Off BASIC ROM

                lda #0
                sta main_ticks
                sta synch
                lda #50
                sta irq_ticks
                
                jsr player_setup
                jsr objects_setup
                jsr screen_setup
                jsr irq_setup
                jsr raycaster_setup
                jsr sprites_setup
                jsr doors_setup
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

; virual rays used to simplify enemy sprite visibility calculations at screen borders
; C5C8, C5C9, C5CA, C5CB (virtual rays 40, 41, 42, 43)
; C69F, C6A0, C6A1, C6A2 (wirtual rays -1, -2, -3, -4)
                lda #0
                sta $C5C8
                sta $C5C9
                sta $C5CA
                sta $C5CB

                sta $C69F
                sta $C6A0
                sta $C6A1
                sta $C6A2

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
                lda #BG_COLOR          ; set bg color 
                sta $d021       ; fps counter readability
                rts


incasm  utils.asm
incasm  renderer.asm
incasm  gameMap.asm
*=SPRITES_MEMORY_START
incbin  chaingun_hd.spd,3
incbin  masking_sprite_xtd.spd,3
incbin  enemy2.spd,3
incasm  assets.asm

incasm  player.asm
incasm  inputhandling.asm
incasm  ray.asm
incasm  object_ray.asm
incasm  sprites.asm
incasm  weapons.asm
incasm  lookuptables.asm
incasm  object.asm
incasm  doors.asm
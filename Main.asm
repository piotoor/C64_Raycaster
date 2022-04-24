; 10 SYS (4096)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

*=$1000

screen_width=#40
screen_height=#25
half_fov=#20
pra=$dc00       ; CIA#1 (Port Register A)
prb=$dc01       ; CIA#1 (Port Register B)
ddra=$dc02      ; CIA#1 (Data Direction Register A)
ddrb=$dc03      ; CIA#1 (Data Direction Register B)

;;---------------------------------------------
;; main
;;---------------------------------------------
main            
                jsr setup
                jmp *       ; infinite loop
                
;;---------------------------------------------
;; irq
;;---------------------------------------------
irq             
                dec $d019               ; acknowledge IRQ / clear register for next interrupt
                jsr check_keyboard 
                jsr compute_frame
                jsr draw_frame
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

                lda #$00    ; trigger interrupt at row zero
                sta $d012

                cli
                rts

;;---------------------------------------------
;; setup
;;---------------------------------------------             
setup
                jsr player_setup
                jsr screen_setup
                jsr irq_setup
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
                sta theta
                rts

;;---------------------------------------------
;; screen_setup
;;
;; Fills the entire screen with A0 char
;;---------------------------------------------
screen_setup     
                ldx #0 
@loop                   lda #$A0
                        sta $0400,x
                        sta $0500,x
                        sta $0600,x
                        sta $06e8,x                        
                inx
                bne @loop 
                rts




incasm  utils.asm
incasm  lookuptables.asm
incasm  gameMap.asm
incasm  player.asm
incasm  inputhandling.asm
incasm  ray.asm
incasm  renderer.asm
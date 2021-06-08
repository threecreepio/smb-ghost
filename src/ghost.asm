LoadedAreaPointer = $77F0
GhostTicks        = $77F1
GhostData         = $77F2
GhostArea         = $77F4
GhostPage         = $77F5
GhostActive       = $77F6
GhostX            = $77F7
GhostY            = $77F8

.org $8000

GhostInit:
    lda #<GhostDataStart
    sta GhostData
    lda #>GhostDataStart
    sta GhostData+1
    lda #0
    sta GhostTicks
    sta GhostArea
    sta GhostPage
    sta GhostX
    sta GhostY
    lda #1
    sta GhostActive
    rts

Ghost:
    ; ghost no longer active
    lda GhostActive
    beq @Exit
    ; make sure we are in game
    lda OperMode
    cmp #1
    bne @Exit
    lda OperMode_Task
    cmp #3
    bne @Exit
    ; only update every other frame
    inc GhostTicks
    lda GhostTicks
    and #%1
    bne @Exit
    ; copy data pointer to zeropage
    ldy #0
    lda GhostData
    sta $0
    lda GhostData+1
    sta $1

@KeepReading:
    ; ghost no longer active
    lda GhostActive
    beq @Finish

    lda ($0),y
    cmp #$F0
    bcc @Movement
    ; update fixed value
    bne @SetValue
    ldx #0
    stx GhostPage
@SetValue:
    sec
    sbc #$F0
    tax
    iny
    lda ($0),y
    sta GhostArea,x
    iny
    bvc @KeepReading

@Movement:
    sta GhostY
    iny
    lda ($0),y
    sta GhostX
    iny

@Finish:
    clc
    sty $2
    lda $0
    adc $2
    sta GhostData
    lda $1
    adc #0
    sta GhostData+1
    jmp PositionGhost

@Exit:
    rts


PositionGhost:
    ; if we're not in the same area as the ghost, exit.
    lda LoadedAreaPointer
    cmp GhostArea
    bne @Exit
    ; calculate x position on screen
    sec
    lda ScreenRight_X_Pos
    sbc GhostX
    tax
    lda ScreenRight_PageLoc
    sbc GhostPage
    ; if we're off screen, exit.
    bne @Exit
    ; otherwise invert x position
    txa
    eor #$FF
    sta $0
    lda GhostY
    beq @Exit
    sta $2FC ; sprite y position
    lda #0
    sta $2FE ; sprite attribute
    lda #$75
    sta $2FD ; sprite tile number
    lda $0
    adc #$08
    sta $2FF ; sprite x position
@Exit:
    rts

GhostDataStart:
.include "ghostpath.asm"
@EOF:
.byte $F2,$00,$00,$00

.scope
Footer $3
.endscope


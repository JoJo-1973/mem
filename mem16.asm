; Macro per la manipolazione di valori a 16 bit

; Titolo:                 MACRO: Sposta un valore costante o un puntatore a 16 bit ad una destinazione specificata
; Nome:                   Mov16
; Descrizione:            Sposta un valore costante o un puntatore a 16 bit ad una destinazione specificata usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                                "IMM" = Immediato: l'operando è un valore a 16 bit e la destinazione è un indirizzo o una coppia di registri
;                                "ABS" = Assoluto: sorgente e destinazione sono indirizzi assoluti; uno dei due può essere una coppia di registri
;                                "ZP"   = Pagina Zero: sorgente e destinazione sono indirizzi in pagina zero; uno dei due può essere una coppia di registri
;
;                                Le coppie di registri sono espresse come ".<r_hi><r_lo>", ad esempio ".AX"
;                         .src_:  Sorgente dello spostamento
;                         .dest_: Destinazione dello spostamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Mov16 .mode_, .src_, .dest_ {
  !if (.mode_ = "IMM") {            
    !if (.src_ = 0) {                  ; Caso 1: .src_ = 0, .dest_ è una coppia di registri
      !if (.dest_ = ".AX") {           
        lda #0
        tax
      } else if (.dest_ = ".AY") {
        lda #0
        tay
      } else if (.dest_ = ".XY") {
        ldx #0
        ldy #0
      } else if (.dest_ = ".XA") {
        ldx #0
        txa
      } else if (.dest_ = ".YA") {
        ldy #0
        tya
      } else if (.dest_ = ".YX") {
        ldy #0
        ldx #0
      } else {                      ; Caso 2: .src_ = 0, .dest_ è un indirizzo
        lda #0
        sta .dest_+1
        sta .dest_
      }
    } else if (.src_ = $FFFF) {    ; Caso 3: .src_ = $FFFF, .dest_ è una coppia di registri
      !if (.dest_ = ".AX") {
        lda #$FF
        tax
      } else if (.dest_ = ".AY") {
        lda #$FF
        tay
      } else if (.dest_ = ".XY") {
        ldx #$FF
        ldy #$FF
      } else if (.dest_ = ".XA") {
        ldx #$FF
        txa
      } else if (.dest_ = ".YA") {
        ldy #$FF
        tya
      } else if (.dest_ = ".YX") {
        ldy #$FF
        ldx #$FF
      } else {                    ; Caso 4: .src_ = $FFFF, .dest_ è un indirizzo
        lda #$FF
        sta .dest_+1
        sta .dest_
      }
    } else {
      !if (.dest_ = ".AX") {           ; Caso 5: .src_ è una costante a 16 bit, .dest_ è una coppia di registri
        lda #>.src_
        ldx #<.src_
      } else if (.dest_ = ".AY") {
        lda #>.src_
        ldy #<.src_
      } else if (.dest_ = ".XY") {
        ldx #>.src_
        ldy #<.src_
      } else if (.dest_ = ".XA") {
        ldx #>.src_
        lda #<.src_
      } else if (.dest_ = ".YA") {
        ldy #>.src_
        lda #<.src_
      } else if (.dest_ = ".YX") {
        ldy #>.src_
        ldx #<.src_
      } else {                        ; Caso 6: .src_ è una costante a 16 bit, .dest_ è un indirizzo.
        lda #>.src_
        sta .dest_+1
        lda #<.src_
        sta .dest_
      }
    }
  } else if (.mode_ = "ABS") {
    !if (.dest_ = ".AX") {           ; Caso 1: .src_ è un indirizzo, .dest_ è una coppia di registri
      lda+2 .src_+1
      ldx+2 .src_
    } else if (.dest_ = ".AY") {
      lda+2 .src_+1
      ldy+2 .src_
    } else if (.dest_ = ".XY") {
      ldx+2 .src_+1
      ldy+2 .src_
    } else if (.dest_ = ".XA") {
      ldx+2 .src_+1
      lda+2 .src_
    } else if (.dest_ = ".YA") {
      ldy+2 .src_+1
      lda+2 .src_
    } else if (.dest_ = ".YX") {
      ldy+2 .src_+1
      ldx+2 .src_
    } else if (.src_ = ".AX") {    ; Caso 2: .src_ è una coppia di registri, .dest_ è un indirizzo
      sta+2 .dest_+1
      stx+2 .dest_
    } else if (.src_ = ".AY") {
      sta+2 .dest_+1
      sty+2 .dest_
    } else if (.src_ = ".XY") {
      stx+2 .dest_+1
      sty+2 .dest_
    } else if (.src_ = ".XA") {
      stx+2 .dest_+1
      sta+2 .dest_
    } else if (.src_ = ".YA") {
      sty+2 .dest_+1
      sta+2 .dest_
    } else if (.src_ = ".YX") {
      sty+2 .dest_+1
      stx+2 .dest_
    } else if (.src_ > .dest_) {  ; Caso 3: .src_ si trova più avanti rispetto a .dest_
      lda+2 .src_                ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_               ; più piccolo al più grande  

      lda+2 .src_+1
      sta+2 .dest_+1
    } else if (.src_ < .dest_) {  ; Caso 4: .src_ si trova più indietro rispetto a .dest_
      lda+2 .src_+1              ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_+1             ; più grande al più piccolo  

      lda+2 .src_
      sta+2 .dest_
    } else if (.src_ = .dest_) {  ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
    }
  } else if (.mode_ = "ZP") {
    !if (.dest_ = ".AX") {       ; Caso 1: .src_ è un indirizzo, .dest_ è una coppia di registri
      lda+1 .src_+1
      ldx+1 .src_
    } else if (.dest_ = ".AY") {
      lda+1 .src_+1
      ldy+1 .src_
    } else if (.dest_ = ".XY") {
      ldx+1 .src_+1
      ldy+1 .src_
    } else if (.dest_ = ".XA") {
      ldx+1 .src_+1
      lda+1 .src_
    } else if (.dest_ = ".YA") {
      ldy+1 .src_+1
      lda+1 .src_
    } else if (.dest_ = ".YX") {
      ldy+1 .src_+1
      ldx+1 .src_
    } else if (.src_ = ".AX") {  ; Caso 2: .src_ è una coppia di registri, .dest_ è un indirizzo
      sta+1 .dest_+1
      stx+1 .dest_
    } else if (.src_ = ".AY") {
      sta+1 .dest_+1
      sty+1 .dest_
    } else if (.src_ = ".XY") {
      stx+1 .dest_+1
      sty+1 .dest_
    } else if (.src_ = ".XA") {
      stx+1 .dest_+1
      sta+1 .dest_
    } else if (.src_ = ".YA") {
      sty+1 .dest_+1
      sta+1 .dest_
    } else if (.src_ = ".YX") {
      sty+1 .dest_+1
      stx+1 .dest_
    } else if (.src_ > .dest_) {  ; Caso 3: .src_ si trova più avanti rispetto a .dest_
      lda+1 .src_                ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_               ; più piccolo al più grande  

      lda+1 .src_+1
      sta+1 .dest_+1
    } else if (.src_ < .dest_) {  ; Caso 4: .src_ si trova più indietro rispetto a .dest_
      lda+1 .src_+1              ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_+1             ; più grande al più piccolo  

      lda+1 .src_
      sta+1 .dest_
    } else if (.src_ = .dest_) {  ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
    }
  }
}

; Titolo:                 MACRO: Scambia di valore due puntatori a 16 bit
; Nome:                   Swap16
; Descrizione:            Scambia di valore due puntatori a 16 bit usando i registri.
; Parametri di ingresso:  .addr1_: Indirizzo del primo valore
;                         .addr2_: Indirizzo del secondo valore
; Parametri di uscita:    ---
; Alterazioni registri:   .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     system/standard.asm
!macro Swap16 .addr1_, .addr2_ {
  +Swap8 .addr1_+1, .addr2_+1   ; Scambia prima i byte alti
  +Swap8 .addr1_, .addr2_       ; e poi quelli bassi
}

; Titolo:                 MACRO: Confronta 2 valori senza segno a 16 bit
; Nome:                   CmpU16
; Descrizione:            Esegui il confronto tra due valori senza segno a 16 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                                "IMM" = Immediato: il primo operando è un indirizzo o una coppia di registri, il secondo operando è un valore a 16 bit
;                                "ABS" = Assoluto: gli operandi sono indirizzi assoluti; il primo può essere una coppia di registri
;                                "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero; il primo può essere una coppia di registri
;
;                                Le coppie di registri sono espresse come ".<r_hi><r_lo>", ad esempio ".AX"
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpU16 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    !if (.op1_ = ".AX") {
      cmp #>.op2_            ; Caso 1: .op1_ è una coppia di registri, .op2_ è una costante a 16 bit
      bne +
      cpx #<.op2_
    +
    } else if (.op1_ = ".AY") {
      cmp #>.op2_
      bne +
      cpy #<.op2_
    +
    } else if (.op1_ = ".XY") {
      cpx #>.op2_
      bne +
      cpy #<.op2_
    +
    } else if (.op1_ = ".XA") {
      cpx #>.op2_
      bne +
      cmp #<.op2_
    +
    } else if (.op1_ = ".YA") {
      cpy #>.op2_
      bne +
      cmp #<.op2_
    +
    } else if (.op1_ = ".YX") {
      cpy #>.op2_
      bne +
      cpx #<.op2_
    +
    } else if (.op2_ = 0) { ; Caso 2: .op1_ è un indirizzo, .op2_ = 0
      lda .op1_+1
      ora .op1_
      sec               ; Poni C=1 per imitare il comportamento di CMP: qualunque numero senza segno è >= 0
    } else {
      lda .op1_+1          ; Caso 3: .op1_ è un indirizzo, .op2_ è una costante a 16 bit.
      cmp #>.op2_
      bne +
      lda .op1_
      cmp #<.op2_
    +
    }
  } else if (.mode_ = "ABS") {
    !if (.op1_ = ".AX") {  ; Caso 1: .op1_ è una coppia di registri, .op2_ è un indirizzo
      cmp+2 .op2_+1
      bne +
      cpx+2 .op2_
    +
    } else if (.op1_ = ".AY") {
      cmp+2 .op2_+1
      bne +
      cpy+2 .op2_
    +
    } else if (.op1_ = ".XY") {
      cpx+2 .op2_+1
      bne +
      cpy+2 .op2_
    +
    } else if (.op1_ = ".XA") {
      cpx+2 .op2_+1
      bne +
      cmp+2 .op2_
    +
    } else if (.op1_ = ".YA") {
      cpy+2 .op2_+1
      bne +
      cmp+2 .op2_
    +
    } else if (.op1_ = ".YX") {
      cpy+2 .op2_+1
      bne +
      cpx+2 .op2_
    +
    } else {              ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
      lda .op1_+1
      cmp+2 .op2_+1
      bne +
      lda .op1_
      cmp+2 .op2_
    +
    }
  } else if (.mode_ = "ZP") {
    !if (.op1_ = ".AX") {  ; Caso 1: .op1_ è una coppia di registri, .op2_ è un indirizzo
      cmp+1 .op2_+1
      bne +
      cpx+1 .op2_
    +
    } else if (.op1_ = ".AY") {
      cmp+1 .op2_+1
      bne +
      cpy+1 .op2_
    +
    } else if (.op1_ = ".XY") {
      cpx+1 .op2_+1
      bne +
      cpy+1 .op2_
    +
    } else if (.op1_ = ".XA") {
      cpx+1 .op2_+1
      bne +
      cmp+1 .op2_
    +
    } else if (.op1_ = ".YA") {
      cpy+1 .op2_+1
      bne +
      cmp+1 .op2_
    +
    } else if (.op1_ = ".YX") {
      cpy+1 .op2_+1
      bne +
      cpx+1 .op2_
    +
    } else {    ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
      lda .op1_+1
      cmp+1 .op2_+1
      bne +
      lda .op1_
      cmp+1 .op2_
    +
    }
  }
}

; Titolo:                 MACRO: Confronta 2 valori con segno a 16 bit.
; Nome:                   CmpS16
; Descrizione:            Esegui il confronto tra due valori con segno a 16 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                                "IMM" = Immediato: il primo operando è un indirizzo, il secondo operando è un valore a 16 bit
;                                "ABS" = Assoluto: gli operandi sono indirizzi assoluti
;                                "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpS16 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    lda .op1_              
    cmp #<.op2_

    lda .op1_+1
    sbc #>.op2_  ; Il flag di Carry è già impostato dall'istruzione CMP precedente
  } else if (.mode_ = "ABS") {
    lda+2 .op1_
    cmp+2 .op2_

    lda+2 .op1_+1
    sbc+2 .op2_+1  ; Il flag di Carry è già impostato dall'istruzione CMP precedente
  } else if (.mode_ = "ZP") {
    lda+1 .op1_
    cmp+1 .op2_

    lda+1 .op1_+1
    sbc+1 .op2_+1  ; Il flag di Carry è già impostato dall'istruzione CMP precedente
  }
}

; Titolo:                 MACRO: Incrementa un contatore a 16 bit
; Nome:                   Inc16
; Descrizione:            Incrementa un contatore contenuto in un puntatore o in una coppia di registri.
;                         Le coppie di registri sono espresse come ".<r_hi><r_lo>", ad esempio ".AX"
; Parametri di ingresso:  .addr_: Indirizzo del contatore; può essere una coppia di registri
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Inc16 .addr_ {
  !if (.addr_ = ".AX") {        ; Caso 1: .addr_ è una coppia di registri
    inx
    bne +
    clc
    adc #1
  +
  } else if (.addr_ = ".AY") {
    iny
    bne +
    clc
    adc #1
  +
  } else if (.addr_ = ".XY") {
    iny
    bne +
    inx
  +
  } else if (.addr_ = ".XA") {
    clc
    adc #1
    bne +
    inx
  +
  } else if (.addr_ = ".YA") {
    clc
    adc #1
    bne +
    iny
  +
  } else if (.addr_ = ".YX") {
    inx
    bne +
    iny
  +
  } else {        ; Caso 2: .addr_ è un indirizzo
    inc .addr_
    bne +
    inc .addr_+1
  +
  }
}

; Titolo:                 MACRO: Decrementa un contatore a 16 bit
; Nome:                   Dec16
; Descrizione:            Decrementa un contatore contenuto in un puntatore o in una coppia di registri.
;                         Le coppie di registri sono espresse come ".<r_hi><r_lo>", ad esempio ".AX"
; Parametri di ingresso:  .addr_: Indirizzo del contatore; può essere una coppia di registri
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Dec16 .addr_ {
  !if (.addr_ = ".AX") {     ; Caso 1: .addr_ è una coppia di registri
    cpx #0
    bne +
    sec
    sbc #1
  + dex
  } else if (.addr_ = ".AY") {
    cpy #0
    bne +
    sec
    sbc #1
  + dey
  } else if (.addr_ = ".XY") {
    cpy #0
    bne +
    dex
  + dey
  } else if (.addr_ = ".XA") {
    cmp #0
    bne +
    dex
  + sec
    sbc #1
  } else if (.addr_ = ".YA") {
    cmp #0
    bne +
    dey
  + sec
    sbc #1
  } else if (.addr_ = ".YX") {
    cpx #0
    bne +
    dey
  + dex
  } else {        ; Caso 2: .addr_ è un indirizzo
    lda .addr_
    bne +
    dec .addr_+1
  + dec .addr_
  }
}

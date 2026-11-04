; Macro per la manipolazione di valori a 24 bit

; Titolo:                 MACRO: Sposta un valore costante o un puntatore a 24 bit ad una destinazione specificata
; Nome:                   Mov24
; Descrizione:            Sposta un valore costante o un puntatore a 24 bit ad una destinazione specificata usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: l'operando è un valore a 24 bit e la destinazione è un indirizzo o una terna di registri
;                               "ABS" = Assoluto: sorgente e destinazione sono indirizzi assoluti; uno dei due può essere una terna di registri
;                               "ZP"  = Pagina Zero: sorgente e destinazione sono indirizzi in pagina zero; uno dei due può essere una terna di registri
;
;                               Le terne di registri sono espresse come ".<r_hi><r_mid><r_lo>", ad esempio ".AXY"
;                         .src_:  Sorgente dello spostamento
;                         .dest_: Destinazione dello spostamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Mov24 .mode_, .src_, .dest_ {
  !if (.mode_ = "IMM") {
    !if (.src_ = 0) {
      !if (.dest_ = ".AXY") {     ; Caso 1: .src_ = 0, .dest_ è una terna di registri
        lda #0
        tax
        tay
      } else if (.dest_ = ".YXA") {
        lda #0
        tax
        tay
      } else {    ; Caso 2: .src_ = 0, .dest_ è un indirizzo
        lda #0
        sta .dest_+2
        sta .dest_+1
        sta .dest_
      }
    } else if (.src_ = $FFFFFF) { ; Caso 3: .src_ = $FFFFFF, .dest_ è una terna di registri
      !if (.dest_ = ".AXY") {
        lda #$FF
        tax
        tay
      } else if (.dest_ = ".YXA") {
        lda #$FF
        tax
        tay
      } else {          ; Caso 4: .src_ = $FFFFFF, .dest_ è un indirizzo
        lda #$FF
        sta .dest_+2
        sta .dest_+1
        sta .dest_
      }
    } else {
      !if (.dest_ = ".AXY") {   ; Caso 5: .src_ è una costante a 24 bit, .dest_ è una terna di registri
        lda #(.src_ & $FF0000) >> 16
        ldx #(.src_ & $00FF00) >> 8
        ldy #(.src_ & $0000FF) >> 0
      } else if (.dest_ = ".YXA") {
        ldy #(.src_ & $FF0000) >> 16
        ldx #(.src_ & $00FF00) >> 8
        lda #(.src_ & $0000FF) >> 0
      } else {                  ; Caso 6: .src_ è una costante a 24 bit, .dest_ è un indirizzo
        lda #(.src_ & $FF0000) >> 16
        sta .dest_+2
        lda #(.src_ & $00FF00) >> 8
        sta .dest_+1
        lda #(.src_ & $0000FF) >> 0
        sta .dest_
      }
    }
  } else if (.mode_ = "ABS") {
    !if (.dest_ = ".AXY") {   ; Caso 1: .src_ è un indirizzo, .dest_ è una terna di registri
      lda+2 .src_+2
      ldx+2 .src_+1
      ldy+2 .src_
    } else if (.dest_ = ".YXA") {
      ldy+2 .src_+2
      ldx+2 .src_+1
      lda+2 .src_
    } else if (.src_ = ".AXY") { ; Caso 2: .src_ è una terna di registri, .dest_ è un indirizzo
      sta+2 .dest_+2
      stx+2 .dest_+1
      sty+2 .dest_
    } else if (.src_ = ".YXA") {
      sty+2 .dest_+2
      stx+2 .dest_+1
      sta+2 .dest_
    } else if (.src_ > .dest_) {  ; Caso 3: .src_ si trova più avanti rispetto a .dest_
      lda+2 .src_               ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_              ; più piccolo al più grande  

      lda+2 .src_+1
      sta+2 .dest_+1

      lda+2 .src_+2
      sta+2 .dest_+2
    } else if (.src_ < .dest_) {  ; Caso 4: .src_ si trova più indietro rispetto a .dest_
      lda+2 .src_+2             ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_+2            ; più grande al più piccolo  

      lda+2 .src_+1
      sta+2 .dest_+1

      lda+2 .src_
      sta+2 .dest_
    } else if (.src_ = .dest_) {  ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
    }
  } else if (.mode_ = "ZP" ) {
    !if (.dest_ = ".AXY") { ; Caso 1: .src_ è un indirizzo, .dest_ è una terna di registri
      lda+1 .src_+2
      ldx+1 .src_+1
      ldy+1 .src_
    } else if (.dest_ = ".YXA") {
      ldy+1 .src_+2
      ldx+1 .src_+1
      lda+1 .src_
    } else if (.src_ = ".AXY") { ; Caso 2: .src_ è una terna di registri, .dest_ è un indirizzo
      sta+1 .dest_+2
      stx+1 .dest_+1
      sty+1 .dest_
    } else if (.src_ = ".YXA") {
      sty+1 .dest_+2
      stx+1 .dest_+1
      sta+1 .dest_
    } else if (.src_ > .dest_) {  ; Caso 3: .src_ si trova più avanti rispetto a .dest_
      lda+1 .src_               ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_              ; più piccolo al più grande  

      lda+1 .src_+1
      sta+1 .dest_+1

      lda+1 .src_+2
      sta+1 .dest_+2
    } else if (.src_ < .dest_) {   ; Caso 4: .src_ si trova più indietro rispetto a .dest_
      lda+1 .src_+2              ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_+2             ; più grande al più piccolo  

      lda+1 .src_+1
      sta+1 .dest_+1

      lda+1 .src_
      sta+1 .dest_
    } else if (.src_ = .dest_) {  ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
    }
  }
}

; Titolo:                 MACRO: Scambia di valore due puntatori a 24 bit
; Nome:                   Swap24
; Descrizione:            Scambia di valore due puntatori a 24 bit usando i registri.
; Parametri di ingresso:  .addr1_: Indirizzo del primo valore
;                         .addr2_: Indirizzo del secondo valore
; Parametri di uscita:    ---
; Alterazioni registri:   .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     system/standard.asm
!macro Swap24 .addr1_, .addr2_ {
  +Swap8 .addr1_+2, .addr2_+2   ; Scambia prima i byte alti
  +Swap8 .addr1_+1, .addr2_+1   ; poi quelli medi
  +Swap8 .addr1_, .addr2_       ; ed infine quelli bassi
}

; Titolo:                 MACRO: Confronta 2 valori senza segno a 24 bit
; Nome:                   CmpU24
; Descrizione:            Esegui il confronto tra due valori senza segno a 24 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo o una terna di registri, il secondo operando è un valore a 24 bit
;                               "ABS" = Assoluto: gli operandi sono indirizzi assoluti; il primo può essere una terna di registri
;                               "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero; il primo può essere una terna di registri
;
;                               Le terne di registri sono espresse come ".<r_hi><r_mid><r_lo>", ad esempio ".AXY"
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpU24 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    !if (.op1_ = ".AXY") {           ; Caso 1: .op1_ è una terna di registri, .op2_ è una costante a 24 bit
      cmp #(.op2_ & $FF0000) >> 16
      bne +
      cpx #(.op2_ & $00FF00) >> 8
      bne +
      cpy #(.op2_ & $0000FF) >> 0
    +
    } else if (.op1_ = ".YXA") {
      cpy #(.op2_ & $FF0000) >> 16
      bne +
      cpx #(.op2_ & $00FF00) >> 8
      bne +
      cmp #(.op2_ & $0000FF) >> 0
    +
    } else if (.op2_ = 0) {          ; Caso 2: .op1_ è un indirizzo, .op2_ = 0
      lda .op1_+2
      ora .op1_+1
      ora .op1_
      sec                           ; Poni C=1 per imitare il comportamento di CMP: qualunque numero senza segno è >= 0
    } else {                        ; Caso 3: .op1_ è un indirizzo, .op2_ è una costante a 24 bit.
      lda .op1_+2
      cmp #(.op2_ & $FF0000) >> 16
      bne +
      lda .op1_+1
      cmp #(.op2_ & $00FF00) >> 8
      bne +
      lda .op1_
      cmp #(.op2_ & $0000FF) >> 0
    +
    }
  } else if (.mode_ = "ABS") {
    !if (.op1_ = ".AXY") {       ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo
      cmp+2 .op2_+2
      bne +
      cpx+2 .op2_+1
      bne +
      cpy+2 .op2_
    +
    } else if (.op1_ = ".YXA") {
      cpy+2 .op2_+2
      bne +
      cpx+2 .op2_+1
      bne +
      cmp+2 .op2_
    +
    } else {                  ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo
      lda+2 .op1_+2
      cmp+2 .op2_+2
      bne +
      lda+2 .op1_+1
      cmp+2 .op2_+1
      bne +
      lda+2 .op1_
      cmp+2 .op2_
    +
    }
  } else if (.mode_ = "ZP" ) {
    !if (.op1_ = ".AXY") {   ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo
      cmp+1 .op2_+2
      bne +
      cpx+1 .op2_+1
      bne +
      cpy+1 .op2_
    +
    } else if (.op1_ = ".YXA") {
      cpy+1 .op2_+2
      bne +
      cpx+1 .op2_+1
      bne +
      cmp+1 .op2_
    +
    } else {                ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo
      lda+1 .op1_+2
      cmp+1 .op2_+2
      bne +
      lda+1 .op1_+1
      cmp+1 .op2_+1
      bne +
      lda+1 .op1_
      cmp+ .op2_
    +
    }
  }
}

; Titolo:                 MACRO: Confronta 2 valori con segno a 24 bit
; Nome:                   CmpS24
; Descrizione:            Esegui il confronto tra due valori con segno a 24 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo, il secondo operando è un valore a 24 bit
;                               "ABS" = Assoluto: gli operandi sono indirizzi assoluti
;                               "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpS24 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    lda .op1_
    cmp #(.op2_ & $0000FF) >> 0
    lda .op1_+1
    sbc #(.op2_ & $00FF00) >> 8      ; Il flag di Carry è già impostato dall'istruzione CMP precedente
    lda .op1_+2
    sbc #(.op2_ & $FF0000) >> 16
  } else if (.mode_ = "ABS") {
    lda+2 .op1_
    cmp+2 .op2_

    lda+2 .op1_+1
    sbc+2 .op2_+1                    ; Il flag di Carry è già impostato dall'istruzione CMP precedente

    lda+2 .op1_+2
    sbc+2 .op2_+2
  } else if (.mode_ = "ZP" ) {
    lda+1 .op1_
    cmp+1 .op2_

    lda+1 .op1_+1
    sbc+1 .op2_+1                    ; Il flag di Carry è già impostato dall'istruzione CMP precedente

    lda+1 .op1_+2
    sbc+1 .op2_+2
  }
}

; Titolo:                 MACRO: Incrementa un contatore a 24 bit
; Nome:                   Inc24
; Descrizione:            Incrementa un contatore contenuto in un puntatore o in una terna di registri.
;                         Le terne di registri sono espresse come ".<r_hi><r_mid><r_lo>", ad esempio ".AXY"
; Parametri di ingresso:  .addr_: Indirizzo del contatore; può essere una terna di registri
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Inc24 .addr_ {
  !if (.addr_ = ".AXY") {      ; Caso 1: .addr_ è una terna di registri
    iny
    bne +
    inx
    bne +
    clc
    adc #1
  +
  } else if (.addr_ = ".YXA") {
    clc
    adc #1
    bne +
    inx
    bne +
    iny
  +
  } else {                  ; Caso 2: .addr_ è un indirizzo
    inc .addr_
    bne +
    inc .addr_+1
    bne +
    inc .addr_+2
  +
  }
}

; Titolo:                 MACRO: Decrementa un contatore a 24 bit
; Nome:                   Dec24
; Descrizione:            Decrementa un contatore contenuto in un puntatore o in una terna di registri.
;                         Le terne di registri sono espresse come ".<r_hi><r_mid><r_lo>", ad esempio ".AXY"
; Parametri di ingresso:  .addr_: Indirizzo del contatore; può essere una terna di registri
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Dec24 .addr_ {
  !if (.addr_ = ".AXY") {  ; Caso 1: .addr_ è una terna di registri
    cpy #0
    bne @Dec_Low
    cpx #0
    bne @Dec_Mid
    sec
    sbc #1
 @Dec_Mid:
    dex
 @Dec_Low:
    dey
  } else if (.addr_ = ".YXA") {
    cmp #0
    bne @Dec_Low
    cpx #0
    bne @Dec_Mid
    dey
@Dec_Mid:
    dex
@Dec_Low:
    sec
    sbc #1
  } else {                     ; Caso 2: .addr_ è un indirizzo
    lda .addr_
    bne @Dec_Low
    lda .addr_+1
    bne @Dec_Mid
    dec .addr_+2
 @Dec_Mid:
    dec .addr_+1
 @Dec_Low:
    dec .addr_
  }
}

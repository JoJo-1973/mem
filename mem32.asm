; Macro per la manipolazione di valori a 32 bit

; Titolo:                 MACRO: Sposta un valore costante o un puntatore a 32 bit ad una destinazione specificata
; Nome:                   Mov32
; Descrizione:            Sposta un valore costante o un puntatore a 32 bit ad una destinazione specificata usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: l'operando è un valore a 32 bit e la destinazione è un indirizzo
;                               "ABS" = Assoluto: sorgente e destinazione sono indirizzi assoluti
;                               "ZP"  = Pagina Zero: sorgente e destinazione sono indirizzi in pagina zero
;                         .src_:  Sorgente dello spostamento
;                         .dest_: Destinazione dello spostamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Mov32 .mode_, .src_, .dest_ {
  !if (.mode_ = "IMM") {
    !if (.src_ = 0) {      ; Caso 1: .src_ = 0, .dest_ è un indirizzo
      lda #0
      sta .dest_+3
      sta .dest_+2
      sta .dest_+1
      sta .dest_
    } else if (.src_ = $FFFFFFFF) {   ; Caso 2: .src_ = $FFFFFFFF, .dest_ è un indirizzo
      lda #$FF
      sta .dest_+3
      sta .dest_+2
      sta .dest_+1
      sta .dest_
    } else {                          ; Caso 3: .src_ è una costante a 32 bit, .dest_ è un indirizzo  
      lda #(.src_ & $FF000000) >> 24
      sta .dest_+3
      lda #(.src_ & $00FF0000) >> 16
      sta .dest_+2
      lda #(.src_ & $0000FF00) >> 8
      sta .dest_+1
      lda #(.src_ & $000000FF) >> 0
      sta .dest_
    }
  } else if (.mode_ = "ABS") {
    !if (.src_ > .dest_) {         ; Caso 1: .src_ si trova più avanti rispetto a .dest_
      lda+2 .src_                ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_               ; più piccolo al più grande  

      lda+2 .src_+1
      sta+2 .dest_+1

      lda+2 .src_+2
      sta+2 .dest_+2

      lda+2 .src_+3
      sta+2 .dest_+3
    } else if (.src_ < .dest_) {     ; Caso 2: .src_ si trova più indietro rispetto a .dest_
      lda+2 .src_+3                ; Per evitare sovrascritture si procede dall'indirizzo
      sta+2 .dest_+3               ; più grande al più piccolo  

      lda+2 .src_+2
      sta+2 .dest_+2

      lda+2 .src_+1
      sta+2 .dest_+1

      lda+2 .src_
      sta+2 .dest_
    } else if (.src_ = .dest_) {       ; Caso 3: .src_ e .dest_ coincidono: non fare niente!
    }
  } else if (.mode_ = "ZP" ) {       
    !if (.src_ > .dest_) {              ; Caso 1: .src_ si trova più avanti rispetto a .dest_
      lda+1 .src_                     ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_                    ; più piccolo al più grande  

      lda+1 .src_+1
      sta+1 .dest_+1

      lda+1 .src_+2
      sta+1 .dest_+2

      lda+1 .src_+3
      sta+1 .dest_+3
    } else if (.src_ < .dest_) {       ; Caso 2: .src_ si trova più indietro rispetto a .dest_
      lda+1 .src_+3                  ; Per evitare sovrascritture si procede dall'indirizzo
      sta+1 .dest_+3                 ; più grande al più piccolo  

      lda+1 .src_+2
      sta+1 .dest_+2

      lda+1 .src_+1
      sta+1 .dest_+1

      lda+1 .src_
      sta+1 .dest_
    } else if (.src_ = .dest_) {        ; Caso 3: .src_ e .dest_ coincidono: non fare niente!
    }
  }
}

; Titolo:                 MACRO: Scambia di valore due puntatori a 32 bit
; Nome:                   Swap32
; Descrizione:            Scambia di valore due puntatori a 32 bit usando i registri.
; Parametri di ingresso:  .addr1_: Indirizzo del primo valore
;                         .addr2_: Indirizzo del secondo valore
; Parametri di uscita:    ---
; Alterazioni registri:   .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     system/standard.asm
!macro Swap32 .addr1_, .addr2_ {
  +Swap8 .addr1_+3, .addr2_+3   ; Scambia prima i byte alti
  +Swap8 .addr1_+2, .addr2_+2   ; poi quelli medio-alti
  +Swap8 .addr1_+1, .addr2_+1   ; poi quelli medio-bassi
  +Swap8 .addr1_, .addr2_       ; ed infine quelli bassi
}

; Titolo:                 MACRO: Confronta 2 valori senza segno a 32 bit
; Nome:                   CmpU32
; Descrizione:            Esegui il confronto tra due valori senza segno a 32 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo, il secondo operando è un valore a 32 bit
;                               "ABS" = Assoluto: gli operandi sono indirizzi assoluti
;                               "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpU32 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    !if (.op2_ = 0) {          ; Caso 1: .op1_ è un indirizzo, .op2_ = 0
      lda .op1_+3
      ora .op1_+2
      ora .op1_+1
      ora .op1_
      sec                      ; Poni C=1 per imitare il comportamento di CMP: qualunque numero senza segno è >= 0
    } else {                    ; Caso 2: .op1_ è un indirizzo, .op2_ è una costante a 32 bit.
      lda .op1_+3
      cmp #(.op2_ & $FF000000) >> 24
      bne +
      lda .op1_+2
      cmp #(.op2_ & $00FF0000) >> 16
      bne +
      lda .op1_+1
      cmp #(.op2_ & $0000FF00) >> 8
      bne +
      lda .op1_
      cmp #(.op2_ & $000000FF) >> 0
    +
    }
  } else if (.mode_ = "ABS") {
    lda+2 .op1_+3              ; Caso 1: .op1_ è un indirizzo, .op2_ è un indirizzo
    cmp+2 .op2_+3
    bne +
    lda+2 .op1_+2
    cmp+2 .op2_+2
    bne +
    lda+2 .op1_+1
    cmp+2 .op2_+1
    bne +
    lda+2 .op1_
    cmp+2 .op2_
  +
  } else if (.mode_ = "ZP" ) {
    lda+1 .op1_+3              ; Caso 1: .op1_ è un indirizzo, .op2_ è un indirizzo
    cmp+1 .op2_+3
    bne +
    lda+1 .op1_+2
    cmp+1 .op2_+2
    bne +
    lda+1 .op1_+1
    cmp+1 .op2_+1
    bne +
    lda+1 .op1_
    cmp+1 .op2_
  +
  }
}

; Titolo:                 MACRO: Confronta 2 valori con segno a 32 bit
; Nome:                   CmpS32
; Descrizione:            Esegui il confronto tra due valori con segno a 32 bit usando l'indirizzamento scelto.
; Parametri di ingresso:  .mode_: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo, il secondo operando è un valore a 32 bit
;                               "ABS" = Assoluto: gli operandi sono indirizzi assoluti
;                               "ZP"  = Pagina Zero: gli operandi sono indirizzi in pagina zero
;                         .op1_:  Primo operando da confrontare
;                         .op2_:  Secondo operando da confrontare
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro CmpS32 .mode_, .op1_, .op2_ {
  !if (.mode_ = "IMM") {
    lda .op1_                              
    cmp #(.op2_ & $000000FF) >> 0
    lda .op1_+1
    sbc #(.op2_ & $0000FF00) >> 8        ; Il flag di Carry è già impostato dall'istruzione CMP precedente
    lda .op1_+2
    sbc #(.op2_ & $00FF0000) >> 16
    lda .op1_+3
    sbc #(.op2_ & $FF000000) >> 24
  } else if (.mode_ = "ABS") {
    lda+2 .op1_
    cmp+2 .op2_

    lda+2 .op1_+1
    sbc+2 .op2_+1                        ; Il flag di Carry è già impostato dall'istruzione CMP precedente

    lda+2 .op1_+2
    sbc+2 .op2_+2

    lda+2 .op1_+3
    sbc+2 .op2_+3
  } else if (.mode_ = "ZP" ) {
    lda+1 .op1_
    cmp+1 .op2_

    lda+1 .op1_+1
    sbc+1 .op2_+1                        ; Il flag di Carry è già impostato dall'istruzione CMP precedente

    lda+1 .op1_+2
    sbc+1 .op2_+2

    lda+1 .op1_+3
    sbc+1 .op2_+3
  }
}

; Titolo:                 MACRO: Incrementa un contatore a 32 bit
; Nome:                   Inc32
; Descrizione:            Incrementa un contatore contenuto in un puntatore.
; Parametri di ingresso:  .addr_: Indirizzo del contatore
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Inc32 .addr_ {
  inc .addr_
  bne +
  inc .addr_+1
  bne +
  inc .addr_+2
  bne +
  inc .addr_+3
+
}

; Titolo:                 MACRO: Decrementa un contatore a 32 bit
; Nome:                   Dec32
; Descrizione:            Decrementa un contatore contenuto in un puntatore.
; Parametri di ingresso:  .addr_: Indirizzo del contatore
; Parametri di uscita:    ---
; Alterazioni registri:   .A, .X, .Y
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     ---
!macro Dec32 .addr_ {
    lda .addr_
    bne @Dec_Low
    lda .addr_+1
    bne @Dec_Mid_Low
    lda .addr_+2
    bne @Dec_Mid_High
    dec .addr_+3
@Dec_Mid_High:    
    dec .addr_+2
@Dec_Mid_Low:
    dec .addr_+1
@Dec_Low:
    dec .addr_
}

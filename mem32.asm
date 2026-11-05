; ==============================================================================
; FILE:           mem32.asm
; PROGETTO:       Libreria di Sistema (mem.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per la manipolazione di valori a 32 bit.
; CONTENUTO:      m_Mov32   Sposta un valore o un puntatore a 32 bit
;                 m_Swap32  Scambia due puntatori a 32 bit
;                 m_CmpU32  Confronta due valori a 32 bit senza segno
;                 m_CmpS32  Confronta due valori a 32 bit con segno
;                 m_Inc32   Incrementa un contatore a 32 bit
;                 m_Dec32   Decrementa un contatore a 32 bit
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Mov32
; ------------------------------------------------------------------------------
; Descrizione:  Copia un valore costante o un puntatore a 32 bit dalla sorgente
;               alla destinazione, secondo l'indirizzamento scelto. A 32 bit non
;               sono previsti gruppi di registri: gli operandi sono indirizzi.
;
;                 "IMM"  Immediato: .src_ è un valore a 32 bit e .dest_ è un
;                        indirizzo.
;                 "ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti.
;                 "ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
;                        zero.
;
;               Con "IMM" una costante con i quattro byte uguali (per esempio 0,
;               $FFFFFFFF o $42424242) usa una sequenza più breve. Con "ABS" e
;               "ZP" la copia procede nel verso che non altera il sorgente se le
;               due aree si sovrappongono.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .src_ (4 byte, Macro)   : Valore (IMM) o indirizzo
;   - .dest_ (4 byte, Macro)  : Indirizzo
;
; Output:
;   - .dest_ (4 byte, Macro)  : Riceve il valore di .src_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Mov32 .mode_, .src_, .dest_ {
    !if (.mode_ = "IMM") {
      !if (.src_ = ((.src_ & $FF) * $01010101)) { ; Caso 1: i quattro byte di .src_ sono uguali, .dest_ è
                                                  ; un indirizzo.
        lda #<.src_
        sta .dest_+3
        sta .dest_+2
        sta .dest_+1
        sta .dest_
      } else {                                    ; Caso 2: .src_ è una costante a 32 bit, .dest_ è
                                                  ; un indirizzo.
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
      !if (.src_ > .dest_) {                      ; Caso 1: .src_ si trova più avanti rispetto a .dest_.
        lda+2 .src_                               ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_                              ; più piccolo al più grande.

        lda+2 .src_+1
        sta+2 .dest_+1

        lda+2 .src_+2
        sta+2 .dest_+2

        lda+2 .src_+3
        sta+2 .dest_+3
      } else if (.src_ < .dest_) {                ; Caso 2: .src_ si trova più indietro rispetto a .dest_.
        lda+2 .src_+3                             ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_+3                            ; più grande al più piccolo.

        lda+2 .src_+2
        sta+2 .dest_+2

        lda+2 .src_+1
        sta+2 .dest_+1

        lda+2 .src_
        sta+2 .dest_
      } else if (.src_ = .dest_) {                ; Caso 3: .src_ e .dest_ coincidono: non fare niente!
      }
    } else if (.mode_ = "ZP" ) {
      !if (.src_ > .dest_) {                      ; Caso 1: .src_ si trova più avanti rispetto a .dest_.
        lda+1 .src_                               ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_                              ; più piccolo al più grande.

        lda+1 .src_+1
        sta+1 .dest_+1

        lda+1 .src_+2
        sta+1 .dest_+2

        lda+1 .src_+3
        sta+1 .dest_+3
      } else if (.src_ < .dest_) {                ; Caso 2: .src_ si trova più indietro rispetto a .dest_.
        lda+1 .src_+3                             ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_+3                            ; più grande al più piccolo.

        lda+1 .src_+2
        sta+1 .dest_+2

        lda+1 .src_+1
        sta+1 .dest_+1

        lda+1 .src_
        sta+1 .dest_
      } else if (.src_ = .dest_) {                ; Caso 3: .src_ e .dest_ coincidono: non fare niente!
      }
    } else {
      !error "Illegal addressing mode in m_Mov32: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Swap32
; ------------------------------------------------------------------------------
; Descrizione:  Scambia il valore di due puntatori a 32 bit usando i registri.
;
; Input:
;   - .addr1_ (4 byte, Macro) : Indirizzo del primo valore
;   - .addr2_ (4 byte, Macro) : Indirizzo del secondo valore
;
; Output:
;   - .addr1_ (4 byte, Macro) : Riceve il valore di .addr2_
;   - .addr2_ (4 byte, Macro) : Riceve il valore di .addr1_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .X, .Y, .P (Negative, Zero)
; Dipendenze Esterne:   <system/standard.asm>
; ==============================================================================
!macro m_Swap32 .addr1_, .addr2_ {
    +m_Swap8 .addr1_+3, .addr2_+3                 ; Scambia prima i byte alti
    +m_Swap8 .addr1_+2, .addr2_+2                 ; poi quelli medio-alti
    +m_Swap8 .addr1_+1, .addr2_+1                 ; poi quelli medio-bassi
    +m_Swap8 .addr1_, .addr2_                     ; ed infine quelli bassi.
}

; ==============================================================================
; MACRO: m_CmpU32
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 32 bit senza segno, secondo
;               l'indirizzamento scelto. Il risultato è nei flag, come con
;               l'istruzione CMP. A 32 bit non sono previsti gruppi di registri:
;               gli operandi sono indirizzi.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo, .op2_ è un valore a 32
;                        bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero.
;
;               Con "IMM", i confronti con 0 e con $FFFFFFFF usano una sequenza
;               più breve.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (4 byte, Macro)   : Primo operando: indirizzo
;   - .op2_ (4 byte, Macro)   : Secondo operando: valore (IMM) o indirizzo
;
; Output:
;   - Flag Zero (1 bit, .P)   : 0 = .op1_ diverso da .op2_; 1 = uguali
;   - Flag Carry (1 bit, .P)  : 0 = .op1_ < .op2_; 1 = .op1_ >= .op2_ (senza
;                               segno)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_CmpU32 .mode_, .op1_, .op2_ {
    !if (.mode_ = "IMM") {
      !if (.op2_ = 0) {                           ; Caso 1: .op1_ è un indirizzo, .op2_ = 0.
        lda .op1_+3
        ora .op1_+2
        ora .op1_+1
        ora .op1_
        sec                                       ; Poni C=1 per imitare il comportamento di CMP: qualunque
                                                  ; numero senza segno è >= 0.
      } else if (.op2_ = $FFFFFFFF) {             ; Caso 2: .op1_ è un indirizzo, .op2_ = $FFFFFFFF
        lda .op1_+3
        and .op1_+2
        and .op1_+1
        and .op1_
        cmp #$FF                                  ; C=1 e Z=1 solo se tutti i byte valgono $FF.
      } else {                                    ; Caso 3: .op1_ è un indirizzo, .op2_ è una costante a 32 bit.
        lda .op1_+3
        cmp #(.op2_ & $FF000000) >> 24
        bne @Result_In_Flags

        lda .op1_+2
        cmp #(.op2_ & $00FF0000) >> 16
        bne @Result_In_Flags

        lda .op1_+1
        cmp #(.op2_ & $0000FF00) >> 8
        bne @Result_In_Flags

        lda .op1_
        cmp #(.op2_ & $000000FF) >> 0

      @Result_In_Flags:
      }
    } else if (.mode_ = "ABS") {
      lda+2 .op1_+3                               ; Caso 1: .op1_ è un indirizzo, .op2_ è un indirizzo.
      cmp+2 .op2_+3
      bne @Result_In_Flags

      lda+2 .op1_+2
      cmp+2 .op2_+2
      bne @Result_In_Flags

      lda+2 .op1_+1
      cmp+2 .op2_+1
      bne @Result_In_Flags

      lda+2 .op1_
      cmp+2 .op2_

    @Result_In_Flags:
    } else if (.mode_ = "ZP" ) {
      lda+1 .op1_+3                               ; Caso 1: .op1_ è un indirizzo, .op2_ è un indirizzo.
      cmp+1 .op2_+3
      bne @Result_In_Flags

      lda+1 .op1_+2
      cmp+1 .op2_+2
      bne @Result_In_Flags

      lda+1 .op1_+1
      cmp+1 .op2_+1
      bne @Result_In_Flags

      lda+1 .op1_
      cmp+1 .op2_

    @Result_In_Flags:
    } else {
      !error "Illegal addressing mode in m_CmpU32: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_CmpS32
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 32 bit con segno, secondo
;               l'indirizzamento scelto. Il flag di Carry si comporta come con
;               l'istruzione CMP (senza segno); con segno vale N xor V = 1 se
;               .op1_ < .op2_. A 32 bit non sono previsti gruppi di registri:
;               gli operandi sono indirizzi.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo, .op2_ è un valore a 32
;                        bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero.
;
;               Con "IMM", il confronto con 0 e con $FFFFFFFF usa una sequenza
;               più breve a parità di flag. Il flag di Zero riflette solo il
;               byte alto del risultato: per verificare l'uguaglianza si usa
;               m_CmpU32.
;
;               Con "IMM", .op2_ deve essere definito prima dell'invocazione,
;               perché la macro lo confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (4 byte, Macro)     : Primo operando: indirizzo
;   - .op2_ (4 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
;
; Output:
;   - Flag Negative (1 bit, .P) : 0 = bit 7 a 0; 1 = bit 7 a 1
;   - Flag oVerflow (1 bit, .P) : 0 = nessun overflow con segno; 1 = overflow
;                                 con segno
;   - Flag Zero (1 bit, .P)     : 0 = byte alto diverso da 0; 1 = uguale a 0
;   - Flag Carry (1 bit, .P)    : 0 = .op1_ < .op2_; 1 = .op1_ >= .op2_ (senza
;                                 segno)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_CmpS32 .mode_, .op1_, .op2_ {
    !if (.mode_ = "IMM") {
      !if (.op2_ = 0) {                           ; Caso 1: .op1_ è un indirizzo, .op2_ = 0.
        lda .op1_+3
        clv                                       ; Stessi flag N, Z, C e V del caso generale: C=1 e V=0.
        sec
      } else if (.op2_ = $FFFFFFFF) {             ; Caso 2: .op1_ è un indirizzo, .op2_ = $FFFFFFFF
        lda .op1_+2
        and .op1_+1
        and .op1_
        cmp #$FF                                  ; C=1 solo se i tre byte bassi valgono $FF.

        lda .op1_+3
        sbc #$FF                                  ; Stessi flag N, Z, C e V del caso generale.
      } else {                                    ; Caso 3: .op1_ è un indirizzo, .op2_ è una costante a 32 bit.
        lda .op1_
        cmp #(.op2_ & $000000FF) >> 0

        lda .op1_+1
        sbc #(.op2_ & $0000FF00) >> 8             ; Il flag di Carry è già impostato dall'istruzione
                                                  ; CMP precedente.

        lda .op1_+2
        sbc #(.op2_ & $00FF0000) >> 16

        lda .op1_+3
        sbc #(.op2_ & $FF000000) >> 24
      }
    } else if (.mode_ = "ABS") {
      lda+2 .op1_
      cmp+2 .op2_

      lda+2 .op1_+1
      sbc+2 .op2_+1                               ; Il flag di Carry è già impostato dall'istruzione
                                                  ; CMP precedente.

      lda+2 .op1_+2
      sbc+2 .op2_+2

      lda+2 .op1_+3
      sbc+2 .op2_+3
    } else if (.mode_ = "ZP" ) {
      lda+1 .op1_
      cmp+1 .op2_

      lda+1 .op1_+1
      sbc+1 .op2_+1                               ; Il flag di Carry è già impostato dall'istruzione
                                                  ; CMP precedente.

      lda+1 .op1_+2
      sbc+1 .op2_+2

      lda+1 .op1_+3
      sbc+1 .op2_+3
    } else {
      !error "Illegal addressing mode in m_CmpS32: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Inc32
; ------------------------------------------------------------------------------
; Descrizione:  Incrementa di 1 un contatore a 32 bit contenuto in un puntatore.
;               Non viene alterato nessun registro.
;
;               Il flag Negative in uscita è indefinito.
;
; Input:
;   - .addr_ (4 byte, Macro) : Contatore: indirizzo
;
; Output:
;   - .addr_ (4 byte, Macro) : Contatore incrementato (da $FFFFFFFF a $00000000)
;   - Flag Zero (1 bit, .P)  : 0 = risultato diverso da 0; 1 = risultato 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .P (Negative, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Inc32 .addr_ {
    inc .addr_
    bne @No_Carry

    inc .addr_+1
    bne @No_Carry

    inc .addr_+2
    bne @No_Carry

    inc .addr_+3

  @No_Carry:
}

; ==============================================================================
; MACRO: m_Dec32
; ------------------------------------------------------------------------------
; Descrizione:  Decrementa di 1 un contatore a 32 bit contenuto in un puntatore.
;               Viene alterato .A.
;
;               Il flag Negative in uscita è indefinito.
;
; Input:
;   - .addr_ (4 byte, Macro) : Contatore: indirizzo
;
; Output:
;   - .addr_ (4 byte, Macro) : Contatore decrementato (da $00000000 a $FFFFFFFF)
;   - Flag Zero (1 bit, .P)  : 0 = byte basso diverso da 0; 1 = byte basso 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Dec32 .addr_ {
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

; ==============================================================================
; FILE:           mem24.asm
; PROGETTO:       Libreria di Sistema (mem.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per la manipolazione di valori a 24 bit.
; CONTENUTO:      m_Mov24   Sposta un valore o un puntatore a 24 bit
;                 m_Swap24  Scambia due puntatori a 24 bit
;                 m_CmpU24  Confronta due valori a 24 bit senza segno
;                 m_CmpS24  Confronta due valori a 24 bit con segno
;                 m_Inc24   Incrementa un contatore a 24 bit
;                 m_Dec24   Decrementa un contatore a 24 bit
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Mov24
; ------------------------------------------------------------------------------
; Descrizione:  Copia un valore costante o un puntatore a 24 bit dalla sorgente
;               alla destinazione, secondo l'indirizzamento scelto.
;
;                 "IMM"  Immediato: .src_ è un valore a 24 bit e .dest_ è un
;                        indirizzo o una terna di registri.
;                 "ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti; uno
;                        dei due può essere una terna di registri.
;                 "ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
;                        zero; uno dei due può essere una terna di registri.
;
;               Le terne di registri si scrivono ".<hi><mid><lo>" (byte alto,
;               intermedio e basso): .AXY e .YXA.
;
;               Con "IMM" una costante con i tre byte uguali (per esempio 0,
;               $FFFFFF o $424242) usa una sequenza più breve. Con "ABS" e "ZP",
;               da indirizzo a indirizzo, la copia procede nel verso che non
;               altera il sorgente se le due aree si sovrappongono.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .src_ (3 byte, Macro)   : Valore (IMM), indirizzo o terna di registri
;   - .dest_ (3 byte, Macro)  : Indirizzo o terna di registri
;
; Output:
;   - .dest_ (3 byte, Macro)  : Riceve il valore di .src_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Mov24 .mode_, .src_, .dest_ {
    !if (.mode_ = "IMM") {
      !if (.src_ = ((.src_ & $FF) * $010101)) { ; Caso 1: i tre byte di .src_ sono uguali, .dest_ è una terna
                                                ; di registri.
        !if (.dest_ = ".AXY") {
          lda #<.src_
          tax
          tay
        } else if (.dest_ = ".YXA") {
          lda #<.src_
          tax
          tay
        } else {                                ; Caso 2: i tre byte di .src_ sono uguali, .dest_ è
                                                ; un indirizzo.
          lda #<.src_
          sta .dest_+2
          sta .dest_+1
          sta .dest_
        }
      } else {
        !if (.dest_ = ".AXY") {                 ; Caso 3: .src_ è una costante a 24 bit, .dest_ è una terna
                                                ; di registri.
          lda #(.src_ & $FF0000) >> 16
          ldx #(.src_ & $00FF00) >> 8
          ldy #(.src_ & $0000FF) >> 0
        } else if (.dest_ = ".YXA") {
          ldy #(.src_ & $FF0000) >> 16
          ldx #(.src_ & $00FF00) >> 8
          lda #(.src_ & $0000FF) >> 0
        } else {                                ; Caso 4: .src_ è una costante a 24 bit, .dest_ è
                                                ; un indirizzo.
          lda #(.src_ & $FF0000) >> 16
          sta .dest_+2
          lda #(.src_ & $00FF00) >> 8
          sta .dest_+1
          lda #(.src_ & $0000FF) >> 0
          sta .dest_
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.dest_ = ".AXY") {                   ; Caso 1: .src_ è un indirizzo, .dest_ è una terna
                                                ; di registri.
        lda+2 .src_+2
        ldx+2 .src_+1
        ldy+2 .src_
      } else if (.dest_ = ".YXA") {
        ldy+2 .src_+2
        ldx+2 .src_+1
        lda+2 .src_
      } else if (.src_ = ".AXY") {              ; Caso 2: .src_ è una terna di registri, .dest_ è
                                                ; un indirizzo.
        sta+2 .dest_+2
        stx+2 .dest_+1
        sty+2 .dest_
      } else if (.src_ = ".YXA") {
        sty+2 .dest_+2
        stx+2 .dest_+1
        sta+2 .dest_
      } else if (.src_ > .dest_) {              ; Caso 3: .src_ si trova più avanti rispetto a .dest_.
        lda+2 .src_                             ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_                            ; più piccolo al più grande.

        lda+2 .src_+1
        sta+2 .dest_+1

        lda+2 .src_+2
        sta+2 .dest_+2
      } else if (.src_ < .dest_) {              ; Caso 4: .src_ si trova più indietro rispetto a .dest_.
        lda+2 .src_+2                           ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_+2                          ; più grande al più piccolo.

        lda+2 .src_+1
        sta+2 .dest_+1

        lda+2 .src_
        sta+2 .dest_
      } else if (.src_ = .dest_) {              ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
      }
    } else if (.mode_ = "ZP" ) {
      !if (.dest_ = ".AXY") {                   ; Caso 1: .src_ è un indirizzo, .dest_ è una terna
                                                ; di registri.
        lda+1 .src_+2
        ldx+1 .src_+1
        ldy+1 .src_
      } else if (.dest_ = ".YXA") {
        ldy+1 .src_+2
        ldx+1 .src_+1
        lda+1 .src_
      } else if (.src_ = ".AXY") {              ; Caso 2: .src_ è una terna di registri, .dest_ è
                                                ; un indirizzo.
        sta+1 .dest_+2
        stx+1 .dest_+1
        sty+1 .dest_
      } else if (.src_ = ".YXA") {
        sty+1 .dest_+2
        stx+1 .dest_+1
        sta+1 .dest_
      } else if (.src_ > .dest_) {              ; Caso 3: .src_ si trova più avanti rispetto a .dest_.
        lda+1 .src_                             ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_                            ; più piccolo al più grande.

        lda+1 .src_+1
        sta+1 .dest_+1

        lda+1 .src_+2
        sta+1 .dest_+2
      } else if (.src_ < .dest_) {              ; Caso 4: .src_ si trova più indietro rispetto a .dest_.
        lda+1 .src_+2                           ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_+2                          ; più grande al più piccolo.

        lda+1 .src_+1
        sta+1 .dest_+1

        lda+1 .src_
        sta+1 .dest_
      } else if (.src_ = .dest_) {              ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
      }
    } else {
      !error "Illegal addressing mode in m_Mov24: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Swap24
; ------------------------------------------------------------------------------
; Descrizione:  Scambia il valore di due puntatori a 24 bit usando i registri.
;
; Input:
;   - .addr1_ (3 byte, Macro) : Indirizzo del primo valore
;   - .addr2_ (3 byte, Macro) : Indirizzo del secondo valore
;
; Output:
;   - .addr1_ (3 byte, Macro) : Riceve il valore di .addr2_
;   - .addr2_ (3 byte, Macro) : Riceve il valore di .addr1_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .X, .Y, .P
; Dipendenze Esterne:   <system/standard.asm>
; ==============================================================================
!macro m_Swap24 .addr1_, .addr2_ {
    +m_Swap8 .addr1_+2, .addr2_+2               ; Scambia prima i byte alti
    +m_Swap8 .addr1_+1, .addr2_+1               ; poi quelli medi
    +m_Swap8 .addr1_, .addr2_                   ; ed infine quelli bassi.
}

; ==============================================================================
; MACRO: m_CmpU24
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 24 bit senza segno, secondo
;               l'indirizzamento scelto. Il risultato è nei flag, come con
;               l'istruzione CMP.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo o una terna di
;                        registri, .op2_ è un valore a 24 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
;                        può essere una terna di registri.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero; .op1_ può essere una terna di registri.
;
;               Le terne di registri si scrivono ".<hi><mid><lo>" (byte alto,
;               intermedio e basso): .AXY e .YXA. Con una terna di registri come
;               .op1_ nessun registro viene alterato.
;
;               Con "IMM" e .op1_ indirizzo, i confronti con 0 e con $FFFFFF
;               usano una sequenza più breve.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (3 byte, Macro)   : Primo operando: indirizzo o terna di registri
;   - .op2_ (3 byte, Macro)   : Secondo operando: valore (IMM) o indirizzo
;
; Output:
;   - Flag Carry (1 bit, .P)  : 0 = .op1_ < .op2_; 1 = .op1_ >= .op2_ (senza
;                               segno)
;   - Flag Zero (1 bit, .P)   : 0 = .op1_ diverso da .op2_; 1 = uguali
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Carry, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_CmpU24 .mode_, .op1_, .op2_ {

    ; Non esistono casi a parte per il confronto di una terna di
    ; registri con 0 e con $FFFFFF: la soluzione generale è già la
    ; più efficiente in cicli e in memoria.

    !if (.mode_ = "IMM") {
      !if (.op1_ = ".AXY") {                    ; Caso 1: .op1_ è una terna di registri, .op2_ è una costante
                                                ; a 24 bit.
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
      } else if (.op2_ = 0) {                   ; Caso 2: .op1_ è un indirizzo, .op2_ = 0.
        lda .op1_+2
        ora .op1_+1
        ora .op1_
        sec                                     ; Poni C=1 per imitare il comportamento di CMP: qualunque
                                                ; numero senza segno è >= 0.
      } else if (.op2_ = $FFFFFF) {             ; Caso 3: .op1_ è un indirizzo, .op2_ = $FFFFFF
        lda .op1_+2
        and .op1_+1
        and .op1_
        cmp #$FF                                ; C=1 e Z=1 solo se tutti i byte valgono $FF.
      } else {                                  ; Caso 4: .op1_ è un indirizzo, .op2_ è una costante a 24 bit.
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
      !if (.op1_ = ".AXY") {                    ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo.
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
      } else {                                  ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
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
      !if (.op1_ = ".AXY") {                    ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo.
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
      } else {                                  ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
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
    } else {
      !error "Illegal addressing mode in m_CmpU24: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_CmpS24
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 24 bit con segno, secondo
;               l'indirizzamento scelto. Il flag di Carry si comporta come con
;               l'istruzione CMP (senza segno); con segno vale N xor V = 1 se
;               .op1_ < .op2_.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo o una terna di
;                        registri, .op2_ è un valore a 24 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
;                        può essere una terna di registri.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero; .op1_ può essere una terna di registri.
;
;               Le terne di registri si scrivono ".<hi><mid><lo>" (byte alto,
;               intermedio e basso): .AXY e .YXA. Con .AXY come .op1_ la macro
;               usa temporaneamente un byte dello stack e lo rilascia prima di
;               terminare.
;
;               Con "IMM" il confronto con 0 (indirizzo o terna di registri) e
;               con $FFFFFF (indirizzo o .AXY) usa una sequenza più breve a
;               parità di flag. Il flag di Zero riflette solo il byte alto del
;               risultato: per verificare l'uguaglianza si usa m_CmpU24.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (3 byte, Macro)     : Primo operando: indirizzo o terna di registri
;   - .op2_ (3 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
;
; Output:
;   - Flag Carry (1 bit, .P)    : 0 = .op1_ < .op2_; 1 = .op1_ >= .op2_ (senza
;                                 segno)
;   - Flag Negative (1 bit, .P) : 0 = bit 7 a 0; 1 = bit 7 a 1
;   - Flag oVerflow (1 bit, .P) : 0 = nessun overflow con segno; 1 = overflow
;                                 con segno
;   - Flag Zero (1 bit, .P)     : 0 = byte alto diverso da 0; 1 = uguale a 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Carry, Negative, oVerflow, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_CmpS24 .mode_, .op1_, .op2_ {

    ; Non esistono casi a parte per il confronto con $FFFFFF della
    ; terna .YXA: la soluzione generale è già la più efficiente in
    ; cicli e in memoria.

    !if (.mode_ = "IMM") {
      !if (.op2_ = 0) {
        !if (.op1_ = ".AXY") {                  ; Caso 1: .op2_ = 0, .op1_ è una terna di registri.
          cmp #0
          clv                                   ; Stessi flag N, Z, C e V del caso generale: C=1 e V=0.
        } else if (.op1_ = ".YXA") {
          cpy #0
          clv
        } else {                                ; Caso 2: .op2_ = 0, .op1_ è un indirizzo.
          lda .op1_+2
          clv
          sec
        }
      } else {
        !if (.op1_ = ".AXY") {
          !if (.op2_ = $FFFFFF) {               ; Caso 3: .op1_ è una terna di registri, .op2_ = $FFFFFF.
            cpy #$FF
            bne +

            cpx #$FF
            +
            sbc #$FF                            ; Stessi flag N, Z, C e V del caso generale.
          } else {                              ; Caso 4: .op1_ è una terna di registri, .op2_ è una costante
                                                ; a 24 bit.
            pha
            cpy #(.op2_ & $0000FF) >> 0
            txa
            sbc #(.op2_ & $00FF00) >> 8
            pla
            sbc #(.op2_ & $FF0000) >> 16
          }
        } else if (.op1_ = ".YXA") {            ; Caso 5: .op1_ è una terna di registri, .op2_ è una costante
                                                ; a 24 bit.
          cmp #(.op2_ & $0000FF) >> 0
          txa
          sbc #(.op2_ & $00FF00) >> 8
          tya
          sbc #(.op2_ & $FF0000) >> 16
        } else if (.op2_ = $FFFFFF) {           ; Caso 6: .op1_ è un indirizzo, .op2_ = $FFFFFF
          lda .op1_+1
          and .op1_
          cmp #$FF                              ; C=1 solo se i due byte bassi valgono $FF.

          lda .op1_+2
          sbc #$FF                              ; Stessi flag N, Z, C e V del caso generale.
        } else {                                ; Caso 7: .op1_ è un indirizzo, .op2_ è una costante a 24 bit.
          lda .op1_
          cmp #(.op2_ & $0000FF) >> 0

          lda .op1_+1
          sbc #(.op2_ & $00FF00) >> 8           ; Il flag di Carry è già impostato dall'istruzione
                                                ; CMP precedente.

          lda .op1_+2
          sbc #(.op2_ & $FF0000) >> 16
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ = ".AXY") {                    ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo.
        pha
        cpy+2 .op2_
        txa
        sbc+2 .op2_+1
        pla
        sbc+2 .op2_+2
      } else if (.op1_ = ".YXA") {
        cmp+2 .op2_
        txa
        sbc+2 .op2_+1
        tya
        sbc+2 .op2_+2
      } else {                                  ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+2 .op1_
        cmp+2 .op2_

        lda+2 .op1_+1
        sbc+2 .op2_+1                           ; Il flag di Carry è già impostato dall'istruzione
                                                ; CMP precedente.

        lda+2 .op1_+2
        sbc+2 .op2_+2
      }
    } else if (.mode_ = "ZP" ) {
      !if (.op1_ = ".AXY") {                    ; Caso 1: .op1_ è una terna di registri, .op2_ è un indirizzo.
        pha
        cpy+1 .op2_
        txa
        sbc+1 .op2_+1
        pla
        sbc+1 .op2_+2
      } else if (.op1_ = ".YXA") {
        cmp+1 .op2_
        txa
        sbc+1 .op2_+1
        tya
        sbc+1 .op2_+2
      } else {                                  ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+1 .op1_
        cmp+1 .op2_

        lda+1 .op1_+1
        sbc+1 .op2_+1                           ; Il flag di Carry è già impostato dall'istruzione
                                                ; CMP precedente.

        lda+1 .op1_+2
        sbc+1 .op2_+2
      }
    } else {
      !error "Illegal addressing mode in m_CmpS24: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Inc24
; ------------------------------------------------------------------------------
; Descrizione:  Incrementa di 1 un contatore a 24 bit contenuto in un puntatore
;               o in una terna di registri.
;
;               Le terne di registri si scrivono ".<hi><mid><lo>" (byte alto,
;               intermedio e basso): .AXY e .YXA. Con un indirizzo non viene
;               alterato nessun registro.
;
;               I flag Carry, Negative e oVerflow in uscita sono indefiniti.
;
;               L'operando deve essere definito prima dell'invocazione, perché
;               la macro lo confronta per scegliere il ramo.
;
; Input:
;   - .addr_ (3 byte, Macro) : Contatore: indirizzo o terna di registri
;
; Output:
;   - .addr_ (3 byte, Macro) : Contatore incrementato (da $FFFFFF a $000000)
;   - Flag Zero (1 bit, .P)  : 0 = risultato diverso da 0; 1 = risultato 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Carry, Negative, oVerflow, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Inc24 .addr_ {
    !if (.addr_ = ".AXY") {                     ; Caso 1: .addr_ è una terna di registri.
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
    } else {                                    ; Caso 2: .addr_ è un indirizzo.
      inc .addr_
      bne +

      inc .addr_+1
      bne +

      inc .addr_+2
      +
    }
}

; ==============================================================================
; MACRO: m_Dec24
; ------------------------------------------------------------------------------
; Descrizione:  Decrementa di 1 un contatore a 24 bit contenuto in un puntatore
;               o in una terna di registri.
;
;               Le terne di registri si scrivono ".<hi><mid><lo>" (byte alto,
;               intermedio e basso): .AXY e .YXA. Con un indirizzo viene
;               alterato .A; con una terna di registri solo i tre registri della
;               terna.
;
;               I flag Carry, Negative e oVerflow in uscita sono indefiniti.
;
;               L'operando deve essere definito prima dell'invocazione, perché
;               la macro lo confronta per scegliere il ramo.
;
; Input:
;   - .addr_ (3 byte, Macro) : Contatore: indirizzo o terna di registri
;
; Output:
;   - .addr_ (3 byte, Macro) : Contatore decrementato (da $000000 a $FFFFFF)
;   - Flag Zero (1 bit, .P)  : 0 = byte basso diverso da 0; 1 = byte basso 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Carry, Negative, oVerflow, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Dec24 .addr_ {
    !if (.addr_ = ".AXY") {                     ; Caso 1: .addr_ è una terna di registri.
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
    } else {                                    ; Caso 2: .addr_ è un indirizzo.
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

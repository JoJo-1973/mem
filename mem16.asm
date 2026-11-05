; ==============================================================================
; FILE:           mem16.asm
; PROGETTO:       Libreria di Sistema (mem.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per la manipolazione di valori a 16 bit.
; CONTENUTO:      m_Mov16   Sposta un valore o un puntatore a 16 bit
;                 m_Swap16  Scambia due puntatori a 16 bit
;                 m_CmpU16  Confronta due valori a 16 bit senza segno
;                 m_CmpS16  Confronta due valori a 16 bit con segno
;                 m_Inc16   Incrementa un contatore a 16 bit
;                 m_Dec16   Decrementa un contatore a 16 bit
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Mov16
; ------------------------------------------------------------------------------
; Descrizione:  Copia un valore costante o un puntatore a 16 bit dalla sorgente
;               alla destinazione, secondo l'indirizzamento scelto.
;
;                 "IMM"  Immediato: .src_ è un valore a 16 bit e .dest_ è un
;                        indirizzo o una coppia di registri.
;                 "ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti; uno
;                        dei due può essere una coppia di registri.
;                 "ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
;                        zero; uno dei due può essere una coppia di registri.
;
;               Le coppie di registri si scrivono ".<hi><lo>" (byte alto e byte
;               basso): .AX, .AY, .XY, .XA, .YA e .YX.
;
;               Con "IMM" una costante con i due byte uguali (per esempio 0,
;               $FFFF o $4242) usa una sequenza più breve. Con "ABS" e "ZP", da
;               indirizzo a indirizzo, la copia procede nel verso che non altera
;               il sorgente se le due aree si sovrappongono.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .src_ (2 byte, Macro)   : Valore (IMM), indirizzo o coppia di registri
;   - .dest_ (2 byte, Macro)  : Indirizzo o coppia di registri
;
; Output:
;   - .dest_ (2 byte, Macro)  : Riceve il valore di .src_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Mov16 .mode_, .src_, .dest_ {
    !if (.mode_ = "IMM") {
      !if (.src_ = ((.src_ & $FF) * $0101)) { ; Caso 1: i due byte di .src_ sono uguali, .dest_ è una coppia
                                              ; di registri.
        !if (.dest_ = ".AX") {
          lda #<.src_
          tax
        } else if (.dest_ = ".AY") {
          lda #<.src_
          tay
        } else if (.dest_ = ".XY") {
          ldx #<.src_
          ldy #<.src_
        } else if (.dest_ = ".XA") {
          ldx #<.src_
          txa
        } else if (.dest_ = ".YA") {
          ldy #<.src_
          tya
        } else if (.dest_ = ".YX") {
          ldy #<.src_
          ldx #<.src_
        } else {                              ; Caso 2: i due byte di .src_ sono uguali, .dest_ è
                                              ; un indirizzo.
          lda #<.src_
          sta .dest_+1
          sta .dest_
        }
      } else {
        !if (.dest_ = ".AX") {                ; Caso 3: .src_ è una costante a 16 bit, .dest_ è una coppia
                                              ; di registri.
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
        } else {                              ; Caso 4: .src_ è una costante a 16 bit, .dest_ è
                                              ; un indirizzo.
          lda #>.src_
          sta .dest_+1
          lda #<.src_
          sta .dest_
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.dest_ = ".AX") {                  ; Caso 1: .src_ è un indirizzo, .dest_ è una coppia
                                              ; di registri.
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
      } else if (.src_ = ".AX") {             ; Caso 2: .src_ è una coppia di registri, .dest_ è
                                              ; un indirizzo.
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
      } else if (.src_ > .dest_) {            ; Caso 3: .src_ si trova più avanti rispetto a .dest_.
        lda+2 .src_                           ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_                          ; più piccolo al più grande.

        lda+2 .src_+1
        sta+2 .dest_+1
      } else if (.src_ < .dest_) {            ; Caso 4: .src_ si trova più indietro rispetto a .dest_.
        lda+2 .src_+1                         ; Per evitare sovrascritture si procede dall'indirizzo
        sta+2 .dest_+1                        ; più grande al più piccolo.

        lda+2 .src_
        sta+2 .dest_
      } else if (.src_ = .dest_) {            ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
      }
    } else if (.mode_ = "ZP") {
      !if (.dest_ = ".AX") {                  ; Caso 1: .src_ è un indirizzo, .dest_ è una coppia
                                              ; di registri.
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
      } else if (.src_ = ".AX") {             ; Caso 2: .src_ è una coppia di registri, .dest_ è
                                              ; un indirizzo.
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
      } else if (.src_ > .dest_) {            ; Caso 3: .src_ si trova più avanti rispetto a .dest_.
        lda+1 .src_                           ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_                          ; più piccolo al più grande.

        lda+1 .src_+1
        sta+1 .dest_+1
      } else if (.src_ < .dest_) {            ; Caso 4: .src_ si trova più indietro rispetto a .dest_.
        lda+1 .src_+1                         ; Per evitare sovrascritture si procede dall'indirizzo
        sta+1 .dest_+1                        ; più grande al più piccolo.

        lda+1 .src_
        sta+1 .dest_
      } else if (.src_ = .dest_) {            ; Caso 5: .src_ e .dest_ coincidono: non fare niente!
      }
    } else {
      !error "Illegal addressing mode in m_Mov16: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Swap16
; ------------------------------------------------------------------------------
; Descrizione:  Scambia il valore di due puntatori a 16 bit usando i registri.
;
; Input:
;   - .addr1_ (2 byte, Macro) : Indirizzo del primo valore
;   - .addr2_ (2 byte, Macro) : Indirizzo del secondo valore
;
; Output:
;   - .addr1_ (2 byte, Macro) : Riceve il valore di .addr2_
;   - .addr2_ (2 byte, Macro) : Riceve il valore di .addr1_
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .X, .Y, .P
; Dipendenze Esterne:   <system/standard.asm>
; ==============================================================================
!macro m_Swap16 .addr1_, .addr2_ {
    +m_Swap8 .addr1_+1, .addr2_+1             ; Scambia prima i byte alti
    +m_Swap8 .addr1_, .addr2_                 ; e poi quelli bassi.
}

; ==============================================================================
; MACRO: m_CmpU16
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 16 bit senza segno, secondo
;               l'indirizzamento scelto. Il risultato è nei flag, come con
;               l'istruzione CMP.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo o una coppia di
;                        registri, .op2_ è un valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
;                        può essere una coppia di registri.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero; .op1_ può essere una coppia di registri.
;
;               Le coppie di registri si scrivono ".<hi><lo>" (byte alto e byte
;               basso): .AX, .AY, .XY, .XA, .YA e .YX. Con una coppia di
;               registri come .op1_ nessun registro viene alterato.
;
;               Con "IMM" e .op1_ indirizzo, i confronti con 0 e con $FFFF usano
;               una sequenza più breve.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro) : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (2 byte, Macro)   : Primo operando: indirizzo o coppia di registri
;   - .op2_ (2 byte, Macro)   : Secondo operando: valore (IMM) o indirizzo
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
!macro m_CmpU16 .mode_, .op1_, .op2_ {

    ; Non esistono casi a parte per il confronto di una coppia di
    ; registri con 0 e con $FFFF: la soluzione generale è già la
    ; più efficiente in cicli e in memoria.

    !if (.mode_ = "IMM") {
      !if (.op1_ = ".AX") {
        cmp #>.op2_                           ; Caso 1: .op1_ è una coppia di registri, .op2_ è una costante
                                              ; a 16 bit.
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
      } else if (.op2_ = 0) {                 ; Caso 2: .op1_ è un indirizzo, .op2_ = 0.
        lda .op1_+1
        ora .op1_
        sec                                   ; Poni C=1 per imitare il comportamento di CMP: qualunque
                                              ; numero senza segno è >= 0.
      } else if (.op2_ = $FFFF) {             ; Caso 3: .op1_ è un indirizzo, .op2_ = $FFFF
        lda .op1_+1
        and .op1_
        cmp #$FF                              ; C=1 e Z=1 solo se tutti i byte valgono $FF.
      } else {
        lda .op1_+1                           ; Caso 4: .op1_ è un indirizzo, .op2_ è una costante a 16 bit.
        cmp #>.op2_
        bne +

        lda .op1_
        cmp #<.op2_
        +
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ = ".AX") {                   ; Caso 1: .op1_ è una coppia di registri, .op2_ è
                                              ; un indirizzo.
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
      } else {                                ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+2 .op1_+1
        cmp+2 .op2_+1
        bne +

        lda+2 .op1_
        cmp+2 .op2_
        +
      }
    } else if (.mode_ = "ZP") {
      !if (.op1_ = ".AX") {                   ; Caso 1: .op1_ è una coppia di registri, .op2_ è
                                              ; un indirizzo.
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
      } else {                                ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+1 .op1_+1
        cmp+1 .op2_+1
        bne +

        lda+1 .op1_
        cmp+1 .op2_
        +
      }
    } else {
      !error "Illegal addressing mode in m_CmpU16: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_CmpS16
; ------------------------------------------------------------------------------
; Descrizione:  Confronta due valori a 16 bit con segno, secondo
;               l'indirizzamento scelto. Il flag di Carry si comporta come con
;               l'istruzione CMP (senza segno); con segno vale N xor V = 1 se
;               .op1_ < .op2_.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo o una coppia di
;                        registri, .op2_ è un valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
;                        può essere una coppia di registri.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
;                        zero; .op1_ può essere una coppia di registri.
;
;               Le coppie di registri si scrivono ".<hi><lo>" (byte alto e byte
;               basso): .AX, .AY, .XY, .XA, .YA e .YX.
;
;               Con "IMM" e .op1_ indirizzo o coppia di registri, il confronto
;               con 0 usa una sequenza più breve a parità di flag. Il flag di
;               Zero riflette solo il byte alto del risultato: per verificare
;               l'uguaglianza si usa m_CmpU16.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (2 byte, Macro)     : Primo operando: indirizzo o coppia di registri
;   - .op2_ (2 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
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
!macro m_CmpS16 .mode_, .op1_, .op2_ {

    ; Non esistono casi a parte per il confronto con $FFFF di una
    ; coppia di registri o di un indirizzo: la soluzione generale
    ; è già la più efficiente in cicli e in memoria.

    !if (.mode_ = "IMM") {
      !if (.op2_ = 0) {
        !if (.op1_ = ".AX") {                 ; Caso 1: .op2_ = 0, .op1_ è una coppia di registri.
          cmp #0
          clv                                 ; Stessi flag N, Z, C e V del caso generale: C=1 e V=0.
        } else if (.op1_ = ".AY") {
          cmp #0
          clv
        } else if (.op1_ = ".XY") {
          cpx #0
          clv
        } else if (.op1_ = ".XA") {
          cpx #0
          clv
        } else if (.op1_ = ".YA") {
          cpy #0
          clv
        } else if (.op1_ = ".YX") {
          cpy #0
          clv
        } else {                              ; Caso 2: .op2_ = 0, .op1_ è un indirizzo.
          lda .op1_+1
          clv
          sec
        }
      } else {
        !if (.op1_ = ".AX") {                 ; Caso 3: .op1_ è una coppia di registri, .op2_ è una costante
                                              ; a 16 bit.
          cpx #<.op2_
          sbc #>.op2_                         ; Il flag di Carry è già impostato dall'istruzione di
                                              ; confronto precedente.
        } else if (.op1_ = ".AY") {
          cpy #<.op2_
          sbc #>.op2_
        } else if (.op1_ = ".XY") {
          cpy #<.op2_
          txa
          sbc #>.op2_
        } else if (.op1_ = ".XA") {
          cmp #<.op2_
          txa
          sbc #>.op2_
        } else if (.op1_ = ".YA") {
          cmp #<.op2_
          tya
          sbc #>.op2_
        } else if (.op1_ = ".YX") {
          cpx #<.op2_
          tya
          sbc #>.op2_
        } else {                              ; Caso 4: .op1_ è un indirizzo, .op2_ è una costante a 16 bit.
          lda .op1_
          cmp #<.op2_

          lda .op1_+1
          sbc #>.op2_                         ; Il flag di Carry è già impostato dall'istruzione
                                              ; CMP precedente.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ = ".AX") {                   ; Caso 1: .op1_ è una coppia di registri, .op2_ è
                                              ; un indirizzo.
        cpx+2 .op2_
        sbc+2 .op2_+1
      } else if (.op1_ = ".AY") {
        cpy+2 .op2_
        sbc+2 .op2_+1
      } else if (.op1_ = ".XY") {
        cpy+2 .op2_
        txa
        sbc+2 .op2_+1
      } else if (.op1_ = ".XA") {
        cmp+2 .op2_
        txa
        sbc+2 .op2_+1
      } else if (.op1_ = ".YA") {
        cmp+2 .op2_
        tya
        sbc+2 .op2_+1
      } else if (.op1_ = ".YX") {
        cpx+2 .op2_
        tya
        sbc+2 .op2_+1
      } else {                                ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+2 .op1_
        cmp+2 .op2_

        lda+2 .op1_+1
        sbc+2 .op2_+1                         ; Il flag di Carry è già impostato dall'istruzione
                                              ; CMP precedente.
      }
    } else if (.mode_ = "ZP") {
      !if (.op1_ = ".AX") {                   ; Caso 1: .op1_ è una coppia di registri, .op2_ è
                                              ; un indirizzo.
        cpx+1 .op2_
        sbc+1 .op2_+1
      } else if (.op1_ = ".AY") {
        cpy+1 .op2_
        sbc+1 .op2_+1
      } else if (.op1_ = ".XY") {
        cpy+1 .op2_
        txa
        sbc+1 .op2_+1
      } else if (.op1_ = ".XA") {
        cmp+1 .op2_
        txa
        sbc+1 .op2_+1
      } else if (.op1_ = ".YA") {
        cmp+1 .op2_
        tya
        sbc+1 .op2_+1
      } else if (.op1_ = ".YX") {
        cpx+1 .op2_
        tya
        sbc+1 .op2_+1
      } else {                                ; Caso 2: .op1_ è un indirizzo, .op2_ è un indirizzo.
        lda+1 .op1_
        cmp+1 .op2_

        lda+1 .op1_+1
        sbc+1 .op2_+1                         ; Il flag di Carry è già impostato dall'istruzione
                                              ; CMP precedente.
      }
    } else {
      !error "Illegal addressing mode in m_CmpS16: ", .mode_
    }
}

; ==============================================================================
; MACRO: m_Inc16
; ------------------------------------------------------------------------------
; Descrizione:  Incrementa di 1 un contatore a 16 bit contenuto in un puntatore
;               o in una coppia di registri.
;
;               Le coppie di registri si scrivono ".<hi><lo>" (byte alto e byte
;               basso): .AX, .AY, .XY, .XA, .YA e .YX.
;
;               Con un indirizzo non viene alterato nessun registro.
;
;               I flag Carry, Negative e oVerflow in uscita sono indefiniti.
;
;               L'operando deve essere definito prima dell'invocazione, perché
;               la macro lo confronta per scegliere il ramo.
;
; Input:
;   - .addr_ (2 byte, Macro)  : Contatore: indirizzo o coppia di registri
;
; Output:
;   - .addr_ (2 byte, Macro)  : Contatore incrementato (da $FFFF a $0000)
;   - Flag Zero (1 bit, .P)   : 0 = risultato diverso da 0; 1 = risultato 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Carry, Negative, oVerflow, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Inc16 .addr_ {
    !if (.addr_ = ".AX") {                    ; Caso 1: .addr_ è una coppia di registri.
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
    } else {                                  ; Caso 2: .addr_ è un indirizzo.
      inc .addr_
      bne +

      inc .addr_+1
      +
    }
}

; ==============================================================================
; MACRO: m_Dec16
; ------------------------------------------------------------------------------
; Descrizione:  Decrementa di 1 un contatore a 16 bit contenuto in un puntatore
;               o in una coppia di registri.
;
;               Le coppie di registri si scrivono ".<hi><lo>" (byte alto e byte
;               basso): .AX, .AY, .XY, .XA, .YA e .YX.
;
;               Con un indirizzo viene alterato .A; con una coppia di
;               registri solo i due registri della coppia.
;
;               I flag Carry, Negative e oVerflow in uscita sono indefiniti.
;
;               L'operando deve essere definito prima dell'invocazione, perché
;               la macro lo confronta per scegliere il ramo.
;
; Input:
;   - .addr_ (2 byte, Macro)  : Contatore: indirizzo o coppia di registri
;
; Output:
;   - .addr_ (2 byte, Macro)  : Contatore decrementato (da $0000 a $FFFF)
;   - Flag Zero (1 bit, .P)   : 0 = byte basso diverso da 0; 1 = byte basso 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Carry, Negative, oVerflow, Zero)
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Dec16 .addr_ {
    !if (.addr_ = ".AX") {                    ; Caso 1: .addr_ è una coppia di registri.
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
    } else {                                  ; Caso 2: .addr_ è un indirizzo.
      lda .addr_
      bne +

      dec .addr_+1
      + dec .addr_
    }
}

# mem

Macro per la manipolazione di quantità a 16, 24 e 32 bit in memoria e nei registri: spostamento, scambio, confronto con e senza segno, incremento e decremento. La libreria `mem` fa parte della Libreria di Sistema (progetto `mem.c64`) ed è scritta in assembly 6510 per C64Studio (sintassi ACME).

Questo documento deriva dai sorgenti. Per ogni dettaglio fanno fede i contratti d'interfaccia nelle intestazioni delle macro e delle subroutine.

<a id="contenuto"></a>
## Contenuto

| Modulo | Utilità | Descrizione |
|---|---|---|
| [`mem16.asm`](#modulo-mem16) | [`m_Mov16`](#utilita-m_mov16) | Sposta un valore o un puntatore a 16 bit |
| | [`m_Swap16`](#utilita-m_swap16) | Scambia due puntatori a 16 bit |
| | [`m_CmpU16`](#utilita-m_cmpu16) | Confronta due valori a 16 bit senza segno |
| | [`m_CmpS16`](#utilita-m_cmps16) | Confronta due valori a 16 bit con segno |
| | [`m_Inc16`](#utilita-m_inc16) | Incrementa un contatore a 16 bit |
| | [`m_Dec16`](#utilita-m_dec16) | Decrementa un contatore a 16 bit |
| [`mem24.asm`](#modulo-mem24) | [`m_Mov24`](#utilita-m_mov24) | Sposta un valore o un puntatore a 24 bit |
| | [`m_Swap24`](#utilita-m_swap24) | Scambia due puntatori a 24 bit |
| | [`m_CmpU24`](#utilita-m_cmpu24) | Confronta due valori a 24 bit senza segno |
| | [`m_CmpS24`](#utilita-m_cmps24) | Confronta due valori a 24 bit con segno |
| | [`m_Inc24`](#utilita-m_inc24) | Incrementa un contatore a 24 bit |
| | [`m_Dec24`](#utilita-m_dec24) | Decrementa un contatore a 24 bit |
| [`mem32.asm`](#modulo-mem32) | [`m_Mov32`](#utilita-m_mov32) | Sposta un valore o un puntatore a 32 bit |
| | [`m_Swap32`](#utilita-m_swap32) | Scambia due puntatori a 32 bit |
| | [`m_CmpU32`](#utilita-m_cmpu32) | Confronta due valori a 32 bit senza segno |
| | [`m_CmpS32`](#utilita-m_cmps32) | Confronta due valori a 32 bit con segno |
| | [`m_Inc32`](#utilita-m_inc32) | Incrementa un contatore a 32 bit |
| | [`m_Dec32`](#utilita-m_dec32) | Decrementa un contatore a 32 bit |

## Uso

### Inclusione

La cartella `mem` sta nella cartella delle librerie di C64Studio, accanto alle altre librerie di sistema. Il sorgente principale del programma include i moduli che usa nella parte dedicata al codice, uno per ogni larghezza:

```
!source <mem/mem16.asm>, once
!source <mem/mem24.asm>, once
!source <mem/mem32.asm>, once
```

I moduli non includono altri file. Solo le macro di scambio (`m_Swap16`, `m_Swap24`, `m_Swap32`) dichiarano una dipendenza, da `<system/standard.asm>`, che il programma include prima. Ogni macro si invoca con `+nome`, seguito dai parametri; il primo parametro delle macro che hanno più indirizzamenti è la stringa del modo (`"IMM"`, `"ABS"` o `"ZP"`). Gli operandi devono essere definiti prima dell'invocazione.

| Modulo | Include da sé | File da includere prima |
|---|---|---|
| `mem16.asm` | Nessuno | `<system/standard.asm>` |
| `mem24.asm` | Nessuno | `<system/standard.asm>` |
| `mem32.asm` | Nessuno | `<system/standard.asm>` |

### Configurazione

Tutte le utilità sono macro: non hanno parametri `__USE_<NOME>` e si assemblano solo quando vengono invocate, con `+nome`, seguito dai parametri.

<a id="modulo-mem16"></a>
## mem16.asm

Macro per la manipolazione di valori a 16 bit.

<a id="utilita-m_mov16"></a>
### m_Mov16

Chiamata: `+m_Mov16 .mode_, .src_, .dest_`

Copia un valore costante o un puntatore a 16 bit dalla sorgente alla destinazione, secondo l'indirizzamento scelto.

```
"IMM"  Immediato: .src_ è un valore a 16 bit e .dest_ è un
       indirizzo o una coppia di registri.
"ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti; uno
       dei due può essere una coppia di registri.
"ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
       zero; uno dei due può essere una coppia di registri.
```

Le coppie di registri si scrivono "`.<hi><lo>`" (byte alto e byte basso): `.AX`, `.AY`, `.XY`, `.XA`, `.YA` e `.YX`.

Con `"IMM"` una costante con i due byte uguali (per esempio 0, `$FFFF` o `$4242`) usa una sequenza più breve. Con `"ABS"` e `"ZP"`, da indirizzo a indirizzo, la copia procede nel verso che non altera il sorgente se le due aree si sovrappongono.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.src_` (2 byte, Macro): Valore (`IMM`), indirizzo o coppia di registri<br>`.dest_` (2 byte, Macro): Indirizzo o coppia di registri |
| Output | `.dest_` (2 byte, Macro): Riceve il valore di `.src_` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_swap16"></a>
### m_Swap16

Chiamata: `+m_Swap16 .addr1_, .addr2_`

Scambia il valore di due puntatori a 16 bit usando i registri.

| Voce | Contenuto |
|---|---|
| Input | `.addr1_` (2 byte, Macro): Indirizzo del primo valore<br>`.addr2_` (2 byte, Macro): Indirizzo del secondo valore |
| Output | `.addr1_` (2 byte, Macro): Riceve il valore di `.addr2_`<br>`.addr2_` (2 byte, Macro): Riceve il valore di `.addr1_` |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmpu16"></a>
### m_CmpU16

Chiamata: `+m_CmpU16 .mode_, .op1_, .op2_`

Confronta due valori a 16 bit senza segno, secondo l'indirizzamento scelto. Il risultato è nei flag, come con l'istruzione `CMP`.

```
"IMM"  Immediato: .op1_ è un indirizzo o una coppia di
       registri, .op2_ è un valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
       può essere una coppia di registri.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero; .op1_ può essere una coppia di registri.
```

Le coppie di registri si scrivono "`.<hi><lo>`" (byte alto e byte basso): `.AX`, `.AY`, `.XY`, `.XA`, `.YA` e `.YX`. Con una coppia di registri come `.op1_` nessun registro viene alterato.

Con `"IMM"` e `.op1_` indirizzo, i confronti con 0 e con `$FFFF` usano una sequenza più breve.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (2 byte, Macro): Primo operando: indirizzo o coppia di registri<br>`.op2_` (2 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Zero (1 bit, .P): 0 = `.op1_` diverso da `.op2_`; 1 = uguali<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmps16"></a>
### m_CmpS16

Chiamata: `+m_CmpS16 .mode_, .op1_, .op2_`

Confronta due valori a 16 bit con segno, secondo l'indirizzamento scelto. Il flag di Carry si comporta come con l'istruzione `CMP` (senza segno); con segno vale N xor V = 1 se `.op1_` < `.op2_`.

```
"IMM"  Immediato: .op1_ è un indirizzo o una coppia di
       registri, .op2_ è un valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
       può essere una coppia di registri.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero; .op1_ può essere una coppia di registri.
```

Le coppie di registri si scrivono "`.<hi><lo>`" (byte alto e byte basso): `.AX`, `.AY`, `.XY`, `.XA`, `.YA` e `.YX`.

Con `"IMM"` e `.op1_` indirizzo o coppia di registri, il confronto con 0 usa una sequenza più breve a parità di flag. Il flag di Zero riflette solo il byte alto del risultato: per verificare l'uguaglianza si usa `m_CmpU16`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (2 byte, Macro): Primo operando: indirizzo o coppia di registri<br>`.op2_` (2 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Negative (1 bit, .P): 0 = bit #7 a 0; 1 = bit #7 a 1<br>oVerflow (1 bit, .P): 0 = nessun overflow con segno; 1 = overflow con segno<br>Zero (1 bit, .P): 0 = byte alto diverso da 0; 1 = uguale a 0<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_inc16"></a>
### m_Inc16

Chiamata: `+m_Inc16 .addr_`

Incrementa di 1 un contatore a 16 bit contenuto in un puntatore o in una coppia di registri.

Le coppie di registri si scrivono "`.<hi><lo>`" (byte alto e byte basso): `.AX`, `.AY`, `.XY`, `.XA`, `.YA` e `.YX`.

Con un indirizzo non viene alterato nessun registro.

I flag Carry, Negative e oVerflow in uscita sono indefiniti.

L'operando deve essere definito prima dell'invocazione, perché la macro lo confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (2 byte, Macro): Contatore: indirizzo o coppia di registri |
| Output | `.addr_` (2 byte, Macro): Contatore incrementato (da `$FFFF` a `$0000`)<br>Zero (1 bit, .P): 0 = risultato diverso da 0; 1 = risultato 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_dec16"></a>
### m_Dec16

Chiamata: `+m_Dec16 .addr_`

Decrementa di 1 un contatore a 16 bit contenuto in un puntatore o in una coppia di registri.

Le coppie di registri si scrivono "`.<hi><lo>`" (byte alto e byte basso): `.AX`, `.AY`, `.XY`, `.XA`, `.YA` e `.YX`.

Con un indirizzo viene alterato `.A`; con una coppia di registri solo i due registri della coppia.

I flag Carry, Negative e oVerflow in uscita sono indefiniti.

L'operando deve essere definito prima dell'invocazione, perché la macro lo confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (2 byte, Macro): Contatore: indirizzo o coppia di registri |
| Output | `.addr_` (2 byte, Macro): Contatore decrementato (da `$0000` a `$FFFF`)<br>Zero (1 bit, .P): 0 = byte basso diverso da 0; 1 = byte basso 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-mem24"></a>
## mem24.asm

Macro per la manipolazione di valori a 24 bit.

<a id="utilita-m_mov24"></a>
### m_Mov24

Chiamata: `+m_Mov24 .mode_, .src_, .dest_`

Copia un valore costante o un puntatore a 24 bit dalla sorgente alla destinazione, secondo l'indirizzamento scelto.

```
"IMM"  Immediato: .src_ è un valore a 24 bit e .dest_ è un
       indirizzo o una terna di registri.
"ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti; uno
       dei due può essere una terna di registri.
"ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
       zero; uno dei due può essere una terna di registri.
```

Le terne di registri si scrivono "`.<hi><mid><lo>`" (byte alto, intermedio e basso): `.AXY` e `.YXA`.

Con `"IMM"` una costante con i tre byte uguali (per esempio 0, `$FFFFFF` o `$424242`) usa una sequenza più breve. Con `"ABS"` e `"ZP"`, da indirizzo a indirizzo, la copia procede nel verso che non altera il sorgente se le due aree si sovrappongono.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.src_` (3 byte, Macro): Valore (`IMM`), indirizzo o terna di registri<br>`.dest_` (3 byte, Macro): Indirizzo o terna di registri |
| Output | `.dest_` (3 byte, Macro): Riceve il valore di `.src_` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_swap24"></a>
### m_Swap24

Chiamata: `+m_Swap24 .addr1_, .addr2_`

Scambia il valore di due puntatori a 24 bit usando i registri.

| Voce | Contenuto |
|---|---|
| Input | `.addr1_` (3 byte, Macro): Indirizzo del primo valore<br>`.addr2_` (3 byte, Macro): Indirizzo del secondo valore |
| Output | `.addr1_` (3 byte, Macro): Riceve il valore di `.addr2_`<br>`.addr2_` (3 byte, Macro): Riceve il valore di `.addr1_` |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmpu24"></a>
### m_CmpU24

Chiamata: `+m_CmpU24 .mode_, .op1_, .op2_`

Confronta due valori a 24 bit senza segno, secondo l'indirizzamento scelto. Il risultato è nei flag, come con l'istruzione `CMP`.

```
"IMM"  Immediato: .op1_ è un indirizzo o una terna di
       registri, .op2_ è un valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
       può essere una terna di registri.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero; .op1_ può essere una terna di registri.
```

Le terne di registri si scrivono "`.<hi><mid><lo>`" (byte alto, intermedio e basso): `.AXY` e `.YXA`. Con una terna di registri come `.op1_` nessun registro viene alterato.

Con `"IMM"` e `.op1_` indirizzo, i confronti con 0 e con `$FFFFFF` usano una sequenza più breve.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (3 byte, Macro): Primo operando: indirizzo o terna di registri<br>`.op2_` (3 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Zero (1 bit, .P): 0 = `.op1_` diverso da `.op2_`; 1 = uguali<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmps24"></a>
### m_CmpS24

Chiamata: `+m_CmpS24 .mode_, .op1_, .op2_`

Confronta due valori a 24 bit con segno, secondo l'indirizzamento scelto. Il flag di Carry si comporta come con l'istruzione `CMP` (senza segno); con segno vale N xor V = 1 se `.op1_` < `.op2_`.

```
"IMM"  Immediato: .op1_ è un indirizzo o una terna di
       registri, .op2_ è un valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti; .op1_
       può essere una terna di registri.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero; .op1_ può essere una terna di registri.
```

Le terne di registri si scrivono "`.<hi><mid><lo>`" (byte alto, intermedio e basso): `.AXY` e `.YXA`. Con `.AXY` come `.op1_` la macro usa temporaneamente un byte dello stack e lo rilascia prima di terminare.

Con `"IMM"` il confronto con 0 (indirizzo o terna di registri) e con `$FFFFFF` (indirizzo o `.AXY`) usa una sequenza più breve a parità di flag. Il flag di Zero riflette solo il byte alto del risultato: per verificare l'uguaglianza si usa `m_CmpU24`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (3 byte, Macro): Primo operando: indirizzo o terna di registri<br>`.op2_` (3 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Negative (1 bit, .P): 0 = bit #7 a 0; 1 = bit #7 a 1<br>oVerflow (1 bit, .P): 0 = nessun overflow con segno; 1 = overflow con segno<br>Zero (1 bit, .P): 0 = byte alto diverso da 0; 1 = uguale a 0<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_inc24"></a>
### m_Inc24

Chiamata: `+m_Inc24 .addr_`

Incrementa di 1 un contatore a 24 bit contenuto in un puntatore o in una terna di registri.

Le terne di registri si scrivono "`.<hi><mid><lo>`" (byte alto, intermedio e basso): `.AXY` e `.YXA`. Con un indirizzo non viene alterato nessun registro.

I flag Carry, Negative e oVerflow in uscita sono indefiniti.

L'operando deve essere definito prima dell'invocazione, perché la macro lo confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (3 byte, Macro): Contatore: indirizzo o terna di registri |
| Output | `.addr_` (3 byte, Macro): Contatore incrementato (da `$FFFFFF` a `$000000`)<br>Zero (1 bit, .P): 0 = risultato diverso da 0; 1 = risultato 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_dec24"></a>
### m_Dec24

Chiamata: `+m_Dec24 .addr_`

Decrementa di 1 un contatore a 24 bit contenuto in un puntatore o in una terna di registri.

Le terne di registri si scrivono "`.<hi><mid><lo>`" (byte alto, intermedio e basso): `.AXY` e `.YXA`. Con un indirizzo viene alterato `.A`; con una terna di registri solo i tre registri della terna.

I flag Carry, Negative e oVerflow in uscita sono indefiniti.

L'operando deve essere definito prima dell'invocazione, perché la macro lo confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (3 byte, Macro): Contatore: indirizzo o terna di registri |
| Output | `.addr_` (3 byte, Macro): Contatore decrementato (da `$000000` a `$FFFFFF`)<br>Zero (1 bit, .P): 0 = byte basso diverso da 0; 1 = byte basso 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-mem32"></a>
## mem32.asm

Macro per la manipolazione di valori a 32 bit.

<a id="utilita-m_mov32"></a>
### m_Mov32

Chiamata: `+m_Mov32 .mode_, .src_, .dest_`

Copia un valore costante o un puntatore a 32 bit dalla sorgente alla destinazione, secondo l'indirizzamento scelto. A 32 bit non sono previsti gruppi di registri: gli operandi sono indirizzi.

```
"IMM"  Immediato: .src_ è un valore a 32 bit e .dest_ è un
       indirizzo.
"ABS"  Assoluto: .src_ e .dest_ sono indirizzi assoluti.
"ZP"   Pagina Zero: .src_ e .dest_ sono indirizzi in pagina
       zero.
```

Con `"IMM"` una costante con i quattro byte uguali (per esempio 0, `$FFFFFFFF` o `$42424242`) usa una sequenza più breve. Con `"ABS"` e `"ZP"` la copia procede nel verso che non altera il sorgente se le due aree si sovrappongono.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.src_` (4 byte, Macro): Valore (`IMM`) o indirizzo<br>`.dest_` (4 byte, Macro): Indirizzo |
| Output | `.dest_` (4 byte, Macro): Riceve il valore di `.src_` |
| Registri Modificati | `.A`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_swap32"></a>
### m_Swap32

Chiamata: `+m_Swap32 .addr1_, .addr2_`

Scambia il valore di due puntatori a 32 bit usando i registri.

| Voce | Contenuto |
|---|---|
| Input | `.addr1_` (4 byte, Macro): Indirizzo del primo valore<br>`.addr2_` (4 byte, Macro): Indirizzo del secondo valore |
| Output | `.addr1_` (4 byte, Macro): Riceve il valore di `.addr2_`<br>`.addr2_` (4 byte, Macro): Riceve il valore di `.addr1_` |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmpu32"></a>
### m_CmpU32

Chiamata: `+m_CmpU32 .mode_, .op1_, .op2_`

Confronta due valori a 32 bit senza segno, secondo l'indirizzamento scelto. Il risultato è nei flag, come con l'istruzione `CMP`. A 32 bit non sono previsti gruppi di registri: gli operandi sono indirizzi.

```
"IMM"  Immediato: .op1_ è un indirizzo, .op2_ è un valore a 32
       bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero.
```

Con `"IMM"`, i confronti con 0 e con `$FFFFFFFF` usano una sequenza più breve.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (4 byte, Macro): Primo operando: indirizzo<br>`.op2_` (4 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Zero (1 bit, .P): 0 = `.op1_` diverso da `.op2_`; 1 = uguali<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cmps32"></a>
### m_CmpS32

Chiamata: `+m_CmpS32 .mode_, .op1_, .op2_`

Confronta due valori a 32 bit con segno, secondo l'indirizzamento scelto. Il flag di Carry si comporta come con l'istruzione `CMP` (senza segno); con segno vale N xor V = 1 se `.op1_` < `.op2_`. A 32 bit non sono previsti gruppi di registri: gli operandi sono indirizzi.

```
"IMM"  Immediato: .op1_ è un indirizzo, .op2_ è un valore a 32
       bit.
"ABS"  Assoluto: gli operandi sono indirizzi assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in pagina
       zero.
```

Con `"IMM"`, il confronto con 0 e con `$FFFFFFFF` usa una sequenza più breve a parità di flag. Il flag di Zero riflette solo il byte alto del risultato: per verificare l'uguaglianza si usa `m_CmpU32`.

Con `"IMM"`, `.op2_` deve essere definito prima dell'invocazione, perché la macro lo confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (4 byte, Macro): Primo operando: indirizzo<br>`.op2_` (4 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo |
| Output | Negative (1 bit, .P): 0 = bit #7 a 0; 1 = bit #7 a 1<br>oVerflow (1 bit, .P): 0 = nessun overflow con segno; 1 = overflow con segno<br>Zero (1 bit, .P): 0 = byte alto diverso da 0; 1 = uguale a 0<br>Carry (1 bit, .P): 0 = `.op1_` < `.op2_`; 1 = `.op1_` >= `.op2_` (senza segno) |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_inc32"></a>
### m_Inc32

Chiamata: `+m_Inc32 .addr_`

Incrementa di 1 un contatore a 32 bit contenuto in un puntatore. Non viene alterato nessun registro.

Il flag Negative in uscita è indefinito.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (4 byte, Macro): Contatore: indirizzo |
| Output | `.addr_` (4 byte, Macro): Contatore incrementato (da `$FFFFFFFF` a `$00000000`)<br>Zero (1 bit, .P): 0 = risultato diverso da 0; 1 = risultato 0 |
| Registri Modificati | `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_dec32"></a>
### m_Dec32

Chiamata: `+m_Dec32 .addr_`

Decrementa di 1 un contatore a 32 bit contenuto in un puntatore. Viene alterato `.A`.

Il flag Negative in uscita è indefinito.

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (4 byte, Macro): Contatore: indirizzo |
| Output | `.addr_` (4 byte, Macro): Contatore decrementato (da `$00000000` a `$FFFFFFFF`)<br>Zero (1 bit, .P): 0 = byte basso diverso da 0; 1 = byte basso 0 |
| Registri Modificati | `.A`, `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="limiti-noti"></a>
## Limiti noti

I sorgenti non dichiarano limiti: nessun riquadro TO-DO e nessuna nota d'uso.

[↑ Torna al contenuto](#contenuto)

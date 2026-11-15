# IPL5X firmware v0.34 — HotWire4X edition

**EN** — Firmware of the **IPL5X**, the USB hot wire CNC interface (PIC18F4550) designed by
Pascal Langer for the 5XProject. Version **0.34** is the one required by
[HotWire4X](https://hotwire4x.com).

Ready-to-flash file: **`IPL5X_v0.34-HotWire4X.hex`** in the
**[latest release](https://github.com/RenaudILTIS/IPL5X-HotWire4X/releases/latest)**.
Flashing and wiring, step by step: [hotwire4x.com/requirements/ipl5x](https://hotwire4x.com/requirements/ipl5x).

**What changes in 0.34**: the STOP/PROG button also cuts the heat (PWM) when the machine is
idle. In 0.33, the interrupt routine cleared the heat on STOP, but `Read_PWM` set it again at
once when no motion was running. Version 0.34 adds two instructions at the start of the
protection block of `Read_PWM` (`btfss E_PROG` / `bcf FLAG_PWM_ISR`) and sets the version to
`0x0034` (`usb_defs.inc`).

**Where these sources come from.** Pascal Langer published the v0.33 sources under the GNU
GPL v3 (archive `IPL5X_Sources_v0.33161d.zip`, kept on
[cncpartage.fr](https://cncpartage.fr/archive-5xproject/5xproject.dyndns.org/5XProject/IPL5X_Sources_v0.33161d.zip?fileId=754)).
He built v0.34 at Renaud Iltis's request; its sources were not published. The sources of
this repository reconstruct v0.34 from v0.33: the first commit is the v0.33 archive untouched,
the second one carries the change. The result was checked against the distributed binary
(by comparing the two `.hex` files, not by reassembling): every byte of program memory that differs between 0.33 and 0.34 is accounted for by the two
instructions, the version number, or an address shifted by those 4 bytes (jumps and calls,
table pointers, USB descriptor pointer). The tables placed at `0x7600` are identical.

**Building**: MPLAB MPASM and MPLINK with `rm18f4550.lkr` (PIC18F4550). The distributed
`.hex` starts at `0x1300`, after the USB bootloader, and holds no EEPROM data: flashing it
from HotWire4X keeps the interface's table.

Licence: GNU GPL v3 (`COPYING`).

**FR** — Firmware de l'**IPL5X**, l'interface USB de découpe CNC par fil chaud (PIC18F4550)
conçue par Pascal Langer pour le 5XProject. La version **0.34** est celle que demande
[HotWire4X](https://hotwire4x.com/fr). Fichier prêt à flasher :
**`IPL5X_v0.34-HotWire4X.hex`**, dans la
**[dernière release](https://github.com/RenaudILTIS/IPL5X-HotWire4X/releases/latest)**.
Flashage et câblage pas à pas : [hotwire4x.com/fr/prerequis/ipl5x](https://hotwire4x.com/fr/prerequis/ipl5x).

**Ce que change la 0.34** : le bouton STOP/PROG coupe aussi la chauffe (PWM) quand la machine
est à l'arrêt. En 0.33, la routine d'interruption coupait bien la chauffe au STOP, mais
`Read_PWM` la remettait aussitôt hors mouvement. La 0.34 ajoute deux instructions en tête du
bloc de protection de `Read_PWM` et passe la version à `0x0034`.

**D'où viennent ces sources.** Pascal Langer a publié les sources de la 0.33 sous GNU GPL v3
(archive conservée sur cncpartage.fr, lien ci-dessus). Il a compilé la 0.34 à la demande de
Renaud Iltis, sans en publier les sources. Celles de ce dépôt reconstituent la 0.34 à partir de
la 0.33 : le premier commit est l'archive 0.33 intacte, le second porte la modification. Le
résultat a été confronté au binaire distribué (en comparant les deux `.hex`, sans
réassembler) : chaque octet de mémoire programme qui diffère
entre 0.33 et 0.34 s'explique par les deux instructions, le numéro de version, ou une adresse
décalée de ces 4 octets. Les tables placées en `0x7600` sont identiques.

Licence GNU GPL v3 (`COPYING`).

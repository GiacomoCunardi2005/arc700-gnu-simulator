# GNU ARC700 Simulator — Reproducible Build

Build scripts for the historical GNU ARCompact / ARC700 simulator.

## Requirements

Linux, Git, Podman and GNU build tools inside the provided container.

## Installation

Run:

    ./install.sh

The installer downloads GNU Binutils/GDB at the pinned commit,
applies the compatibility patch and builds arc-elf32-run
inside a Debian 11 container.

## Output

    .local-build/install/bin/arc-elf32-run

Execute the simulator inside the Debian 11 container.

## Scope

This repository provides a CPU simulation environment.
It does not emulate complete Nikon camera hardware.

No Nikon firmware, extracted TBIB, firmware-derived ELF files,
disassemblies or traces are distributed.

CPU conformance is not certified at 99 percent.

## Original source

https://gnu.googlesource.com/binutils-gdb.git

Pinned commit:

fa7f0c2d4e8e670a608337d71857408010551215

See THIRD_PARTY_NOTICES.md.


## Known limitations

- The historical GNU ARC700 simulator does not decode the
  `muldw` and `muludw` DSP instruction encodings observed
  in Nikon COOLPIX S33 firmware. The optional experimental
  DSP patch covers only a restricted subset; see
  `patches/EXPERIMENTAL-S33.md`.
- CPU/ISA compatibility has not been certified at 99%.
- Hardware-specific MMIO and peripherals are not implemented.
- Nikon firmware and firmware-derived binaries are not distributed.

## Related research

The Nikon COOLPIX S33 findings obtained with this simulator
(firmware structure, boot chain, kernel, GUI, keys, DSP
instruction usage) are published in the
[AkeruOS](https://github.com/GiacomoCunardi2005/AkeruOS)
repository.

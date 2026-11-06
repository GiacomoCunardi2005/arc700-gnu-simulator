# Experimental S33 laboratory variants

These optional, mutually exclusive patches capture existing laboratory builds
against the upstream commit pinned in `config.env`. They do not change the
default installer or its output. Apply one patch to a separate clean source
checkout after `compat.patch`; do not apply both together.

* `s33-dsp-v7-experimental.patch` contains the laboratory AUX bounds and
  storage model, delay-slot correction, restricted empty IRQ-hint model, and
  provisional DSP instruction handling.
* `s33-defined-memory-v2-experimental.patch` includes all of the above and
  adds byte-level defined-memory tracking. It requires `S33_DEFINED_RANGES`
  to declare initial guest memory; `none` declares no initially defined bytes.

The DSP behavior and register-lane ordering are provisional; nonzero software
IRQ delivery is unsupported. AUX storage is a laboratory assumption, not a
hardware model. Defined-memory tracking covers selected CGEN accesses in a
synthetic 128 MiB bank and uses process-global state; it does not model DMA,
all host callbacks, physical RAM geometry, or multiple CPU lifecycles.
These variants do not establish hardware compatibility or a complete boot.

The laboratory validation used the existing local GNU builds: the defined
memory verifier covered 29 cases, and the DSP v7 GUI pipeline verifier passed
11 resources with two synthetic lookup tables each. Firmware, derived inputs,
and laboratory outputs are not part of this repository. The patches are
archived here; the installer does not apply or test them automatically.

## Incremental patch: `s33-dc-ctrl-aux-experimental.patch`

Apply after `s33-dsp-v7-experimental.patch` (or after the defined-memory
patch, which includes it). It adds one line to `sim/arc/cpu7.h`: a read of AUX
index `0x48` (`DC_CTRL`) is accepted and returns the assumed reset value `0`
(logged as `S33_AUX_LAB_RESET index=72 value=00000000 assumed=1`) instead of
stopping with "Unconfigured extended AUX read". It lets a guest poll the data
cache flush-busy bit (`bit 8`) and continue. This is a laboratory assumption
for guest code that polls the flag; it is not a cache model and says nothing
about physical flush timing. Writes to AUX `0x47` were already stored without
effect. No Nikon bytes, firmware or dumps are part of this repository.

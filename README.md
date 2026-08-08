# Bram

Bram currently builds as a 32-bit x86 Multiboot kernel image with Zig.

## Build

```sh
zig build
```

The kernel image is written to:

```text
zig-out/bin/init_kernel
```

## Build a Limine UEFI ISO

Copy the kernel into the Limine ISO tree:

```sh
cp zig-out/bin/init_kernel limine-iso/boot/bram.bin
```

Build the ISO:

```sh
xorriso -as mkisofs -R -r -J \
  -b limine-bios-cd.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -hfsplus -apm-block-size 2048 \
  --efi-boot limine-uefi-cd.bin \
  -efi-boot-part --efi-boot-image --protective-msdos-label \
  -o bram-limine.iso \
  limine-iso
```

## Run with QEMU and OVMF

```sh
qemu-system-x86_64 \
  -nic none \
  -bios /usr/share/ovmf/x64/OVMF.4m.fd \
  --cdrom bram-limine.iso
```

## Notes

- The current UEFI path uses Limine.
- The ISO staging tree lives in `limine-iso/`.
- The kernel remains a 32-bit x86 build.

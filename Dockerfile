FROM alpine:3.21.2

RUN apk update
RUN apk add xorriso grub qemu-system-x86_64
RUN apk add zig=0.13.0-r1

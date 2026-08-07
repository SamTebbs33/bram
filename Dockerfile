FROM alpine:3.21.2

RUN apk update
RUN apk add xorriso grub qemu-system-i386
RUN apk add zig=0.16.0-r1

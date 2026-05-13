FROM alpine:3.23

RUN apk update
RUN apk add xorriso grub qemu-system-i386
RUN apk add zig=0.15.2-r0

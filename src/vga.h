#ifndef VGA_H
#define VGA_H

#include "types.h"

extern volatile uint16_t* vga_buffer;

void clear_screen(void);
void print_char(char c, int x, int y, uint8_t color);
void print_string(const char* str, int x, int y, uint8_t color);

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

#endif

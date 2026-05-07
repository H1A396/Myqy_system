#include "vga.h"

volatile uint16_t* vga_buffer = (uint16_t*)0xB8000;

void clear_screen(void) {
    for (int i = 0; i < 80 * 25; i++) {
        vga_buffer[i] = 0x0720;
    }
}

void print_char(char c, int x, int y, uint8_t color) {
    vga_buffer[y * 80 + x] = (uint16_t)c | (uint16_t)(color << 8);
}

void print_string(const char* str, int x, int y, uint8_t color) {
    int i = 0;
    while (str[i] != '\0') {
        print_char(str[i], x + i, y, color);
        i++;
    }
}

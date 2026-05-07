typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long size_t;

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

volatile uint16_t* vga_buffer = (uint16_t*)0xB8000;

void clear_screen() {
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

int main() {
    clear_screen();
    
    print_string("Hello from C!", 0, 0, 0x0F);
    print_string("GRUB Boot + GDT Loaded", 0, 1, 0x07);
    print_string("System is running in Protected Mode", 0, 2, 0x0A);
    
    return 0;
}
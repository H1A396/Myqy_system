#include "types.h"
#include "vga.h"
#include "idt.h"
#include "pic.h"

int main() {
    clear_screen();

    print_string("Hello from C!", 0, 0, 0x0F);
    print_string("GRUB Boot + GDT Loaded", 0, 1, 0x07);
    print_string("System is running in Protected Mode", 0, 2, 0x0A);

    pic_remap();
    idt_init();

    __asm__ volatile("sti");

    print_string("IDT + PIC Initialized", 0, 3, 0x0B);
    print_string("Interrupts Enabled", 0, 4, 0x0B);

    while (1) {
        __asm__ volatile("hlt");
    }

    return 0;
}

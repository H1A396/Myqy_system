#include "idt.h"
#include "vga.h"

struct IDT_Entry idt_table[IDT_ENTRIES];

static const char* exception_names[] = {
    "Divide by Zero",
    "Debug",
    "Non-Maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Bound Range Exceeded",
    "Invalid Opcode",
    "Device Not Available",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Invalid TSS",
    "Segment Not Present",
    "Stack-Segment Fault",
    "General Protection Fault",
    "Page Fault",
    "Reserved",
    "x87 Floating-Point Exception",
    "Alignment Check",
    "Machine Check",
    "SIMD Floating-Point Exception",
    "Virtualization Exception",
    "Control Protection Exception"
};

void idt_set_gate(uint8_t num, uint32_t base, uint16_t selector, uint8_t flags) {
    idt_table[num].offset_low  = base & 0xFFFF;
    idt_table[num].offset_high = (base >> 16) & 0xFFFF;
    idt_table[num].selector    = selector;
    idt_table[num].zero        = 0;
    idt_table[num].type_attr   = flags;
}

void idt_init(void) {
    extern void isr_stubs_start(void);
    extern void irq_stubs_start(void);
    extern uint32_t isr_stub_table[];
    extern uint32_t irq_stub_table[];

    for (int i = 0; i < 32; i++) {
        uint32_t base = isr_stub_table[i];
        idt_set_gate(i, base, 0x08, 0x8E);
    }

    for (int i = 0; i < 16; i++) {
        uint32_t base = irq_stub_table[i];
        idt_set_gate(i + 32, base, 0x08, 0x8E);
    }

    struct IDT_Ptr idt_ptr;
    idt_ptr.limit = sizeof(idt_table) - 1;
    idt_ptr.base  = (uint32_t)&idt_table;

    __asm__ volatile("lidt %0" : : "m"(idt_ptr));
}

void isr_handler(uint32_t int_no, uint32_t err_code) {
    clear_screen();

    print_string("EXCEPTION: ", 0, 0, 0x0C);

    if (int_no < 22) {
        print_string(exception_names[int_no], 11, 0, 0x0C);
    } else {
        print_string("Unknown Exception", 11, 0, 0x0C);
    }

    char buf[12];
    int pos = 0;
    uint32_t n = err_code;
    if (n == 0) {
        buf[pos++] = '0';
    } else {
        while (n > 0) {
            buf[pos++] = (n % 10) + '0';
            n /= 10;
        }
    }
    buf[pos] = '\0';

    int len = pos;
    for (int i = 0; i < len / 2; i++) {
        char tmp = buf[i];
        buf[i] = buf[len - 1 - i];
        buf[len - 1 - i] = tmp;
    }

    print_string(" (Error Code: ", 0, 1, 0x07);
    print_string(buf, 15, 1, 0x07);
    print_string(")", 15 + pos, 1, 0x07);

    print_string("System halted.", 0, 3, 0x0C);

    while (1) {
        __asm__ volatile("cli; hlt");
    }
}

void irq_handler(uint32_t irq_no) {
    if (irq_no == 32) {
        static uint32_t tick = 0;
        tick++;
    }

    if (irq_no >= 40) {
        outb(0xA0, 0x20);
    }
    outb(0x20, 0x20);
}

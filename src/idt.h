#ifndef IDT_H
#define IDT_H

#include "types.h"

struct IDT_Entry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  zero;
    uint8_t  type_attr;
    uint16_t offset_high;
} __attribute__((packed));

struct IDT_Ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

#define IDT_ENTRIES 256

extern struct IDT_Entry idt_table[IDT_ENTRIES];

void idt_init(void);
void idt_set_gate(uint8_t num, uint32_t base, uint16_t selector, uint8_t flags);

void isr_handler(uint32_t int_no, uint32_t err_code);
void irq_handler(uint32_t irq_no);

#endif

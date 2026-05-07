#ifndef PIC_H
#define PIC_H

#include "types.h"

void pic_remap(void);
void pic_disable(void);
void pic_unmask(uint8_t irq);
void pic_mask(uint8_t irq);

#endif

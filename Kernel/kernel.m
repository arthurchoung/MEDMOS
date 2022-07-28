#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

#import <objc/runtime.h>
#import <objc/Object.h>

#include "MEDMOS.h"
#import "HOTDOG.h"

#import "foundation-printf.h"

static inline uint8_t vga_entry_color(unsigned char fg, unsigned char bg) 
{
	return fg | bg << 4;
}
 
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}
 
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
 
size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;
 
void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(7 /* light grey */, 0 /* black */);
	terminal_buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}
 
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}
 
void terminal_putchar(char c) 
{
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
			terminal_row = 0;
	}
}
 
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}
 
void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}


void abort(void)
{
}

int __objc_init_thread_system(void)
{
    return 0;
}

void __objc_sync_init(void)
{
}

void *objc_mutex_allocate(void)
{
    return (void *)1;
}

int objc_mutex_lock(void *mutex)
{
    return 0;
}

int objc_mutex_unlock(void *mutex)
{
    return 0;
}

void *memset(void *s, int c, size_t n)
{
    char *p = s;
    for (int i=0; i<(int)n; i++) {
        *p = c;
        p++;
    }
    return s;
}

void *memcpy(void *dest, const void *src, size_t n)
{
    char *p = (char *)src;
    char *q = dest;
    for (int i=0; i<(int)n; i++) {
        *q = *p;
        p++;
        q++;
    }
    return dest;
}

char *strcpy(char *dest, const char *src)
{
    char *p = (char *)src;
    char *q = dest;
    for(;;) {
        *q = *p;
        if (!*p) {
            break;
        }
        p++;
        q++;
    }
    return dest;
}

char *strncpy(char *dest, const char *src, size_t n)
{
    size_t i;

    for (i=0; i<n && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    for (; i<n; i++) {
        dest[i] = '\0';
    }
    return dest;
}

int strcmp(const char *s1, const char *s2)
{
    char *p = (char *)s1;
    char *q = (char *)s2;
    for(;;) {
        if (!*p && !*q) {
            return 0;
        }
        if (!*p) {
            return -1;
        }
        if (!*q) {
            return 1;
        }
        if (*p < *q) {
            return -1;
        } else if (*p > *q) {
            return 1;
        }
        p++;
        q++;
    }
    return 0;
}

int strncmp(const char *s1, const char *s2, size_t n)
{
    char *p = (char *)s1;
    char *q = (char *)s2;
    for(int i=0; i<n; i++) {
        if (!*p && !*q) {
            return 0;
        }
        if (!*p) {
            return -1;
        }
        if (!*q) {
            return 1;
        }
        if (*p < *q) {
            return -1;
        } else if (*p > *q) {
            return 1;
        }
        p++;
        q++;
    }
    return 0;
}

size_t strlen(const char *s)
{
    char *p = (char *)s;
    for(;;) {
        if (!*p) {
            break;
        }
        p++;
    }
    int len = p - s;
    return len;
}

int atoi(const char *nptr)
{
    int result = 0;
    char *p = (char *)nptr;
    for(;;) {
        if (!*p) {
            break;
        }
        if ((*p >= '0') && (*p <= '9')) {
            result *= 10;
            int val = *p - '0';
            result += val;
            p++;
        } else {
            break;
        }
    }
    return result;
}

unsigned long strtoul(const char *nptr, char **endptr, int base)
{
    return atoi(nptr);
}

long strtol(const char *nptr, char **endptr, int base)
{
    return atoi(nptr);
}

long long strtoll(const char *nptr, char **endptr, int base)
{
    return atoi(nptr);
}

double strtod(const char *nptr, char **endptr)
{
    return 0.0;
}

int isdigit(int c)
{
    if ((c >= '0') && (c <= '9')) {
        return 1;
    }
    return 0;
}

int printf(const char *format, ...)
{
    return 0;
}

int sprintf(char *str, const char *format, ...)
{
    va_list va;
    va_start(va, format);
    int ret = foundation_vsprintf(str, format, va);
    va_end(va);
    return ret;
}

int vfprintf(void *stream, const char *format, va_list ap)
{
    return 0;
}

int fprintf(FILE *stream, const char *format, ...)
{
    return 0;
}

#define MAX_MEM (192*1024*1024)
static char _mem[MAX_MEM];
static int _memidx = 0;

#define MAX_ALLOC (1024*1024)
typedef struct {
    void *ptr;
    size_t size;
} MemoryAllocation;
static MemoryAllocation _alloc[MAX_ALLOC];
static int _allocidx = 0;

void *malloc(size_t size)
{
    if (_allocidx >= MAX_ALLOC) {
        /* Out of allocations */
        return 0;
    }
    if (_memidx + size >= MAX_MEM) {
        /* Out of memory */
        return 0;
    }
    char *p = &_mem[_memidx];
    _memidx += size;
    int offset = _memidx % 8;
    if (offset != 0) {
        _memidx += 8 - offset;
    }

    _alloc[_allocidx].ptr = p;
    _alloc[_allocidx].size = size;
    _allocidx++;

    return p;
}

void *calloc(size_t nmemb, size_t size)
{
    int n = nmemb*size;
    void *p = malloc(n);
    if (p) {
        memset(p, 0, size);
    }

    return p;
}

void *realloc(void *ptr, size_t size)
{
    if (!ptr) {
        return malloc(size);
    }
    MemoryAllocation *match = 0;
    for (int i=0; i<_allocidx; i++) {
        if (_alloc[i].ptr == ptr) {
            match = ptr;
            break;
        }
    }
    if (!match) {
        return 0;
    }
    if (size <= match->size) {
        return match->ptr;
    }
    void *newptr = malloc(size);
    if (!newptr) {
        return 0;
    }
    memcpy(newptr, ptr, match->size);
    return newptr;
}

void free(void *ptr)
{
}

void exit(int status)
{
}

int isspace(int c)
{
    switch (c) {
        case ' ':
        case '\f':
        case '\n':
        case '\r':
        case '\t':
        case '\v':
            return 1;
    }
    return 0;
}

int isprint(int c)
{
    if (c < 32) {
        return 0;
    }
    if (c == 127) {
        return 0;
    }
    return 1;
}

char *strchr(const char *s, int c)
{
    char *p = s;
    for(;;) {
        if (!*p) {
            break;
        }
        if (*p == c) {
            return p;
        }
        p++;
    }
    return 0;
}

char *strrchr(const char *s, int c)
{
    char *result = 0;
    char *p = s;
    for(;;) {
        if (!*p) {
            break;
        }
        if (*p == c) {
            result = p;
        }
        p++;
    }
    return result;
}

void *memchr(const void *s, int c, size_t n)
{
    unsigned char *p = s;
    for(int i=0; i<n; i++) {
        if (*p == c) {
            return p;
        }
        p++;
    }
    return 0;
}

FILE *fopen(const char *pathname, const char *mode)
{
    return 0;
}

size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
    return 0;
}

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
    return 0;
}

int fclose(FILE *stream)
{
    return 0;
}

int toupper(int c)
{
    if ((c >= 'a') && (c <= 'z')) {
        return c - 32;
    }
    return c;
}

int tolower(int c)
{
    if ((c >= 'A') && (c <= 'Z')) {
        return c + 32;
    }
    return c;
}

char *getenv(const char *name)
{
    return 0;
}

int setenv(const char *name, const char *value, int overwrite)
{
    return 0;
}

int abs(int j)
{
    if (j < 0) {
        return j * -1;
    }
    return j;
}

char *strdup(const char *s)
{
    int len = strlen(s);
    char *newstr = malloc(len+1);
    if (!newstr) {
/* out of memory */
        exit(1);
    }
    strcpy(newstr, s);
    return newstr;
}

char *strstr(const char *haystack, const char *needle)
{
    int haystacklen = strlen(haystack);
    int needlelen = strlen(needle);
    char *p = haystack;
    for(int i=0; i<haystacklen-needlelen; i++) {
        if (!strncmp(p, needle, needlelen)) {
            return p;
        }
        p++;
    }
    return 0;
}


static inline void outl(unsigned short port, unsigned long val)
{
    asm volatile ( "outl %%eax, %%dx" : : "d"(port), "a"(val) );
}

static inline unsigned long inl(unsigned short port)
{
    unsigned long ret;
    asm volatile ( "inl %%dx, %%eax"
                   : "=a"(ret)
                   : "dN"(port) );
    return ret;
}
static inline void outb(uint16_t port, uint8_t val)
{
    asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
}

static inline uint8_t inb(uint16_t port)
{
    uint8_t ret;
    asm volatile ( "inb %1, %0"
                   : "=a"(ret)
                   : "Nd"(port) );
    return ret;
}


static inline void mouse_write(unsigned char c)
{
    for (int i=0; i<100000; i++) {
        unsigned char c = inb(0x64);
        if ((c & 0x02) == 0) {
            break;
        }
    }
    outb(0x64, 0xd4);
    for (int i=0; i<100000; i++) {
        unsigned char c = inb(0x64);
        if ((c & 0x02) == 0) {
            break;
        }
    }
    outb(0x60, c);
}
static inline unsigned char mouse_read()
{
    for (int i=0; i<100000; i++) {
        unsigned char c = inb(0x64);
        if ((c & 0x01) == 1) {
            break;
        }
    }
    unsigned char c = inb(0x60);
    return c;
}

static uint16_t pci_read_word(uint16_t bus, uint16_t slot, uint16_t func, uint16_t offset)
{
	uint64_t address;
    uint64_t lbus = (uint64_t)bus;
    uint64_t lslot = (uint64_t)slot;
    uint64_t lfunc = (uint64_t)func;
    uint16_t tmp = 0;
    address = (uint64_t)((lbus << 16) | (lslot << 11) |
              (lfunc << 8) | (offset & 0xfc) | ((uint32_t)0x80000000));
    outl (0xCF8, address);
    tmp = (uint16_t)((inl (0xCFC) >> ((offset & 2) * 8)) & 0xffff);
    return (tmp);
}

static unsigned long pci_read_long(uint16_t bus, uint16_t slot, uint16_t func, uint16_t offset)
{
	uint64_t address;
    uint64_t lbus = (uint64_t)bus;
    uint64_t lslot = (uint64_t)slot;
    uint64_t lfunc = (uint64_t)func;
    address = (uint64_t)((lbus << 16) | (lslot << 11) |
              (lfunc << 8) | (offset & 0xfc) | ((uint32_t)0x80000000));
    outl (0xCF8, address);
    return (inl (0xCFC));
}

static unsigned long pci_addr = 0;
static unsigned long pci_match = 0;
static unsigned char uart_data = 0;
static unsigned char uart_status = 0;
static int uart_count = 0;
static int uart_status_count = 0;
static unsigned long uart_prev_mem[8];
static unsigned long uart_mem[8];
static int uart_memidx = 0;
static unsigned char midibuf[256];
static int midiidx = 0;
static unsigned char midistatus = 0;
static unsigned char midinote = 0;
static unsigned long mpu_addr = 0;
static unsigned char mpu_ack = 0;

void mpu_init()
{
    if (!mpu_addr) {
        return;
    }

    for (int i=0; i<100000; i++) {
        unsigned char c = inb(mpu_addr+1);
        if ((c & 0x40) == 0) {
            break;
        }
    }
    outb(mpu_addr+1, 0xff);

    for (int i=0; i<100000; i++) {
        unsigned char c = inb(mpu_addr+1);
        if ((c & 0x80) == 0) {
            break;
        }
    }
    mpu_ack = inb(mpu_addr);

    for (int i=0; i<100000; i++) {
        unsigned char c = inb(mpu_addr+1);
        if ((c & 0x40) == 0) {
            break;
        }
    }
    outb(mpu_addr+1, 0x3f);
}

void mpu_wait_for_data_read_ready_clear()
{
    for(int i=0; i<100000; i++) {
        unsigned char c = inb(mpu_addr+1);
        if ((c & 0x40) == 0) {
            break;
        }
    }
}

void mpu_busy_wait(int duration)
{
    for (int i=0; i<duration; i++) {
        unsigned char c = inb(0x64);
    }
}

void mpu_send_note(int note, int duration)
{
    mpu_wait_for_data_read_ready_clear();
    outb(mpu_addr, note);
    mpu_wait_for_data_read_ready_clear();
    outb(mpu_addr, 64);

    mpu_busy_wait(duration);

    mpu_wait_for_data_read_ready_clear();
    outb(mpu_addr, note);
    mpu_wait_for_data_read_ready_clear();
    outb(mpu_addr, 0);
}

void mpu_send_midi_data()
{
    if (!mpu_addr) {
        return;
    }

    mpu_wait_for_data_read_ready_clear();
    outb(mpu_addr, 0x90);
///
    int duration = 100000;
    mpu_send_note(59, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(59, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(59, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(60, duration);
    mpu_send_note(65, duration);
    mpu_busy_wait(duration);
    mpu_send_note(64, duration);
    mpu_busy_wait(duration);
}

void uart_wait_for_data_read_ready_clear()
{
    for(int i=0; i<100000; i++) {
        unsigned char c = inb(pci_addr+9);
        if (c & 0x01) {
            unsigned char d = inb(pci_addr+8);
        }
        if (c & 0x02) {
            break;
        }
    }
}

void uart_busy_wait(int duration)
{
    for (int i=0; i<duration; i++) {
        unsigned char c = inb(pci_addr+9);
        if (c & 0x01) {
            unsigned char d = inb(pci_addr+8);
        }
    }
}

void uart_send_note(int note, int duration)
{
    uart_wait_for_data_read_ready_clear();
    outb(pci_addr+8, note);
    uart_wait_for_data_read_ready_clear();
    outb(pci_addr+8, 64);

    uart_busy_wait(duration);

    uart_wait_for_data_read_ready_clear();
    outb(pci_addr+8, note);
    uart_wait_for_data_read_ready_clear();
    outb(pci_addr+8, 0);
}

void uart_send_midi_data()
{
    if (!pci_addr) {
        return;
    }

    uart_wait_for_data_read_ready_clear();
    outb(pci_addr+8, 0x90);
///
    int duration = 100000;
    uart_send_note(59, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(59, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(59, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(60, duration);
    uart_send_note(65, duration);
    uart_busy_wait(duration);
    uart_send_note(64, duration);
    uart_busy_wait(duration);
}

id probe_pci_bus(int bus)
{
    id arr = nsarr();
    [arr addObject:nsfmt(@"pci bus %d", bus)];
    for (int i=0; i<32; i++) {
        unsigned long pci_id = pci_read_long(bus, i, 0, 0x00);
        if (pci_id == 0xffffffff) {
            continue;
        }
        [arr addObject:nsfmt(@"PCI %d ID: %x", i, pci_id)];
        if (pci_id == 0x13711274) {
        } else if (pci_id == 0x50001274) {
        } else if (pci_id == 0x00021102) {
        } else {
            continue;
        }
        pci_match = pci_id;
        unsigned long pci_command_status = pci_read_long(bus, i, 0, 0x04);
        [arr addObject:nsfmt(@"PCI %d Command/Status: %x", i, pci_command_status)];
        unsigned long pci_bar0 = pci_read_long(bus, i, 0, 0x10);
        [arr addObject:nsfmt(@"PCI %d BAR0: %x", i, pci_bar0)];
        unsigned long pci_interrupt = pci_read_long(bus, i, 0, 0x3c);
        [arr addObject:nsfmt(@"PCI %d Interrupt: %x", i, pci_interrupt)];
        pci_addr = pci_bar0 & 0xfffffffc;
        if (pci_addr) {
            [arr addObject:nsfmt(@"PCI %d addr: %x", i, pci_addr)];
            if (pci_id == 0x00021102) {
//                unsigned long sblive_inte = inl(pci_addr+0x0c);
//                [arr addObject:nsfmt(@"SBLive INTE: %x", sblive_inte)];
//                unsigned long sblive_hcfg = inl(pci_addr+0x14);
//                [arr addObject:nsfmt(@"SBLive Hardware Config: %x", sblive_hcfg)];


                mpu_addr = pci_addr+0x18;
                mpu_init();
                [arr addObject:nsfmt(@"MPU Ack: %x", mpu_ack)];
            } else {
                unsigned long es1371_control0 = inl(pci_addr);
                [arr addObject:nsfmt(@"ES1371 Control 0: %x", es1371_control0)];
                unsigned long es1371_control1 = inl(pci_addr+4);
                [arr addObject:nsfmt(@"ES1371 Control 1: %x", es1371_control1)];
                unsigned char es1371_io0 = inb(pci_addr);
                [arr addObject:nsfmt(@"ES1371 IO 0: %x", es1371_io0)];
                unsigned long es1371_memory_page = inl(pci_addr+0xc);
                [arr addObject:nsfmt(@"ES1371 Memory Page: %x", es1371_memory_page)];

                outl(pci_addr, es1371_control0|0x08);
                es1371_io0 = inb(pci_addr);
                [arr addObject:nsfmt(@"ES1371 IO 0: %x", es1371_io0)];
                es1371_control0 = inl(pci_addr);
                [arr addObject:nsfmt(@"ES1371 Control 0: %x", es1371_control0)];
                outb(pci_addr+9, 3);
                outb(pci_addr+9, 0);
                outb(pci_addr+0xa, 0);
            }
        }
    }
    return [arr join:@"\n"];
}

void kernel_main(unsigned long magic, unsigned long addr) 
{
//terminal_initialize();
//terminal_writestring("Hello!");

    unsigned int *mbi = (unsigned int *) addr;
    unsigned char *framebuffer = (unsigned char *)mbi[22];
    uint32_t framebuffer_pitch = mbi[24];
    uint32_t framebuffer_width = mbi[25];
    uint32_t framebuffer_height = mbi[26];

HOTDOG_initialize();

for (int i=0; i<8; i++) {
    uart_prev_mem[i] = 0;
    uart_mem[i] = 0;
}
    int iteration = 0;
    int inbytes = 0;

    id pool = [[NSAutoreleasePool alloc] init];
    id bitmap = [Definitions bitmapWithWidth:framebuffer_width height:framebuffer_height];
    [bitmap useC64Font];
    id obj = [Definitions Piano];

    int pci_bus = 17;
    id pci_str = probe_pci_bus(pci_bus);

/*
    for (int i=0; i<100000; i++) {
        unsigned char c = inb(0x64);
        if (c & 0x02 == 0) {
            break;
        }
    }
    outb(0x64, 0xad);

    for (int i=0; i<100000; i++) {
        unsigned char c = inb(0x64);
        if (c & 0x02 == 0) {
            break;
        }
    }
    outb(0x64, 0xa8);

    mouse_write(0xf6);
    unsigned char ack1 = mouse_read();
    mouse_write(0xf4);
    unsigned char ack2 = mouse_read();
*/

    unsigned char mousebuf[3];
    int mouseidx = 0;

    int mouseX = 5;
    int mouseY = 5;

    for (;;) {
        unsigned char keyDown = 0;
        for (int i=0; i<100000; i++) {
            if (mpu_addr) {
                uart_status = inb(mpu_addr+1);
                uart_status_count++;
                if ((uart_status & 0x80) == 0) {
                    uart_data = inb(mpu_addr);
                    uart_count++;
                    midibuf[midiidx] = uart_data;
                    midiidx++;
                    if (midiidx == 256) {
                        /* overflow */
                        break;
                    }
                }
            } else if (pci_addr) {
                if (pci_match == 0x00021102) {
                } else {
                    int timeout = 1;
                    for (int j=0; j<timeout; j++) {
                        uart_status = inb(pci_addr+9);
                        if (uart_status & 0x01) {
                            uart_data = inb(pci_addr+8);
                            uart_count++;
                            midibuf[midiidx] = uart_data;
                            midiidx++;
                            if (midiidx == 256) {
                                /* overflow */
                                break;
                            }
                            timeout = 10000;
                            j = 0;
                        }
                    }
                    if (midiidx) {
                        i = 100000;
                    }
                }
/*
                for(;;) {
                    uart_status = inb(pci_addr+9);
                    if (uart_status & 0x01) {
                        uart_data = inb(pci_addr+8);
                        uart_count++;

                        uart_prev_mem[0] = uart_mem[0];
                        uart_prev_mem[1] = uart_mem[1];
                        uart_prev_mem[2] = uart_mem[2];
                        uart_prev_mem[3] = uart_mem[3];
                        uart_prev_mem[4] = uart_mem[4];
                        uart_prev_mem[5] = uart_mem[5];
                        uart_prev_mem[6] = uart_mem[6];
                        uart_prev_mem[7] = uart_mem[7];

                        outl(pci_addr+0xc, 0xe);
                        uart_mem[0] = inl(pci_addr+0x30);
                        uart_mem[1] = inl(pci_addr+0x34);
                        uart_mem[2] = inl(pci_addr+0x38);
                        uart_mem[3] = inl(pci_addr+0x3c);
                        outl(pci_addr+0xc, 0xf);
                        uart_mem[4] = inl(pci_addr+0x30);
                        uart_mem[5] = inl(pci_addr+0x34);
                        uart_mem[6] = inl(pci_addr+0x38);
                        uart_mem[7] = inl(pci_addr+0x3c);

                        int lastidx = uart_memidx;
                        for (int j=0; j<8; j++) {
                            if (uart_mem[uart_memidx] != uart_prev_mem[uart_memidx]) {
                                lastidx = uart_memidx;
                            }
                            uart_memidx++;
                            if (uart_memidx == 8) {
                                uart_memidx = 0;
                            }
                        }
                        for(int j=0; j<8; j++) {
                            midibuf[midiidx] = uart_mem[uart_memidx];
                            midiidx++;
                            if (midiidx == 256) {
                                // overflow, not possible
                                break;
                            }
                            if (lastidx == uart_memidx) {
                                j = 8;
                            }
                            uart_memidx++;
                            if (uart_memidx == 8) {
                                uart_memidx = 0;
                            }
                        }

                        i = 100000;

                        continue;
                    }
                    break;
                }
*/
            }

            unsigned char c = inb(0x64);
            if ((c & 0x01) == 1) {
                keyDown = inb(0x60);
                if (keyDown == 2) {
                    pci_bus++;
                    pci_str = probe_pci_bus(pci_bus);
                }
                if (keyDown == 3) {
                    pci_bus--;
                    pci_str = probe_pci_bus(pci_bus);
                }
                if (keyDown == 4) {
                    uart_send_midi_data();
                }
                if (keyDown == 5) {
                    mpu_send_midi_data();
                }
                i = 100000;
            }
        }


/*
        for (int i=0; i<100000; i++) {
            unsigned char c = inb(0x64);
            if (c & 0x01 == 1) {
                c = inb(0x60);
                if (mouseidx == 3) {
                    mouseidx = 0;
                }
                mousebuf[mouseidx] = c;
                mouseidx++;
                break;
            }
        }
*/

        for (int i=0; i<midiidx; i++) {
            if (midibuf[i] & 0x80) {
                midistatus = midibuf[i];
                midinote = 0;
                continue;
            }
            if (midinote) {
                if ((midistatus & 0xf0) == 0x90) { /* note on */
                    if (midibuf[i]) {
                        [obj setNoteOn:midinote-20];
                    } else {
                        [obj setNoteOff:midinote-20];
                    }
                } else if ((midistatus & 0xf0) == 0x80) { /* note off */
                    [obj setNoteOff:midinote-20];
                }
                midinote = 0;
            } else {
                midinote = midibuf[i];
            }
        }
        midiidx = 0;

        [bitmap setColor:@"#0000aa"];
        [bitmap fillRectangleAtX:0 y:0 w:framebuffer_width h:framebuffer_height];
        [obj drawInBitmap:bitmap rect:[Definitions rectWithX:0 y:0 w:framebuffer_width h:framebuffer_height]];

        [bitmap setColor:@"#0088ff"];

        [bitmap drawBitmapText:nsfmt(@"UART: data %x status %x count %d %d", uart_data, uart_status, uart_count, uart_status_count) x:320 y:5];
        for (int i=0; i<8; i++) {
            [bitmap drawBitmapText:nsfmt(@"UART: mem %d %x", i, uart_mem[i]) x:320 y:20+10*i];
        }
        {
            id arr = nsarr();
            [arr addObject:nsfmt(@"MIDI: midiidx %d", midiidx)];
            for (int i=0; i<16; i++) {
                [arr addObject:nsfmt(@"%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x",
                    midibuf[i*16+0],
                    midibuf[i*16+1],
                    midibuf[i*16+2],
                    midibuf[i*16+3],
                    midibuf[i*16+4],
                    midibuf[i*16+5],
                    midibuf[i*16+6],
                    midibuf[i*16+7],
                    midibuf[i*16+8],
                    midibuf[i*16+9],
                    midibuf[i*16+10],
                    midibuf[i*16+11],
                    midibuf[i*16+12],
                    midibuf[i*16+13],
                    midibuf[i*16+14],
                    midibuf[i*16+15])];
            }
            id str = [arr join:@"\n"];
            [bitmap drawBitmapText:str x:320 y:100];
        }

        [bitmap drawBitmapText:nsfmt(@"Keys:\n1 probe next pci bus\n2 probe prev pci bus\n3 uart send midi data\n4 mpu send midi data\n\niteration %d\nfb pitch %d width %d height %d\nmemidx %d MAX MEM %d\nallocidx %d MAX ALLOC %d\nkeyDown %d\npci:\n%@", iteration, framebuffer_pitch, framebuffer_width, framebuffer_height, _memidx, MAX_MEM, _allocidx, MAX_ALLOC, keyDown, pci_str) x:10 y:10];
        if (mouseidx == 3) {
            int32_t mouseDeltaX = mousebuf[1];
            int32_t mouseDeltaY = mousebuf[2];
            BOOL leftButton = NO;
            BOOL middleButton = NO;
            BOOL rightButton = NO;
            if (mousebuf[0] & 0x01) { // left button
                leftButton = YES;
            }
            if (mousebuf[0] & 0x02) { // right button
                rightButton = YES;
            }
            if (mousebuf[0] & 0x04) { // middle button
                middleButton = YES;
            }
            if (mousebuf[0] & 0x10) { // x sign
                mouseDeltaX -= 256;
            }
            if (mousebuf[0] & 0x20) { // y sign
                mouseDeltaY -= 256;
            }
            [bitmap drawBitmapText:nsfmt(@"x %d y %d left %d middle %d right %d", mouseDeltaX, mouseDeltaY, leftButton, middleButton, rightButton) x:5 y:240];
            mouseX += mouseDeltaX;
            mouseY -= mouseDeltaY;
        } else {
            [bitmap drawBitmapText:nsfmt(@"mouseidx %d", mouseidx) x:5 y:240];
        }

        unsigned char *pixels = [bitmap pixelBytes];
        for (int i=0; i<framebuffer_height; i++) {
            memcpy(framebuffer+i*framebuffer_pitch, pixels+i*framebuffer_width*4, framebuffer_width*4);
        }

        iteration++;
    }
}

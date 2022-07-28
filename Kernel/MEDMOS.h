
typedef int time_t; //FIXME should be removed

typedef void *FILE;

void exit(int status);

void *malloc(size_t size);
void *calloc(size_t nmemb, size_t size);
void free(void *ptr);
char *strdup(const char *s);

void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t n);

size_t strlen(const char *s);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);
char *strchr(const char *s, int c);
char *strrchr(const char *s, int c);
char *strstr(const char *haystack, const char *needle);
void *memchr(const void *s, int c, size_t n);

FILE *fopen(const char *pathname, const char *mode);
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
int fclose(FILE *stream);

int isprint(int c);
int isspace(int c);
int isdigit(int c);
int toupper(int c);
int tolower(int c);

long strtol(const char *ptr, char **endptr, int base);
long long strtoll(const char *nptr, char **endptr, int base);
unsigned long strtoul(const char *nptr, char **endptr, int base);
double strtod(const char *nptr, char **endptr);

int abs(int j);

char *getenv(const char *name);
int setenv(const char *name, const char *value, int overwrite);

int sprintf(char *str, const char *format, ...);
int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);


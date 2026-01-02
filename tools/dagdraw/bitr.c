#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "pristine.xbm"

/* 2^18, ceil(420*596), ceil(A5) */
#define MAXBITS 262144
#define STKSIZE 32
#define BUFSIZE 32

typedef struct bt_context {
    int w, h;
    unsigned char bits[MAXBITS];
    char buf[BUFSIZE];
    int stk[STKSIZE];
    int sp;
    int bp;
} bt_context;

void bt_init(bt_context *ctx)
{
    int i;
    ctx->w = 320;
    ctx->h = 200;
    for (i = 0; i < MAXBITS; i++) ctx->bits[i] = 0;
    for (i = 0; i < 32; i++) ctx->buf[i] = 0;
    for (i = 0; i < 32; i++) ctx->stk[i] = 0;
    ctx->sp = ctx->bp = 0;
}

int bt_get(bt_context *ctx, int x, int y)
{
    int pos;
    int byte;
    int bit;
    unsigned char b;

    pos = y*ctx->w + x;
    byte = pos / 8;
    bit = pos % 8;
    b = ctx->bits[byte];


    return (b >> bit) & 1;
}

void bt_set(bt_context *ctx, int x, int y, int s)
{
    int pos;
    int byte;
    int bit;
    unsigned char b;

    pos = y*ctx->w + x;
    byte = pos / 8;
    bit = pos % 8;
    s &= 1;

    b = ctx->bits[byte];

    b &= ~(1 << bit);

    b |= s << bit;

    ctx->bits[byte] = b;
}

void bt_write(bt_context *ctx, const char *filename)
{
    FILE *fp;
    int x, y;

    if (filename[0] == '-') {
        fp = stdout;
    } else {
        fp = fopen(filename, "w");
    }

    fprintf(fp, "P1\n");
    fprintf(fp, "# generated with bitr\n");
    fprintf(fp, "%d %d\n", ctx->w, ctx->h);

    for (y = 0; y < ctx->h; y++) {
        for (x = 0; x < ctx->w; x++) {
            int b;
            char s[2];
            b = bt_get(ctx, x, y);
            s[0] = s[1] = 0;
            if (x > 0) s[0] = ' ';
            fprintf(fp, "%s%d", s, b);
        }
        fprintf(fp, "\n");
    }

    fclose(fp);
}

void bt_hline(bt_context *ctx, int x, int y, int len)
{
    int i;
    for (i = 0; i < len; i++) bt_set(ctx, x + i, y, 1);
}

void bt_vline(bt_context *ctx, int x, int y, int len)
{
    int i;
    for (i = 0; i < len; i++) bt_set(ctx, x, y + i, 1);
}

void bt_rect(bt_context *ctx, int x, int y, int w, int h)
{
    bt_vline(ctx, x, y, h);
    bt_hline(ctx, x, y, w);
    bt_hline(ctx, x, y + h - 1, w);
    bt_vline(ctx, x + w - 1, y, h);
}

void bt_rectf(bt_context *ctx, int x, int y, int w, int h)
{
    int i;
    for (i = 0; i < h; i++) bt_hline(ctx, x, y + i, w);
}

static const char *ktos_lookup =
    "_ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789$+";

void ktos(uint32_t k, char *s)
{
    int i;
    int n;
    uint32_t o;
    o = 0;

    for (i = 0; i < 5; i++) {
        int p;
        p = k & 63;
        k >>= 6;
        o |= p << ((4 - i) * 6);
    }

    n = 0;

    for (i = 0; i < 5; i++) {
        int p;
        char c;
        p = o & 63;
        o >>= 6;
        c = ktos_lookup[p];
        if (c != '_') {
            s[n] = c;
            n++;
        }
    }

    s[n] = 0;
}

void bt_glyph(bt_context *ctx, int x, int y, char c)
{
    int pos;
    int i, j;
    int stride;
    int px;
    int py;
    const unsigned char *bits;

    bits = pristine_bits;
    stride = pristine_width>>3;

    pos = c - 0x20;
    px = pos % stride;
    py = pos / stride;
    pos = py * stride * 8 + px;

    for (i = 0; i < 8; i++) {
        unsigned char b = bits[pos + i*stride];
        for (j = 0; j < 8; j++) {
            bt_set(ctx, x + j, y + i, ((1 << j) & b) > 0);
        }
    }

}

void bt_txt(bt_context *ctx, int x, int y, uint32_t k)
{
    char tmp[8];
    int i;
    int sz;

    for (i = 0; i < 8; i++) tmp[i] = 0;

    ktos(k, tmp);

    sz = strlen(tmp);

    for (i = 0; i < sz; i++) {
        bt_glyph(ctx, x + i*8, y, tmp[i]);
    }
}

void push(bt_context *ctx, int x)
{
    if (ctx->sp >= STKSIZE) return;
    ctx->stk[ctx->sp] = x;
    ctx->sp++;
}

int pop(bt_context *ctx)
{
    if (ctx->sp == 0) return -1;

    ctx->sp--;

    return ctx->stk[ctx->sp];
}

void parse_word(bt_context *ctx)
{
    char *buf;
    if (ctx->bp == 0) return;

    buf = ctx->buf;

    ctx->bp = 0;    

    if (buf[0] >= '0' && buf[0] <= '9') {
        int i;
        i = atoi(buf);
        push(ctx, i);
        return;
    }

    if (!strcmp(buf, "rc")) {
        int x, y, w, h;

        h = pop(ctx);
        w = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        bt_rect(ctx, x, y, w, h);

    }else if (!strcmp(buf, "rf")) {
        int x, y, w, h;

        h = pop(ctx);
        w = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        bt_rectf(ctx, x, y, w, h);
        return;
    } else if (!strcmp(buf, "vl")) {
        int x, y, d;

        d = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        bt_vline(ctx, x, y, d);
        return;
    } else if (!strcmp(buf, "hl")) {
        int x, y, d;

        d = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        bt_hline(ctx, x, y, d);
        return;
    } else if (!strcmp(buf, "sz")) {
        int w, h;

        h = pop(ctx);
        w = pop(ctx);

        ctx->w = w;
        ctx->h = h;
        return;
    } else if (!strcmp(buf, "tx")) {
        int x, y;
        uint32_t k;

        k = (uint32_t)pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        bt_txt(ctx, x, y, k);
        return;
    }

}

void parse(bt_context *ctx, char c)
{
    if (c == ' ' || c == '\n') {
        parse_word(ctx);
        return;
    }
    if (ctx->bp >= (BUFSIZE - 1)) return;
    ctx->buf[ctx->bp] = c;
    ctx->bp++;
    ctx->buf[ctx->bp] = 0;
}

int main(int argc, char *argv[])
{
    bt_context *ctx;
    FILE *fp;
    const char *filename;
    char c;

    fp = stdin;


    if (argc < 2) {
        fprintf(stderr, "Usage: %s out.pbm\n", argv[0]);
        return -1;
    }

    filename = argv[1];

    ctx = malloc(sizeof(bt_context));
    bt_init(ctx);

    while ((c = fgetc(fp)) != -1) {
        parse(ctx, c);
    }

    fflush(stdout);

    bt_write(ctx, filename);
    free(ctx);

    fclose(fp);
    return 0;
}

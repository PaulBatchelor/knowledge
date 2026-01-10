#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <cairo.h>
#include <cairo-ps.h>

#define STKSIZE 32
#define BUFSIZE 32

typedef struct vc_context {
    int w, h;
    char buf[BUFSIZE];
    int stk[STKSIZE];
    int sp;
    int bp;
    cairo_surface_t *surface;
    cairo_t *cr;
} vc_context;

void vc_init(vc_context *ctx)
{
    int i;
    ctx->w = 320;
    ctx->h = 200;
    for (i = 0; i < 32; i++) ctx->buf[i] = 0;
    for (i = 0; i < 32; i++) ctx->stk[i] = 0;
    ctx->sp = ctx->bp = 0;
    ctx->cr = NULL;
    ctx->surface = NULL;
}

void vc_hline(vc_context *ctx, int x, int y, int len)
{
    cairo_t *cr;
    cr = ctx->cr;
    if (cr == NULL) return;

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_set_line_width(cr, 1);
    cairo_move_to(cr, x + 0.5, y + 0.5);
    cairo_line_to(cr, x + len + 0.5, y + 0.5);
    cairo_stroke(cr);
}

void vc_vline(vc_context *ctx, int x, int y, int len)
{
    cairo_t *cr;
    cr = ctx->cr;
    if (cr == NULL) return;

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_set_line_width(cr, 1);
    cairo_move_to(cr, x + 0.5, y + 0.5);
    cairo_line_to(cr, x + 0.5, y + len + 0.5);
    cairo_stroke(cr);
}

void vc_rect(vc_context *ctx, int x, int y, int w, int h)
{
    cairo_t *cr;
    cr = ctx->cr;
    if (cr == NULL) return;
    cairo_rectangle(cr, x, y, w, h);
    cairo_set_source_rgb(cr, 1, 1, 1);
    cairo_fill_preserve(cr);
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_set_line_width(cr, 1);
    cairo_stroke(cr);
}

void vc_rectf(vc_context *ctx, int x, int y, int w, int h)
{
    cairo_t *cr;
    cr = ctx->cr;
    if (cr == NULL) return;
    cairo_rectangle(cr, x, y, w, h);
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_fill_preserve(cr);
    cairo_stroke(cr);
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

void vc_txt(vc_context *ctx, int x, int y, uint32_t k)
{
    char tmp[8];
    int i;
    int sz;
    cairo_t *cr;
    cairo_text_extents_t extents;

    cr = ctx->cr;
    if (cr == NULL) return;

    for (i = 0; i < 8; i++) tmp[i] = 0;

    ktos(k, tmp);

    sz = strlen(tmp);

    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                          CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 8);
    
    cairo_text_extents(cr, tmp, &extents);
#if 0
    cairo_move_to(cr, x - extents.width/2 - extents.x_bearing,
                  y - extents.height/2 - extents.y_bearing);
#endif
    cairo_move_to(cr, x, y + extents.height);
    cairo_show_text(cr, tmp);
}

void push(vc_context *ctx, int x)
{
    if (ctx->sp >= STKSIZE) return;
    ctx->stk[ctx->sp] = x;
    ctx->sp++;
}

int pop(vc_context *ctx)
{
    if (ctx->sp == 0) return -1;

    ctx->sp--;

    return ctx->stk[ctx->sp];
}

void parse_word(vc_context *ctx)
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

        vc_rect(ctx, x, y, w, h);

    } else if (!strcmp(buf, "rf")) {
        int x, y, w, h;

        h = pop(ctx);
        w = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        vc_rectf(ctx, x, y, w, h);
        return;
    } else if (!strcmp(buf, "vl")) {
        int x, y, d;

        d = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        vc_vline(ctx, x, y, d);
        return;
    } else if (!strcmp(buf, "hl")) {
        int x, y, d;

        d = pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        vc_hline(ctx, x, y, d);
        return;
    } else if (!strcmp(buf, "sz")) {
        int w, h;
        cairo_surface_t *surface;
        cairo_t *cr;

        h = pop(ctx);
        w = pop(ctx);

        ctx->w = w;
        ctx->h = h;

        surface = cairo_ps_surface_create("dag.eps", w, h);
        cairo_ps_surface_set_eps(surface, 1);
        cr = cairo_create(surface);

        cairo_set_source_rgb(cr, 1, 1, 1);
        cairo_paint(cr);

        ctx->surface = surface;
        ctx->cr = cr;
        return;
    } else if (!strcmp(buf, "tx")) {
        int x, y;
        uint32_t k;

        k = (uint32_t)pop(ctx);
        y = pop(ctx);
        x = pop(ctx);

        vc_txt(ctx, x, y, k);
        return;
    }
}

void parse(vc_context *ctx, char c)
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

void vc_clean(vc_context *ctx)
{
    if (ctx->cr != NULL) {
        cairo_destroy(ctx->cr);
    }

    if (ctx->surface != NULL) {
        cairo_surface_destroy(ctx->surface);
    }
}

int main(int argc, char *argv[])
{
    vc_context *ctx;
    FILE *fp;
    const char *filename;
    char c;

    fp = stdin;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s out.pbm\n", argv[0]);
        return -1;
    }

    filename = argv[1];

    ctx = malloc(sizeof(vc_context));
    vc_init(ctx);

    while ((c = fgetc(fp)) != -1) {
        parse(ctx, c);
    }

    fflush(stdout);

    vc_clean(ctx);

    free(ctx);

    fclose(fp);
    return 0;
}

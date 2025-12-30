#define _GNU_SOURCE
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define MAX_EDGES 512
#define MAX_VERTS 512
#define QUEUE_SIZE 16

enum {
    HORIZ,
    VERT,
    HORIZ_HIDDEN,
    VERT_HIDDEN
};

typedef struct gd_edge {
    int type;
    int v_a;
    int v_b;
    int w;
} gd_edge;

typedef struct gd_vert {
    uint32_t key;
    int n, e, s, w;
    /* used for traversal */
    int visited;
} gd_vert;

typedef struct queue_entry {
    int p, cx, cy;
} queue_entry;

typedef struct queue {
    queue_entry q[QUEUE_SIZE];
    int sz;
    int front;
    int back;
} queue;

typedef struct gd_ctx {
    gd_edge edges[MAX_EDGES];
    gd_vert verts[MAX_VERTS];
    int nedges;
    int nverts;
    queue q;
    int xmin, xmax;
    int ymin, ymax;
} gd_ctx;

void queue_init(queue *q)
{
    q->sz = 0;
    q->front = 0;
    q->back = 0;
}

void queue_append(queue *q, int p, int cx, int cy)
{
    queue_entry *ent;
    if (q->sz >= QUEUE_SIZE) return;
    ent = &q->q[q->back];
    ent->p = p;
    ent->cx = cx;
    ent->cy = cy;
    q->back++;
    q->sz++;
    q->back %= QUEUE_SIZE;
}

void queue_remove(queue *q, int *p, int *cx, int *cy)
{
    queue_entry *ent;
    if (q->sz <= 0) return;
    ent = &q->q[q->front];
    q->sz--;
    *p = ent->p;
    *cx = ent->cx;
    *cy = ent->cy;
    q->front++;
    q->front %= QUEUE_SIZE;
}

uint32_t stok(const char *str, int len)
{
    uint32_t x;
    int i;
    x = 0;

    for (i = 0; i < len; i++) {
        int p;
        char c;
        p = 0;

        c = str[i];

        /* 0: null */
        /* a-z (case insensitive): 1 - 26 */
        /* 0-9: 27 - 37 */
        /* 38: $ (used to indicate node) */
        /* 39: + (used to indicate junction) */

        if (c >= 'a' && c <= 'z') {
            p = 1 + (c - 'a');
        } else if (c >= 'A' && c <= 'Z') {
            p = 1 + (c - 'A');
        } else if (c >= '0' && c <= '9') {
            p = 27 + (c - '0');
        } else if (c == '$') {
            p = 37;
        } else if (c == '+') {
            p = 38;
        }

        x <<= 6;
        x |= p & 63;
    }

    return x;
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

void ctx_init(gd_ctx *ctx)
{
    ctx->nverts = 0;
    ctx->nedges = 0;
    ctx->xmin = ctx->ymin = 9999;
    ctx->xmax = ctx->ymax = -9999;
}

int append_node(gd_ctx *ctx, uint32_t key)
{
    int i;
    int out;
    gd_vert *v;
    int vid;

    if (ctx->nverts >= MAX_VERTS) return -1;

    out = -1;

    /* First, try to find existing node */
    for (i = 0; i < ctx->nverts; i++) {
        if (ctx->verts[i].key == key) {
            out = i;
            break;
        }
    }

    /* node previously defined */
    if (out >= 0) return out;

    /* create new node */
    vid = ctx->nverts;
    v = &ctx->verts[vid];
    ctx->nverts++;
    v->n = v->e = v->s = v->w = -1;
    v->key = key;
    v->visited = 0;

    return vid;
}

int mkint(const char *s, int n)
{
    int x;
    int i;

    x = 0;

    for (i = 0; i < n; i++) {
        int p;
        p = 0;
        if (s[i] >= '0' && s[i] <= '9') {
            p = s[i] - '0';
        }
        x *= 10;
        x += p;
    }

    return x;
}

void parse_line(gd_ctx *ctx, const char *line, ssize_t sz)
{
    ssize_t i;
    int arg;
    int start;
    int type;
    int v_a;
    int v_b;
    int weight;
    gd_edge *e;
    int eid;


    arg = 0;
    start = 0;
    type = HORIZ_HIDDEN;
    for (i = 0; i <= sz; i++) {
        /* TODO: handle multiple spaces */
        if (i == sz || line[i] == ' ') {
            switch (arg) {
                case 0:
                    switch (line[start]) {
                        case 'H':
                            type = HORIZ;
                            break;
                        case 'h':
                            type = HORIZ_HIDDEN;
                            break;
                        case 'V':
                            type = VERT;
                            break;
                        case 'v':
                            type = VERT_HIDDEN;
                            break;
                    }
                    break;
                case 1:
                    v_a = append_node(ctx, stok(&line[start], i - start));
                    break;
                case 2:
                    v_b = append_node(ctx, stok(&line[start], i - start));
                    break;
                case 3:
                    weight = mkint(&line[start], i - start);
                    break;
            }
            start = i + 1;
            arg += 1;
        }
    }
   
    eid = ctx->nedges; 
    ctx->nedges++;
    e = &ctx->edges[eid];
    e->type = type;
    e->v_a = v_a;
    e->v_b = v_b;
    e->w = weight;

    /* update vertices to point to edge */
    if (type == HORIZ || type == HORIZ_HIDDEN) {
        /* H: X.e -> Y.w */
        ctx->verts[v_a].e = eid;
        ctx->verts[v_b].w = eid;
    } else if (type == VERT || type == VERT_HIDDEN) {
        /* V: X.s -> X.n */
        ctx->verts[v_a].s = eid;
        ctx->verts[v_b].n = eid;
    }
}

void parse_file(gd_ctx *ctx, FILE *fp)
{
    ssize_t nread;
    size_t len;
    char *line;

    line = NULL;
    while ((nread = getline(&line, &len, fp)) != -1) {
        parse_line(ctx, line, nread - 1);
    }
    free(line);
}

void print_overlay(gd_ctx *ctx, gd_edge *e, int x, int y)
{
    char ka[8], kb[8];
    int i;
    gd_vert *a, *b;
    char ta, tb;
    char dir[2];
    int bx, by;

    for (i = 0; i < 8; i++) ka[i] = kb[i] = 0;

    a = &ctx->verts[e->v_a];
    b = &ctx->verts[e->v_b];

    ktos(a->key, ka);
    ktos(b->key, kb);

    ta = ka[0] == '$' ? 'N' : 'J';
    tb = kb[0] == '$' ? 'N' : 'J';

    dir[0] = dir[1] = '*';

    bx = x;
    by = y;

    if (e->type == VERT) {
        dir[0] = 'S';
        dir[1] = 'N';
        by += e->w + 1;
    } else if (e->type == HORIZ) {
        dir[0] = 'E';
        dir[1] = 'W';
        bx += e->w + 1;
    }

    printf("OVERLAY %s %c %d %d %c\n", ka, ta, x, y, dir[0]);
    printf("OVERLAY %s %c %d %d %c\n", kb, tb, bx, by, dir[1]);
}

void draw(gd_ctx *ctx, gd_vert *v, int cx, int cy)
{
    int i;
    char tmp[8];
    gd_edge *e;

    for (i = 0; i < 8; i++) tmp[i] = 0;
    /* draw */
    ktos(v->key, tmp);
   
    /* apply bounds retrieved from first traversal */
    cx -= ctx->xmin;
    cy -= ctx->ymin;

    if (tmp[0] == '$') {
        int klen;
        klen = strlen(&tmp[1]);
        /* draw node */
        printf("NODE %d %d %d %d\n", stok(&tmp[1], klen), klen, cx, cy);
    }

    /* draw lines */

    if (v->e >= 0) {
        e = &ctx->edges[v->e];
        if (e->type == HORIZ) {
            printf("HLINE %s %d %d %d\n", tmp, cx, cy, e->w);
            print_overlay(ctx, e, cx, cy);
        }
    }

    if (v->s >= 0) {
        e = &ctx->edges[v->s];
        if (e->type == VERT) {
            printf("VLINE %s %d %d %d\n", tmp, cx, cy, e->w);
            print_overlay(ctx, e, cx, cy);
        }
    }
}

void bounds(gd_ctx *ctx, gd_vert *v, int cx, int cy)
{
    if (cx > ctx->xmax) ctx->xmax = cx;
    if (cy > ctx->ymax) ctx->ymax = cy;
    if (cx < ctx->xmin) ctx->xmin = cx;
    if (cy < ctx->ymin) ctx->ymin = cy;
}

void traverse(gd_ctx *ctx, int x, int y,
        void (*process)(gd_ctx*, gd_vert *, int, int))
{
    int i;
    queue *q;
    gd_edge *edges;
    const int offs[][2] = {
        /* north */
        {0, -1},

        /* east */
        {1, 0},

        /* south */
        {0, 1},

        /* west */
        {-1, 0}
    };

    edges = ctx->edges;

    for (i = 0; i < ctx->nverts; i++) {
        ctx->verts[i].visited = 0;
    }

    q = &ctx->q;

    queue_init(q);
    /* add first node to Q */
    q = &ctx->q;
    queue_append(q, 0, x, y);

    while (q->sz > 0) {
        int p, cx, cy;
        int i;
        gd_vert *v;
        int dir[4];
        int w[4];

        p = cx = cy = 0;
        queue_remove(q, &p, &cx, &cy);
        v = &ctx->verts[p];

        /* for some reason, the last value duplicates,
         * so I added this check here */
        if (v->visited) continue;


        /* n->s = V(A, B) = V(s, n) = V(A) */
        dir[0] = edges[v->n].v_a;
        if (v->n < 0) w[0] = 0;
        else w[0] = edges[v->n].w;

        /* e->w = H(A, B) = H(e, w) = H(B) */
        dir[1] = edges[v->e].v_b;
        if (v->e < 0) w[1] = 0;
        else w[1] = edges[v->e].w;

        /* s->n = V(A, B) = V(s, n) = V(B) */
        dir[2] = edges[v->s].v_b;
        if (v->s < 0) w[2] = 0;
        else w[2] = edges[v->s].w;

        /* w->e = H(A, B) = H(e, w) = H(A) */
        dir[3] = edges[v->w].v_a;
        if (v->w < 0) w[3] = 0;
        else w[3] = edges[v->w].w;

        v->visited = 1;
        process(ctx, v, cx, cy);

        for (i = 0; i < 4; i++) {
            if (dir[i] < 0) continue;
            if (ctx->verts[dir[i]].visited) continue;
            queue_append(q, dir[i], cx + (w[i] + 1)*offs[i][0], cy + (w[i] + 1)*offs[i][1]);
        }
    }
}

void print_nodes(gd_ctx *ctx)
{
    int i;
    char tmp[8];

    for (i = 0; i < 8; i++) tmp[i] = 0;

    for (i = 0; i < ctx->nverts; i++) {
        int n, e, s, w;
        n = ctx->verts[i].n;
        e = ctx->verts[i].e;
        s = ctx->verts[i].s;
        w = ctx->verts[i].w;
        ktos(ctx->verts[i].key, tmp);
        printf("%s:\t%02d %02d %02d %02d\n",
                tmp, n, s, e, w);
    }
}

int main(int argc, char *argv[])
{
    gd_ctx *ctx;

    ctx = malloc(sizeof(gd_ctx));

    ctx_init(ctx);
    parse_file(ctx, stdin);

    traverse(ctx, 0, 0, bounds);
    printf("BOUNDS %d %d\n",
            ctx->xmax - ctx->xmin + 1, 
            ctx->ymax - ctx->ymin + 1);
    traverse(ctx, 0, 0, draw);

    free(ctx);
    return 0;
}

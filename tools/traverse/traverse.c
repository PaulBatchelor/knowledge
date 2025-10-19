#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlite3.h>
#define MEMSIZE (1 << 16)
#define MAX_ENTRIES 512

#if 0
static int callback(void *NotUsed, int argc, char **argv, char **azColName){
    int i;
    for(i=0; i<argc; i++){
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}
#endif

typedef struct node_entry {
    int id;
    const char *path;
} node_entry;
    
const char *query =
        "SELECT "
        "left, leftnode.name, "
        "right, rightnode.name "
        "FROM dz_connections "
        "INNER JOIN dz_nodes AS leftnode ON "
        "leftnode.id = dz_connections.left "
        "INNER JOIN dz_nodes AS rightnode ON "
        "rightnode.id = dz_connections.right "
        "WHERE rightnode.name IS ?1";

typedef struct state {
    char *strings;
    size_t spos;
    node_entry *ent;
    size_t ep;
} state;

typedef struct queue {
    int data[256];
    int front, back;
    int sz, cap;
} queue;

void append_entry(struct state *st, int id, const char *path)
{
    size_t len;
    len = strlen((const char *)path);
    memcpy(&st->strings[st->spos], path, len + 1);
    st->ent[st->ep].id = id;
    st->ent[st->ep].path = &st->strings[st->spos];
    st->spos += (len + 1);
    st->ep++;
}

void queue_init(queue *q) {
    q->sz = 0;
    q->cap = 256;
    q->front = q->back = 0;
}

void queue_add(queue *q, int x) {
    int pos;
    if (q->sz >= q->cap) return;
    q->data[q->back] = x;
    pos = (q->back + 1) % q->cap;
    q->back = pos;
    q->sz++;
}

int queue_pop(queue *q) {
    int x;
    int pos;
    if (q->sz <= 0) return -1;
    q->sz--;
    pos = q->front;
    x = q->data[pos];
    q->front = (pos + 1) % q->cap;

    return x;
}

void append_node_to_queue(state *st, queue *q, int id, const char *path)
{
    append_entry(st, id, path);
    queue_add(q, st->ep);
}

int traverse_node(sqlite3 *db, state *st, queue *q, const char *top_node)
{
    sqlite3_stmt *stmt;
    /* const char *top_node = "project/top"; */
    int rc;
    rc = sqlite3_prepare_v2(db, query, -1, &stmt, NULL);
    /* append_entry(st, -1, top_node); */

    if (rc) {
        fprintf(stderr, "Can't prepare: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return(1);
    }

    rc = sqlite3_bind_text(stmt, 1, top_node, -1, NULL);

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        int id_l, id_r;
        const unsigned char *name_l, *name_r;

        id_l = sqlite3_column_int(stmt, 0);
        id_r = sqlite3_column_int(stmt, 2);
        name_l = sqlite3_column_text(stmt, 1);
        name_r = sqlite3_column_text(stmt, 3);
        /* append_entry(st, id_l, (const char *)name_l); */
        append_node_to_queue(st, q, id_l, (const char *)name_l);

        printf("%d:%s -> %d:%s\n", id_l, name_l, id_r, name_r);
    }

    sqlite3_finalize(stmt);

    return 0;
}

int main(int argc, char **argv){
    sqlite3 *db;
    /* char *zErrMsg = 0; */
    int rc;
    const char *dbpath = "a.db";
    state st;
    size_t i;
    queue q;

    queue_init(&q);

    st.spos = 0;
    st.ep = 0;

    st.strings = malloc(MEMSIZE);
    memset(st.strings, 0, MEMSIZE);
    st.ent = malloc(MAX_ENTRIES);

    rc = sqlite3_open(dbpath, &db);

    if (rc) {
        fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return(1);
    }
  
    append_node_to_queue(&st, &q, -1, "project/top");

    while (q.sz > 0) {
        int e;
        node_entry *ent;
        e = queue_pop(&q);
        ent = &st.ent[e - 1];
        traverse_node(db, &st, &q, ent->path);
    }

    for (i = 0; i < st.ep; i++) {
        printf("%d: %s\n", st.ent[i].id, st.ent[i].path);
    }

    free(st.strings);
    free(st.ent);

    sqlite3_close(db);

    return 0;
}

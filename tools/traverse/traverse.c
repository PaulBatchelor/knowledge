#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlite3.h>
#define MEMSIZE (1 << 16)
#define MAX_ENTRIES 512
#define MAX_CONNECTIONS 1024

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

typedef struct connection {
    int left, right;
} connection;

typedef struct state {
    char *strings;
    size_t spos;
    node_entry *ent;
    size_t ep;
    connection *con;
    size_t cp;
} state;

typedef struct queue {
    int data[256];
    int front, back;
    int sz, cap;
} queue;

int append_entry(struct state *st, int id, const char *path)
{
    size_t len;
    len = strlen((const char *)path);
    memcpy(&st->strings[st->spos], path, len + 1);
    st->ent[st->ep].id = id;
    st->ent[st->ep].path = &st->strings[st->spos];
    st->spos += (len + 1);
    return ++st->ep;
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

int append_node_to_queue(state *st, queue *q, int id, const char *path)
{
    int eid;
    eid = append_entry(st, id, path);
    queue_add(q, st->ep);
    return eid;
}

void add_connection(state *st, int left, int right) {
    connection *c;
    c = &st->con[st->cp];
    c->left = left;
    c->right = right;
    st->cp++;
}

int find_entry(state *st, int id) {
    int i;

    for (i = 0; i < st->ep; i++) {
        if (st->ent[i].id == id) return i;
    }

    return -1;
}

int traverse_node(sqlite3 *db, state *st, queue *q, const char *top_node)
{
    sqlite3_stmt *stmt;
    /* const char *top_node = "project/top"; */
    int rc;
    rc = sqlite3_prepare_v2(db, query, -1, &stmt, NULL);

    if (rc) {
        fprintf(stderr, "Can't prepare: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return(1);
    }

    rc = sqlite3_bind_text(stmt, 1, top_node, -1, NULL);

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        int id_l, id_r;
        int eid;
        const unsigned char *name_l;

        id_l = sqlite3_column_int(stmt, 0);
        id_r = sqlite3_column_int(stmt, 2);
        name_l = sqlite3_column_text(stmt, 1);
        /* append_entry(st, id_l, (const char *)name_l); */
        eid = append_node_to_queue(st, q, id_l, (const char *)name_l);

        /* TODO: find_node() only needs to be calculated once */
        add_connection(st, eid, find_entry(st, id_r));
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
    st.cp = 0;
    st.con = malloc(MAX_CONNECTIONS);

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

    printf("i %ld %ld\n", st.ep, st.cp);

    for (i = 0; i < st.ep; i++) {
        printf("n %ld %s\n", i, st.ent[i].path);
    }

    for (i = 0; i < st.cp; i++) {
        int r = st.con[i].right;
        /* most likely root, but could be error */
        /* TODO: handle more elegantly */
        if (r < 0) r = 0;
        printf("c %d %d\n", st.con[i].left, r);
    }

    free(st.strings);
    free(st.ent);

    sqlite3_close(db);

    return 0;
}

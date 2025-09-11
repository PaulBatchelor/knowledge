#!/usr/bin/env python3
import sys
import subprocess
import sqlite3
import os

def read_dzfiles(dzfilename, cur, curpath):
    with open(dzfilename) as fp:
        linebuf = []
        linebuf_mode = False
        for line in fp:

            if len(line) == 0:
                continue

            if line[0] == '+':
                linebuf_mode = True
                linebuf = []
                continue


            fileargs = None

            if linebuf_mode:
                if line[0] == '.':
                    linebuf_mode = False
                    fileargs = " ".join(linebuf).split()
                    linebuf = []
                else:
                    linebuf.append(line[:-1])
                    continue
            else:
                fileargs = line[:-1].split()

            args = ["dagzet"]
            if os.path.isdir(fileargs[0]):
                common = os.path.commonpath((fileargs[0], curpath))
                newcurpath = common + fileargs[0].removeprefix(common)
                read_dzfiles(newcurpath + "/dzfiles.txt", cur, newcurpath)
                continue

            for i in range(len(fileargs)):
                if os.path.isfile(fileargs[i]):
                    continue

                # file might be a local path, in which case append prefix
                fileargs[i] = curpath + "/" + fileargs[i]
                if not os.path.isfile(fileargs[i]):
                    raise Exception(f"Could not find: {fileargs[i]}")
            args.extend(fileargs)

            if cur:
                print(" ".join(args[1:]))
                rc = subprocess.run(args, capture_output=True)
                if rc.returncode != 0:
                    print(rc.stderr.decode())
                    raise Exception("oops")
                cur.executescript(rc.stdout.decode())
            else:
                rc = subprocess.run(args)
                rc.check_returncode()


def run(args):
    dzfiles = "dzfiles.txt"

    if len(args) > 1:
        dzfiles = args[1]

    con = None
    cur = None
    if len(args) > 2:
        dbfile = args[2]
        con = sqlite3.connect(dbfile)
        cur = con.cursor()


    if cur:
        cur.executescript("\n".join([
        "DROP TABLE IF EXISTS dz_nodes;",
        "DROP TABLE IF EXISTS dz_connections;",
        "DROP TABLE IF EXISTS dz_connection_remarks;",
        "DROP TABLE IF EXISTS dz_lines;",
        "DROP TABLE IF EXISTS dz_remarks;",
        "DROP TABLE IF EXISTS dz_hyperlinks;",
        "DROP TABLE IF EXISTS dz_tags;",
        "DROP TABLE IF EXISTS dz_graph_remarks;",
        "DROP TABLE IF EXISTS dz_flashcards;",
        "DROP TABLE IF EXISTS dz_file_ranges;",
        "DROP TABLE IF EXISTS dz_images;",
        "DROP TABLE IF EXISTS dz_audio;",
        "DROP TABLE IF EXISTS dz_textfiles;",
        "DROP TABLE IF EXISTS dz_pages;",
        "DROP TABLE IF EXISTS dz_todo;",
        "DROP TABLE IF EXISTS dz_noderefs;",
        "DROP TABLE IF EXISTS dz_attributes;",
    ]))

    curpath=""
    read_dzfiles(dzfiles, cur, curpath)

if __name__ == "__main__":
    run(sys.argv)

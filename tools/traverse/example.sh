> a.db
dagzet tasks.dz | sqlite3 a.db
./traverse project/top | awk -f connections.awk | tsort

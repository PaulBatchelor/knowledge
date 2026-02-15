> ma123.txt
grep -v "^#" files.txt |\
while read -r LINE
do
    awk -f parse.awk $LINE >> ma123.txt
done

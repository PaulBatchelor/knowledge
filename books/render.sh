grep -v "^#" books/books.txt |\
while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ';' -f 2)
    echo $BOOK
    cd books;
    pdftex $BOOK >/dev/null;
    if [ ! "$?" -eq 0 ]
    then
        echo "TeX Error. See logs"
        exit 1
    fi
    cd - >/dev/null
done


grep -v "^#" books/books.txt |\
while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ':' -f 2)
    echo $BOOK $QUERY
    TEX=tmp/$BOOK.tex
    ./tools/inkbook.sh $QUERY > books/$BOOK.tex
done


while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ':' -f 2)
    echo $BOOK $QUERY
    ./tools/inkbook.sh $QUERY > books/$BOOK.tex
done < books/books.txt


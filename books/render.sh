while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ';' -f 2)
    echo $BOOK
    cd books; pdftex $BOOK; cd -
done < books/books.txt


while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ';' -f 2)
    echo $BOOK
    cd book; pdftex $BOOK; cd -
done < book/books.txt


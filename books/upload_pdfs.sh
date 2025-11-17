while read -r LINE
do
    BOOK=$(echo $LINE | cut -d ':' -f 1).pdf
    echo "uploading $BOOK"
    ./tools/rm_upload_pdf books/$BOOK
    # extra new line because curl output doesn't add one
    echo
done < books/books.txt

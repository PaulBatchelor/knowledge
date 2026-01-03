while read -r LINE
do
    OUTPUT=$(echo $LINE | cut -f 1 -d ':')
    cd notes; pdftex $OUTPUT; cd -
done < notes/notes.txt

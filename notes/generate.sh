mkdir -p notes/ink
while read -r LINE
do
    OUTPUT=$(echo $LINE | cut -f 1 -d ':')
    NAMESPACE=$(echo $LINE | cut -f 2 -d ':')
    echo $OUTPUT
    ./notes/mknotes.sh $NAMESPACE | ./notes/process.py > notes/$OUTPUT.tex
    ./notes/mknotes.sh $NAMESPACE | ./notes/inkpage.py > notes/ink/$OUTPUT.tex
done < notes/notes.txt

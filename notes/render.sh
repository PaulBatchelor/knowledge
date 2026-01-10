export TEXINPUTS=$(pwd)/tex/: 
while read -r LINE
do
    OUTPUT=$(echo $LINE | cut -f 1 -d ':')
    cd notes; pdftex $OUTPUT; cd -
    cd notes/ink; tex $OUTPUT; dvips $OUTPUT; ps2pdf $OUTPUT.ps; cd -
done < notes/notes.txt

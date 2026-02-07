export TEXINPUTS=$(pwd)/tex/: 
while read -r LINE
do
    NAME=$(echo $LINE | cut -d ':' -f 1)
    echo $NAME
    cd logs/tex;
    pdftex $NAME >/dev/null;
    if [ ! "$?" -eq 0 ]
    then
        echo "TeX Error. See logs"
        exit 1
    fi
    cd - >/dev/null
done < logs/logs.txt

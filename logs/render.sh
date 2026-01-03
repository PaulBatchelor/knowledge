while read -r LINE
do
    NAME=$(echo $LINE | cut -d ':' -f 1)
    echo $NAME
    TEXINPUTS=$(pwd)//: 
    cd logs/pdf; pdftex $NAME; cd -
done < logs/logs.txt

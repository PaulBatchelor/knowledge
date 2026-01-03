export TEXINPUTS=$(pwd)/tex/: 
while read -r LINE
do
    NAME=$(echo $LINE | cut -d ':' -f 1)
    echo $NAME
    cd logs/pdf; pdftex $NAME; cd -
done < logs/logs.txt

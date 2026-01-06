mkdir -p logs/pdf
while read -r LINE
do
    NAME=$(echo $LINE | cut -d ':' -f 1)
    TOP=$(echo $LINE | cut -d ':' -f 2)
    echo $NAME
    ./tools/messages $TOP | ./tools/messages2tex.py > logs/tex/$NAME.tex
done < logs/logs.txt

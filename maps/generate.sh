while read -r LINE
do
    MAP=$(echo $LINE | cut -d ':' -f 1)
    QUERY=$(echo $LINE | cut -d ':' -f 2)
    echo $MAP
    # run twice to generate references
    ./maps/mkmap.sh $MAP $QUERY | ./maps/map_to_tex.py > maps/$MAP.tex
done < maps/maps.txt

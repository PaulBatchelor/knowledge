while read -r LINE
do
    MAP=$(echo $LINE | cut -d ':' -f 1)
    echo $MAP
    cd maps; pdftex $MAP; cd -
done < maps/maps.txt

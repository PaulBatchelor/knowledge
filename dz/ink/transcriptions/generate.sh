TOOLPATH=../../../tools
while read -r LINE
do
    NAMESPACE=$(echo $LINE | cut -f 1 -d ' ')
    FILE=$(echo $LINE | cut -f 2 -d ' ')
    OUTPUT=$(echo $LINE | cut -f 3 -d ' ')
    FIGS=$(echo $LINE | cut -f 4 -d ' ')
    $(cd transcriptions && $TOOLPATH/gparse/gparse $NAMESPACE $FILE > ../$OUTPUT)
    if [ -f "transcriptions/$FIGS" ]
    then
        ./transcriptions/mkfigs.sh transcriptions/$FIGS $NAMESPACE >> ../$OUTPUT
    fi

done < transcriptions/graphs.txt

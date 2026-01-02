TOOLPATH=../../../tools
while read -r LINE
do
    NAMESPACE=$(echo $LINE | cut -f 1 -d ' ')
    FILE=$(echo $LINE | cut -f 2 -d ' ')
    OUTPUT=$(echo $LINE | cut -f 3 -d ' ')
    $(cd transcriptions && $TOOLPATH/gparse/gparse $NAMESPACE $FILE > ../$OUTPUT)
done < transcriptions/graphs.txt

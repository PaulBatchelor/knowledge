if [ "$#" -lt 1 ]
then
    echo "usage: $0 INKPATH"
    exit 1
fi

INKPATH=$1

awk -f $INKPATH/2025/generate.awk $INKPATH/2025/bins.txt > 2025.dz

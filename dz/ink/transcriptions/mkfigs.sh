TOOLPATH=../../tools

if [ "$#" -lt 2 ]
then
    echo "Usage: dagdraw figs.txt namespace"
    exit 1
fi

FIGS=$1
NAMESPACE=$2
DAGDRAW_PATH=$TOOLPATH/dagdraw
dagdraw() {
./$DAGDRAW_PATH/fig.awk transcriptions/$1/$1.fig |\
    ./$DAGDRAW_PATH/dagdraw |\
    ./$DAGDRAW_PATH/draw.awk |\
    ./$DAGDRAW_PATH/bitr - | magick - figs/$2.png
echo "nn $2"
echo "at fig figs/$2.png"
}

mkdir -p figs
echo "ns $NAMESPACE"
while read -r LINE
do
    dagdraw $LINE
done < $FIGS


TOOLPATH=../../tools

if [ "$#" -lt 2 ]
then
    echo "Usage: dagdraw figs.txt namespace"
    exit 1
fi

FIGS=$1
NAMESPACE=$2
DAGDRAW_PATH=$TOOLPATH/dagdraw
FIGOUT=figs

dagdraw() {
FIGPATH=$FIGOUT/$2
PNG=$FIGPATH.png
EPS=$FIGPATH.eps
./$DAGDRAW_PATH/fig.awk transcriptions/$1/$1.fig |\
    ./$DAGDRAW_PATH/dagdraw |\
    ./$DAGDRAW_PATH/draw.awk |\
    ./$DAGDRAW_PATH/bitr - | magick - $PNG
./$DAGDRAW_PATH/fig.awk transcriptions/$1/$1.fig |\
    ./$DAGDRAW_PATH/dagdraw |\
    ./$DAGDRAW_PATH/draw.awk |\
    ./$DAGDRAW_PATH/vectr $EPS
# dimmensions are needed to get consistent printing
# results in TeX (converted to DPI later)
DIMS=$(magick identify $PNG | cut -d ' ' -f 3)
WIDTH=$(echo $DIMS | cut -d 'x' -f 1)
HEIGHT=$(echo $DIMS | cut -d 'x' -f 2)
echo "nn $2"
echo "at fig $FIGPATH"
echo "at figw $WIDTH"
echo "at figh $HEIGHT"
echo "at pg $1"
}

mkdir -p figs
echo "ns $NAMESPACE"
while read -r LINE
do
    dagdraw $LINE
done < $FIGS


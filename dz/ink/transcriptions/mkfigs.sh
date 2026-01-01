TOOLPATH=../../tools

DAGDRAW_PATH=$TOOLPATH/dagdraw
dagdraw() {
./$DAGDRAW_PATH/fig.awk transcriptions/$1/$1.fig |\
    ./$DAGDRAW_PATH/dagdraw |\
    ./$DAGDRAW_PATH/draw.awk |\
    ./$DAGDRAW_PATH/bitr figs/$1.pbm
}

mkdir -p figs
while read -r LINE
do
    dagdraw $LINE
done < transcriptions/figs.txt


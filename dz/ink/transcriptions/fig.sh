DAGDRAW_PATH=../../../../tools/dagdraw
./$DAGDRAW_PATH/fig.awk $1.fig | ./$DAGDRAW_PATH/dagdraw | ./$DAGDRAW_PATH/draw.awk | ./$DAGDRAW_PATH/bitr $1.pbm

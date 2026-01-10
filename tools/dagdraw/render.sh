render1() {
    ./dagdraw < $1.txt | ./draw.awk | ./bitr $1.pbm
}

render2() {
    ./fig.awk $1.txt | ./dagdraw | ./draw.awk | ./bitr $1.pbm
}

render3() {
    #./fig.awk $1.txt | ./dagdraw | ./draw.awk | ./bitr - | magick - $1.png
    ./fig.awk $1.txt | ./dagdraw | ./draw.awk | ./vectr $1.eps
}

# render1 ex2
# render1 ex1
# render2 ex3
# render2 ex4
render3 ex4

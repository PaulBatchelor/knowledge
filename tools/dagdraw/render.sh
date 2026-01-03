render1() {
    ./dagdraw < $1.txt | ./draw.awk | ./bitr $1.pbm
}

render2() {
    ./fig.awk $1.txt | ./dagdraw | ./draw.awk | ./bitr $1.pbm
}

render1 ex2
render1 ex1
render2 ex3
render2 ex4

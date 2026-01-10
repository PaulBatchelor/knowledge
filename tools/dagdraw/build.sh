# gcc -g -Wall -pedantic -std=c89 dagdraw.c -o dagdraw
# gcc -g -Wall -pedantic -std=c89 bitr.c -o bitr
gcc -g -I /opt/homebrew/include/cairo -L/opt/homebrew/lib -Wall -pedantic -std=c89 vectr.c -o vectr -lcairo

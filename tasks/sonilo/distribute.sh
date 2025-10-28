# if [ "$#" -lt 3 ]
# then
#     echo "Usage: $0 tasks.txt days out.txt"
#     exit 1
# fi

# TASKS=$1
# DAYS=$2
# OUT=$3

TASKS=tasks.txt
DAYS=70
OUT=schedule.txt

NTASKS=$(wc -l $TASKS | cut -d ' ' -f 1)

awk -f distribute.awk -vNDAYS=$DAYS -vNTASKS=$NTASKS $TASKS > $OUT

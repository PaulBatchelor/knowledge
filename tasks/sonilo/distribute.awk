BEGIN {
    TASKS_PER_DAY=NDAYS/NTASKS
    DAY=0
}
{
    print $1":"int(DAY*TASKS_PER_DAY)
    DAY++
}

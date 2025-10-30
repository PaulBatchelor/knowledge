/^!task / {
    prefix = "tasks/META/"
    task = prefix $2
    start = task "_start"
    end = task "_end"
    nn = "nn "
    co = "co "
    to = " "

    print nn start
    print nn end
    print nn task
    print co start to end
    print co start to task
    print co end to task
}

/^!connect / {
    prefix = "tasks/META/"
    task = prefix $2
    start = "?" task "_start"
    end = "?" task "_end"
    co = "co "
    to = " "
    this = "$"
    print co start to this
    print co this to end
}

/^!seq / {
    prefix = "tasks/META/"
    task1 = $2
    task2 = $3
    start = prefix task2 "_start"
    end = prefix task1 "_end"
    co = "co "
    to = " "
    print co end to start
}

/^!node / {
    node = $2
    nn = "nn "
    this = "$"
    to = " "
    print nn node
    if (prev != "") {
        print co prev to this
    }
    prev = node
}

/^!clear/ {
    prev = ""
}

/^nn|^ln|^co|^ns|^gr|^gr/ { print $0 }

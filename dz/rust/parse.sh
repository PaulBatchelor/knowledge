if [ "$#" -lt 1 ]

then
    echo "Usage: $0 <module-name>"
    exit 1
fi

NAME=$1

../../tools/htmlparse/htmlparse \
    scratch.html \
    $NAME \
    https://doc.rust-lang.org/std/$NAME |\
    iconv -f utf-8 -t ascii//translit > std/$NAME.dz

if [ $# -eq 1 ] && [ -f $1 ]; then
    echo "Creating a space-delimited version of $1 ..."
    cat "$1" | tr -s "," " " >> "$1.ssv"

elif [ ! $# -eq 1 ] && [ -f $1 ]; then
    echo "Error- please input ONE file."
    exit

elif [ $# -eq 1 ] && [ ! -f $1 ]; then
    echo "Error- input must be a file."
    
fi

echo "Done!"


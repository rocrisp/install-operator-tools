#echo "Get Operator status"

#echo "From source of truth $1"
status=$(grep "$2" $1)

if [[ $RETRY == "YES" ]]; then
   if [[ "$status " =~ (no:) ]]; then
      echo "Found"
   else echo "Notfound"
   fi
else
    if [[ "$status " =~ (yes:|no:) ]]; then
       echo "Found"
    else echo "Notfound"
    fi
fi
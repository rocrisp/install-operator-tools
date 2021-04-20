#echo "Get Operator status"

#echo "From source of truth $1"
status=$(grep "$2" $1)
#echo "status is $status"
if [[ "$status " =~ (yes|no) ]]; then
   echo "Found"
else echo "Notfound"
fi
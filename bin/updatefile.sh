#permission to execute for everyone
echo "Update Source of Truth"
echo "file is $1"

#update the file
echo " adding $2 $3 $4"
sed -i '.backup' "s/.*$2.*/$2:$3:$4/w changelog.txt" $1
echo $?

if [ -s changelog.txt ]; then
    echo "Changes made."
else
    echo "$2 not found, adding a new operator."
    echo "$2:${3:+$3}:${4:+$4}" >> $1
fi
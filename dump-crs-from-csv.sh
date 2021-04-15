#/bin/bash

CSV=$1
IDX=$(expr $2 - 1) # let 2nd argument be the number of CRs to extract, minus 1 since we count from zero in the CSV

if [ -z "$CSV" ] || [ -z "$2" ]; then
	echo -e "ERROR: Not enough arguments. Exiting..."
	echo -e "Usage:"
	echo -e "  $(basename $0) <csv_file> <cr_count>"
	exit 1
fi

if [ ! $(which ./yq 2>/dev/null) ]; then
	echo -e "ERROR: yq not found. Exiting..."
	exit 2
fi

if [ ! $(which ./jq 2>/dev/null) ]; then
	echo -e "ERROR: jq not found. Exiting..."
	exit 4
fi

mkdir -p crs/
#yq eval '.metadata.annotations.alm-examples' $CSV | jq .[0]
for i in $(seq 0 $IDX); do ./yq eval '.metadata.annotations.alm-examples' $CSV | jq .[$i] > crs/cr$i.yml; done

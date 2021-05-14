#!/bin/bash

counter=1
inputfile=$1

#add array hearder to the json file
##{
#"operators": [

while IFS= read -r line; do 
    #gpu-operator-certified:13-05-2021-13-15-58:yes:yes:13-05-2021-13-17-06:comment
    
    echo "text read from file: $line"
    operator_name=$(echo $line| cut -d':' -f1)
    operator_starttime=$(echo $line| cut -d':' -f2)
    operator_status=$(echo $line| cut -d':' -f3)
    operand_status=$(echo $line| cut -d':' -f4)
    operator_endtime=$(echo $line| cut -d':' -f5)
    #optional
    operator_comment=$(echo $line| cut -d':' -f6)

    echo "Counter is $counter"
    echo "Operator Name is $operator_name"
    echo "Operator Starttime is $operator_starttime"
    echo "Operator Status is $operator_status"
    echo "Operand Status is $operand_status"
    echo "Operator endtime is $operator_endtime"
    echo "Operator comment is $operator_comment"

    #     {
    #     id: $t1 ,  
    #     name: $t2 ,
    #     starttime: $t3 ,
    #     endttime: $t4 ,
    #     install: $t5 ,
    #     comment: $t7 ,
    #     operand: [
    #         { install: $t6}
    #     ]
    #     }

   jq -n --argjson t1 $counter \
        --arg t2 $operator_name \
        --arg t3 $operator_starttime \
        --arg t4 $operator_endtime \
        --argjson t5 $operator_status \
        --argjson t6 $operand_status \
        --arg t7 "$operator_comment" \
        -f /opt/operator/bin/template.json >> $inputfile.temp.json
((counter++))
done < $inputfile

#slurp the object to make it json arrays
jq -s . $inputfile.temp.json > $inputfile.json

#remove temporary file
rm $inputfile.temp.json
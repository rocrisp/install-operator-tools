counter=1
inputfile=../operatorlist/$1

#add array hearder to the json file
##{
#"operators": [

while IFS= read -r line; do 
    # echo $counter
    # echo "text read from file: $line"
    operator_name=$(echo $line| cut -d':' -f1)
    operator_status=$(echo $line| cut -d':' -f2)
    operand_status=$(echo $line| cut -d':' -f3)
    # echo "Operator Name is $operator_name"
    # echo "Operator Status is $operator_status"
    # echo "Operand Status is $operand_status"

#     {
#     id: $t1 ,  
#     name: $t2 ,
#     starttime: $t3 ,
#     endttime: $t4 ,
#     install: $t5 ,
#     operand: [
#         { install: $t6}
#     ]
#     }

   jq -n --arg t1 $counter \
        --arg t2 $operator_name \
        --arg t3 "starttime" \
        --arg t4 "endtime" \
        --arg t5 $operator_status \
        --arg t6 $operand_status \
        -f template.json >> $inputfile.temp.json

((counter++))
done < $inputfile
#slurp the object to make it json arrays
jq -s . $inputfile.temp.json > $inputfile.json
echo "Source of Truth : $1"

total=$(cat $1 | wc -l)
echo "Total number of Certified Operators :                                          $total"

tested=$(grep -E 'yes:yes|yes:no|no:|yes' $1 | wc -l)
success=$(grep -E 'yes:yes' $1 | wc -l)
failed_operand=$(grep -E "yes:no" $1 | wc -l)
failed=$(grep -E "no:" $1 | wc -l)


echo "Total number of Operator tested :                                              $tested"
echo "Total number of succesfully installed Operator and Operand :                   $success"
echo "Total number of succesfully installed Operator but operand failed to install : $failed_operand"
echo "Total number of Operator failed to install:                                    $failed"

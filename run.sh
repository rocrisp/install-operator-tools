#cat package.yaml | yq '.channels[] | {name} | .[]'
export OO_INSTALL_NAMESPACE="!create"
export OO_TARGET_NAMESPACES="!all"
export OO_INDEX="registry.redhat.io/redhat/certified-operator-index:v4.7"
export ARTIFACT_DIR="artifact_dir"
export SHARED_DIR="shared_dir"
i=0
for file in $(find $PWD/$1 -name 'package.yaml'); 
do 
	echo $file;
	export OO_PACKAGE=$(cat $file | yq '.packageName' | sed -e 's/^"//' -e 's/"$//');
	echo $OO_PACKAGE;
	#key=$(echo $OO_PACKAGE | cut -d'-' -f1);
	#echo 'operator name' $key
	export OO_CHANNEL=$(cat $file | yq '.channels[] | {name} | .[]' | sed -e 's/^"//' -e 's/"$//');
	echo $OO_CHANNEL;
	#currentCSV=$(cat $file | yq '.channels[] | {currentCSV} | .[]' | sed -e 's/^"//' -e 's/"$//');
	#echo 'cvs' $currentCSV
	#csvdir=$(echo $currentCSV | cut -d'.' -f2- | sed 's/v//');
	#echo 'remove the v' $csvdir
	#found=$(find $PWD/$1/$OO_PACKAGE/ -name *.clusterserviceversion.yaml | wc -l);
        #if [[ $found -eq 1 ]]; then
        #   echo "$OO_PACKAGE" >> one.txt
        #else
	#   echo "$OO_PACKAGE" >> other.txt
	#fi
	#csvfile=$(find . -name *$key*$csvdir*.clusterserviceversion.yaml);
	#echo $found
        #echo $csvfile	
        #echo $'--------------------\n'
        #echo $csvfile
	#break
        #cat $csvfile | yq '.spec | {installModes} | .[] | .[] | {supported}'
	#break	
	./subscribe-command-v2.sh
	
	status=$?
        echo "Output rc = " $status	
	if [[ $status -ne 0 ]]; then
		export OO_TARGET_NAMESPACES="!install"
		echo "Run the command again with OO_TARGET_NAMESPACES = $OO_TARGET_NAMESPACES"
		./subscribe-command-v2.sh
	fi
        
	echo $'--------------------\n'

	((i++))
	if [[ $i -eq 10 ]]; then
		echo "Counter : " $i
	        break
	fi	
done

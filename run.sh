export OO_INSTALL_NAMESPACE="!create"
export OO_INDEX="registry.redhat.io/redhat/certified-operator-index:v4.7"
export ARTIFACT_DIR="artifact_dir"
export SHARED_DIR="shared_dir"

counter=1
for file in $(find $PWD/$1 -name 'package.yaml'); 
do 
	echo $file;
        csvpath="$(dirname "${file}")"

	if [[ $file == *"mongodb-enterprise"* ]] ||
           [[ $file == *"aqua-operator-certified"* ]] ||
           [[ $file == *"stonebranch-universalagent-operator-certified"* ]] ||
           [[ $file == *"nvmesh-operator"* ]] ||
           [[ $file == *"anzograph-operator"* ]] ||
           [[ $file == *"cic-operator-with-crds"* ]] ||
           [[ $file == *"anzo-operator"* ]]; then
	   continue
	fi
        # yq eval .packageName /Users/rosecrisp/test/manifests-616344862//tf-operator/tf-operator-9gd6l17v/package.yaml
        export OO_PACKAGE=$(yq eval '.packageName' $file);
       
        #currentCSV=$(yq eval '.channels.[].currentCSV' $file);
        #echo "Current CSV = $currentCSV"


        defaultChannel=$(yq eval '.defaultChannel' $file)

        currentCSV=$(cat $file | grep -A1 "name: ${defaultChannel}" | grep currentCSV | awk '{ print $2 }');
        echo "currentCVS for $defaultChannel is $currentCSV"

        csvdir=$(echo $currentCSV | cut -d'.' -f2- | sed 's/v//');

        countfiles=0
        for csvfile in $(find $csvpath/$csvdir -name '*.clusterserviceversion.yaml');
        do
           echo 'Found the file!!!'
           echo $csvfile;
           #yq eval '.spec.installModes[] | select(.type == "AllNamespaces") | .supported'
           export AllNamespaces=$(yq eval '.spec.installModes[] | select(.type == "AllNamespaces") | .supported' $csvfile)
           echo "AllNamespaces = $AllNamespaces"
           (( countfiles++ ))
        done

        if [[ $countfiles > 1 ]] 
        then 
           echo "found more than one cvs file"
        fi
    
        if [[ $AllNamespaces == "false" ]]; then
           #set 
           export OO_TARGET_NAMESPACES="!install"
        else
           export OO_TARGET_NAMESPACES="!all"
        fi

        export OO_CHANNEL=$defaultChannel;
	echo "print ENV"
        echo "OO_TARGET_NAMESPACES = $OO_TARGET_NAMESPACES"
        echo "OO_PACKAGE = $OO_PACKAGE"
        echo "OO_CHANNEL == $OO_CHANNEL"


        echo "------------------------------------"
        echo "Installing Operator $OO_PACKAGE"
        echo $'----------------------------\n'	
        output=$(./subscribe-command-v2.sh)
        echo $output
        
        if [[ $output == *"Timed out waiting for csv to become ready"* ]]; then
           echo $'------------------\n' >> failed.txt
           echo $OO_PACKAGE >> failed.txt
           echo $output2 >> failed.txt
           echo $'------------------\n' >> failed.txt

	elif [[ $output == *"ClusterServiceVersion \"$currentCSV\" ready"* ]]; then
            echo "Success Installing $counter $OO_PACKAGE" >> success.txt
        else
           echo $OO_PACKAGE $output >> failed.txt
           echo $'------------------\n' >> failed.txt  
        fi
        ((counter++))

done

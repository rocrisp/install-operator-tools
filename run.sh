export OO_INDEX="registry.redhat.io/redhat/certified-operator-index:v4.7"
export ARTIFACT_DIR="artifact_dir"
export SHARED_DIR="shared_dir"
export CR_YML="crs/cr0.yml"
export RUNOPERAND="true"
export SOURCEOFTRUTH="operatorlist.txt"

#yq for local testing
#export YQ="yq"
#yq for jenkins server
export YQ="./yq"

counter=1

##initiate files

rm -f success_operator.txt
rm -f success_operand.txt
rm -f failed_operator.txt
rm -f failed_operand.txt

if [[ "$#" -eq 0 ]]; then
    echo "<Please enter the directory path to the package.yml>"
    exit;
 fi

if [[ $2 == "-nooperand" ]]; then
   export RUNOPERAND="false"
fi

echo "Install Operand : $RUNOPERAND"

echo "Run find $PWD/$1 -name '*package.yaml' | sort -n"

for file in $(find $PWD/$1 -name '*package.yaml' | sort -n); 
#for file in $(cat test-inputfile.txt);
do 
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        
        csvpath="$(dirname "${file}")"

        # yq eval .packageName /Users/rosecrisp/test/manifests-616344862//tf-operator/tf-operator-9gd6l17v/package.yaml
        export OO_PACKAGE=$($YQ eval '.packageName' $file);
        echo ""
        echo "--------------$counter----------------------"
        echo "Installing Operator $OO_PACKAGE"
        echo "Start time : ${dt}"
        echo $'--------------------------------------\n'	
        echo "Package.yaml :"
        echo $file;

        if      [[ $file == *"mongodb-enterprise"* ]] ||
                [[ $file == *"aqua-operator-certified"* ]] ||
                [[ $file == *"stonebranch-universalagent-operator-certified"* ]] ||
                [[ $file == *"nvmesh-operator"* ]] ||
                [[ $file == *"anzograph-operator"* ]] ||
                [[ $file == *"cic-operator-with-crds"* ]] ||
                [[ $file == *"data-explorer-operator-certified"* ]] ||
                [[ $file == *"anzo-operator"* ]]; then
                echo "skip $OO_PACKAGE. Problem installing. Skip it."
                ((counter++))
                continue
        fi
        
        echo "Run ./status.sh $SOURCEOFTRUTH $OO_PACKAGE"
        operator_status=$(./status.sh $SOURCEOFTRUTH $OO_PACKAGE)

        if [[ $operator_status == "Found" ]]; then
           echo "skip $OO_PACKAGE. Already installed"
           ((counter++))
           continue
        fi

        defaultChannel=$($YQ eval '.defaultChannel' $file)
        export OO_CHANNEL=$defaultChannel;

        currentCSV=$(cat $file | grep -A1 "name: ${defaultChannel}" | grep currentCSV | awk '{ print $2 }');
        
        ##do this if the format is different
        if [[ -z "$currentCSV" ]]; then
           currentCSV=$($YQ eval '.channels[].currentCSV' $file)
        fi

        echo "currentCSV for defaultChannel $defaultChannel : $currentCSV"
        csvdir=$(echo $currentCSV | cut -d'.' -f2- | sed 's/v//');

        csvfile=$(find $csvpath/$csvdir -name '*.clusterserviceversion.yaml');
        
        #do this if csvfile is on the same path as the package.yaml
        if [[ -z "$csvfile" ]]; then
           echo "file not found in $csvdir"
           csvfile=$(find $csvpath -name "$currentCSV.clusterserviceversion.yaml");
        fi

        echo "clusterserviceversion.yml : $csvfile"
        
        export AllNamespaces=$($YQ eval '.spec.installModes[] | select(.type == "AllNamespaces") | .supported' $csvfile)
        echo "installModes.AllNamespaces = $AllNamespaces"
        
        #Setup cr file
        ./dump-crs-from-csv.sh $csvfile 1
        

        if [[ $AllNamespaces == "false" ]]; then
                #set OO_TARGET_NAMESPACES
                export OO_TARGET_NAMESPACES="!install"
        else
                export OO_TARGET_NAMESPACES="!all"
        fi

        ##find metadata.namespace per
        #manifests-616344862/instana-agent/instana-agent-z73s1az3/1.0.2/instana-agent-operator.clusterserviceversion.yaml
        #Replace namaspace with cr.namespace
        #yq eval '.metadata.annotations.alm-examples' $csvfile | jq .[].metadata.namespace
        echo "cr_yaml is $CR_YML"
        cr_namespace=$($YQ eval '.metadata.namespace' $CR_YML)
        echo "metadata.namespace = $cr_namespace"
        if [[ $cr_namespace == *"null"* ]]; then
                echo "namespace is NOT in cr, so set OO_INSTALL_NAMESPACE to !create otherwise set it to the namespace"
                export OO_INSTALL_NAMESPACE="!create"
        else
                echo "namespace IS defined in cr."
                export OO_INSTALL_NAMESPACE="$cr_namespace"

        fi

        echo "OO_INSTALL_NAMESPACE = $OO_INSTALL_NAMESPACE"
        echo "OO_TARGET_NAMESPACES = $OO_TARGET_NAMESPACES"
        echo "OO_PACKAGE = $OO_PACKAGE"
        echo "OO_CHANNEL = $OO_CHANNEL"
        
        echo "Run ./subscribe-command.sh"
        
        error_file="errorfile.txt"
        output=$(./subscribe-command.sh 2>$error_file)
        err=$(< $error_file)
        rm $error_file

        echo "$output"
        echo "-------------------"
        echo "$err"

        if [[ $output == *"Timed out waiting for csv to become ready"* ]]; then
                echo $'------------------\n' >> failed_operator.txt
                echo "Failed to install operator:$counter $OO_PACKAGE" >> failed_operator.txt
                echo "$output" >> failed_operator.txt
                echo $'------------------\n' >> failed_operator.txt
                echo "Run ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE no"
                ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE no

        elif [[ $output == *"ClusterServiceVersion \""*"\" ready"* ]]; then
                echo "Success installed operator:$counter $OO_PACKAGE" >> success_operator.txt

                #update source of truth
                echo "Run ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes"
                ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes
                
                if  [[ $RUNOPERAND == "true" ]]; then

                        ###Did the operand Installed siccessfully ?
                        if [[ $output == *"Operand RC = 0"* ]]; then
                           echo "Successfully installed operand for $counter $OO_PACKAGE" >> success_operand.txt
                           echo "Run ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes yes"
                           ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes yes
                        else 
                           echo "Failed to install operand for $counter $OO_PACKAGE" >> failed_operand.txt
                           echo "$err" >> failed_operand.txt
                           echo "Run ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes no"
                           ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE yes no
                        fi
                fi
        else
                echo "Run ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE no"
                ./updatefile.sh $SOURCEOFTRUTH $OO_PACKAGE no no
                echo $OO_PACKAGE >> failed_operator.txt
                echo "$output" >> failed_operator.txt
                echo $'------------------\n' >> failed_operator.txt  
        fi

        ((counter++))
        echo "--------------------------------------"
        echo "Finish Installing Operator $OO_PACKAGE"
        echo $'--------------------------------------\n'

done

display_help() {
    # taken from https://stackoverflow.com/users/4307337/vincent-stans
    echo "Usage: $0 <Enter the directory path to the package.yaml>" >&2
    exit 1
}


#!/bin/bash
#export vars
cat /opt/operator/vars.sh
source /opt/operator/vars.sh

# generate manifests from appregistry namespace
offline-cataloger generate-manifests "certified-operators"
export INSTALL_MANIFEST_DIRECTORY="$(find . -maxdepth 1 -type d -name manifests-* -printf '%T@ %p\n' | sort -nr | awk 'NR==1{print $2}')"

echo print vars
env | grep OO_
env | grep INSTALL

#create file if it doesn't exist
if [[ ! -e operatorlist/$INSTALL_SOURCEOFTRUTH ]]; then
    mkdir -p operatorlist
    echo "Source-of-truth" > operatorlist/$INSTALL_SOURCEOFTRUTH
fi

#count the number for installs
counter=1

echo "Run find $INSTALL_MANIFEST_DIRECTORY -name '*package.yaml' | sort -n"

for file in $(find $INSTALL_MANIFEST_DIRECTORY -name '*package.yaml' | sort -n); 
do 
        script_starttime=$(date -u '+%Y-%m-%dT-%H-%M-%SZ')
        
        csvpath="$(dirname "${file}")"

        # yq eval .packageName /Users/rosecrisp/test/manifests-616344862//tf-operator/tf-operator-9gd6l17v/package.yaml
        export OO_PACKAGE=$(yq eval '.packageName' $file);
        echo ""
        echo "--------------$counter----------------------"
        echo "Installing Operator $OO_PACKAGE"
        echo "Start time : ${script_starttime}"
        echo $'--------------------------------------\n'	
        echo "Package.yaml : $file"

        if      # Missing in OperatorHub
                [[ $file == *"armo-operator-certified"* ]] ||
                [[ $file == *"cilium"* ]] ||
                [[ $file == *"cortex-operator"* ]] ||
                [[ $file == *"epsagon-operator-certified"* ]] ||
                [[ $file == *"ocean-operator"* ]] ||
                [[ $file == *"newrelic-infrastructure"* ]] ||
                [[ $file == *"erynis-operator"* ]] ||
                [[ $file == *"ubix-operator"* ]] ||
                [[ $file == *"driverlessai-deployment-operator-certified"* ]] ||
                [[ $file == *"gitlab-operator"* ]] ||
                [[ $file == *"trains-operator-certified"* ]] ||
                [[ $file == *"ibm-auditlogging-operator-app"* ]] ||
                [[ $file == *"ibm-helm-api-operator-app"* ]] ||
                [[ $file == *"ibm-helm-repo-operator-app"* ]] ||
                [[ $file == *"ibm-management-ingress-operator-app"* ]] ||
                [[ $file == *"ibm-mongodb-operator-app"* ]] ||
                [[ $file == *"ibm-platform-api-operator-app"* ]] ||
                [[ $file == *"ibm-monitoring-grafana-operator-app"* ]] ||
                [[ $file == *"traefikee-certified"* ]] ||
                [[ $file == *"planetscale-certified"* ]] ||
                [[ $file == *"tidb-operator-certified"* ]]; # TiDB Operator Community exist
                then
                   echo "Skip $OO_PACKAGE with operator had problems installing on a cluster."
                   ((counter++))
                   continue
                
         elif   # Only in Marketplace
                [[ $file == *"open-enterprise-spinnaker"* ]] ||
                [[ $file == *"robin-storage-trial"* ]] || #same as robin-storage-express
                [[ $file == *"robin-storage-express"* ]];
                then
                   echo "Skip $OO_PACKAGE with operator had problems installing on a cluster."
                   ((counter++))
                   continue
                
         elif   #unable to install by automation and manual.
                [[ $file == *"cockroachdb-certified"* ]] || #The default channel is set to beta, but there's new version stable
                [[ $file == *"data-explorer-operator-certified"* ]] ||
                [[ $file == *"twistlock-certified"* ]] || #related to prisma-cloud-compute-console-operator.v2.0.1
                [[ $file == *"prisma-cloud-compute-console-operator.v2.0.1"* ]] ||
                [[ $file == *"presto-operator"* ]];
                then
                   echo "Skip $OO_PACKAGE with operator had problems installing on a cluster."
                   echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE ${operator_starttime}"
                   bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE 0 false false 0 "Skip. Unable to install via automation/manual"
                   ((counter++))
                   continue

         elif   #unable to install by automation, but installed by manual.
                [[ $file == *"cass-operator"* ]] ||
                [[ $file == *"storageos"* ]] || #related to storageos2 which installed.
                [[ $file == *"portshift-operator"* ]] ||
                [[ $file == *"triggermesh-operator"* ]] || #search for triggermesh AWS sources operator popped up
                [[ $file == *"universalagent-operator-certified"* ]] || #unable to install by automation. seems to be connected to stonebranch-universalagent-operator-certified
                [[ $file == *"crunchy-postgres-operator"* ]];                 
                then
                   echo "Skip $OO_PACKAGE with operator had problems installing on a cluster."
                   echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE ${operator_starttime}"
                   bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE 0 true true 0 "Skip. Unable to install via automation. Installed Manually"
                   
                   ((counter++))
                   continue
        fi
        
        echo "Run bin/status.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE"
        operator_status=$(bin/status.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE)

        ### if yes or no is found
        if [[ $operator_status == "Found" && $INSTALL_RETRY == "NO" ]]; then
           echo "Skip $OO_PACKAGE with operator already installed on a cluster"
           ((counter++))
           continue

        ### if no: is found   
        elif [[ $operator_status == "Notfound" && $INSTALL_RETRY == "YES" ]]; then
           echo "Skip $OO_PACKAGE with operator installed successfully on a cluster."
           ((counter++))
           continue

        ### if yes: is found   
        elif [[ $operator_status == "Notfound" && $INSTALL_NEWTEST == "YES" ]]; then
           echo "Skip $OO_PACKAGE with operator NOT installed successfully on a cluster."
           ((counter++))
           continue
        fi

        defaultChannel=$(yq eval '.defaultChannel' $file)
        export OO_CHANNEL=$defaultChannel;

        currentCSV=$(cat $file | grep -A1 "name: ${defaultChannel}" | grep currentCSV | awk '{ print $2 }');
        
        ##do this if the format is different
        if [[ -z "$currentCSV" ]]; then
           currentCSV=$(yq eval '.channels[].currentCSV' $file)
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
        
        export AllNamespaces=$(yq eval '.spec.installModes[] | select(.type == "AllNamespaces") | .supported' $csvfile)
        echo "installModes.AllNamespaces = $AllNamespaces"
        
        #Setup cr file
        echo "Run dump-crs-from-csv.sh $csvfile 1"
        bin/dump-crs-from-csv.sh $csvfile 1

        if [[ $AllNamespaces == "false" ]]; then
                #set OO_TARGET_NAMESPACES
                export OO_TARGET_NAMESPACES="!install"
        else
                export OO_TARGET_NAMESPACES="!all"
        fi

        ##find metadata.namespace per
        echo "cr_yaml is $INSTALL_CR_YML"
        cr_namespace=$(yq eval '.metadata.namespace' $INSTALL_CR_YML)
        echo "metadata.namespace = $cr_namespace"
        if [[ $cr_namespace == *"null"* ]]; then
                echo "namespace is NOT in cr, so set OO_INSTALL_NAMESPACE to !create otherwise set it to the namespace"
                export OO_INSTALL_NAMESPACE="!create"
        else
                echo "namespace IS defined in cr."
                export OO_INSTALL_NAMESPACE="$cr_namespace"

        fi

        echo print vars
        env | grep OO_
        
        echo "Run bin/subscribe-command.sh"
        
        error_file="errorfile.txt"
        
        #track start time
        operator_starttime=$(date -u '+%Y-%m-%dT-%H-%M-%SZ')
        echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE ${operator_starttime}"
        bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE ${operator_starttime} "status" "status" "endtime" ""

        output=$(bin/subscribe-command.sh 2>$error_file)
        err=$(< $error_file)
        rm $error_file

        echo "$output"
        echo "-------------------"
        echo "$err"

        #track end time, note: it's not exact science here
        operator_endtime=$(date -u '+%Y-%m-%dT-%H-%M-%SZ')

        if [[ $output == *"Timed out waiting for csv to become ready"* ]]; then
                echo $'------------------\n' >> failed_operator.txt
                echo "Failed to install operator:$counter $OO_PACKAGE" >> failed_operator.txt
                echo "$output" >> failed_operator.txt
                echo $'------------------\n' >> failed_operator.txt
                echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime false false $operator_endtime"
                bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime false false $operator_endtime ""

        elif [[ $output == *"ClusterServiceVersion \""*"\" ready"* ]]; then
                
                echo "Success installed operator:$counter $OO_PACKAGE" >> success_operator.txt

                #update source of truth
                echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true $operator_endtime"
                bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true status $operator_endtime ""
                
                if  [[ $INSTALL_OPERAND == "yes" ]]; then

                        ###Did the operand Installed siccessfully ?
                        if [[ $output == *"Operand RC = 0"* ]]; then
                           echo "Successfully installed operand for $counter $OO_PACKAGE" >> success_operand.txt
                           echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true true $operator_endtime"
                           bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true true $operator_endtime ""
                        else 
                           echo "Failed to install operand for $counter $OO_PACKAGE" >> failed_operand.txt
                           echo "$err" >> failed_operand.txt
                           echo "Run bin/updatefile.sh operatorlist/$INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true false $operator_endtime"
                           bin/updatefile.sh $INSTALL_SOURCEOFTRUTH $OO_PACKAGE $operator_starttime true false $operator_endtime ""
                        fi
                fi
        else
                echo $OO_PACKAGE >> failed_operator.txt
                echo "$output" >> failed_operator.txt
                echo $'------------------\n' >> failed_operator.txt  
        fi

        ((counter++))
        echo "--------------------------------------"
        echo "Finish Installing Operator $OO_PACKAGE"
        echo $'--------------------------------------\n'

done
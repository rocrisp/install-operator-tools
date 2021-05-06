#Prereqquisite 
k8s cluster available

#Before begin the test, you need to generates manifests from appregistry namespace

#For mac:
mac/offline-cataloger generate-manifests "certified-operators"

#For Linux:
linux/offline-cataloger generate-manifests "certified-operators"

#edit vars.sh to add your operatorlist filename and the manifest-xxx directory generated from offline-cataloger

#How to run Test

bin/run.sh
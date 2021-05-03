#Prereqquisite 
k8s cluster available

#edit vars.sh to add your operatorlist filename

#Before begin the test, you need to generates manifests from appregistry namespace

#For mac:
mac/offline-cataloger generate-manifests "certified-operators"

#For Linux:
linux/offline-cataloger generate-manifests "certified-operators"

#How to run Test

bin/run.sh manifest-directory

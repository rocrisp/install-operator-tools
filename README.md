#Prereqquisite 
k8s cluster available

#Before begin the test, you need to generates manifests from appregistry namespace

#From mac
mac/offline-cataloger generate-manifests "certified-operators"

#From Linux
linux/offline-cataloger generate-manifests "certified-operators"

#How to run Test

#mac
bin/run.sh <manifest-directory>

#linux
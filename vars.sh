##
#Don't need to change these vars
export OO_INDEX="registry.redhat.io/redhat/certified-operator-index:v4.7"
export ARTIFACT_DIR="artifact_dir"
export SHARED_DIR="shared_dir"
export INSTALL_CR_YML="crs/cr0.yml"
export RUNOPERAND="yes" # change it to no if you don't want to install operand.

#options
export INSTALL_SOURCEOFTRUTH="operatorlist_4.7.8.txt" #operatorlist
export INSTALL_RUNOPERAND="false" # install operands
export INSTALL_RETRY="yes"  # re-install operators which have failed.
export INSTALL_NEWTEST="no" # Run All test again 
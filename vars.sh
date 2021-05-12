##
#Don't need to change these vars
export OO_INDEX="registry.redhat.io/redhat/certified-operator-index:v4.7"
export ARTIFACT_DIR="artifact_dir"
export SHARED_DIR="shared_dir"
export INSTALL_CR_YML="crs/cr0.yml"

#options
export INSTALL_SOURCEOFTRUTH="operatorlist_4.7.8" #operatorlist
export INSTALL_OPERAND="yes" # install operands
export INSTALL_RETRY="yes"  # re-install operators which have failed.
export INSTALL_NEWTEST="no" # Run All test again
export INSTALL_FOO="yes"
export INSTALL_MANIFEST_DIRECTORY="placeholder"

# Options
export INSTALL_OPERAND=${INSTALL_OPERAND:-"yes"} # install operands
export INSTALL_RETRY=${INSTALL_RETRY:-"yes"} # re-install operators which have failed.
export INSTALL_NEWTEST=${INSTALL_NEWTEST:-"no"} # Run All test again

# Don't need to change these vars
export OO_INDEX=${OO_INDEX:-"registry.redhat.io/redhat/certified-operator-index:v4.7"}
export ARTIFACT_DIR=${ARTIFACT_DIR:-"artifact_dir"}
export SHARED_DIR=${SHARED_DIR:-"shared_dir"}
export INSTALL_CR_YML=${INSTALL_CR_YML:-"crs/cr0.yml"}

export INSTALL_SOURCEOFTRUTH=${INSTALL_SOURCEOFTRUTH:-"results.txt"} #operatorlist

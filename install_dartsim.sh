#!/usr/bin/env bash
############################################################################
# This script installs the DART simulator in a catkin workspace. To use    #
# along with another workspace, use the catkin config --extend options on  #
# that workspace to extend the DART workspace, and be sure to source the   #
# DART workspace in your bashrc *after* you source your own workspace.     #
#                                                                          #
############################################################################

DART_VERSION="latest"	     
INSTALL_DART_OPTIONAL=true  # Install optional Dart dependencies with apt
INSTALL_DEPENDENCIES=true   # Install dependencies with apt (recommended)

AVAILABLE_DART_VERSIONS=(
    5.1
    latest
)

# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/dart_ws"


# You shouldn't need to edit below this line
#===============================================================================#



#-------------------------------------------------------------------------------#
# Create the catkin workspace (or bail if it already exists)                    #
#-------------------------------------------------------------------------------#
if [ -d "$WORKSPACE_PATH" ] ; then
    echo -e "\nThe directory $WORKSPACE_PATH already exists. Exiting.\n"
    exit 1
fi

mkdir -p ${WORKSPACE_PATH}/src
cd ${WORKSPACE_PATH}/src


#-------------------------------------------------------------------------------#
# Install dependencies                                                          #
#-------------------------------------------------------------------------------#
if [ "$INSTALL_DEPENDENCIES" = true ] ; then
    PACKAGES+=" build-essential cmake pkg-config git"
    PACKAGES+=" libeigen3-dev libassimp-dev libccd-dev"
    if [ "$DART_VERSION" = "5.1" ] ; then
        PACKAGES+=" libfcl-0.5-dev"
	PACKAGES+=" libxi-dev libxmu-dev freeglut3-dev"
	PACKAGES+=" libflann-dev libboost-all-dev"
	PACKAGES+=" libtinyxml-dev libtinyxml2-dev"
	PACKAGES+=" liburdfdom-dev liburdfdom-headers-dev"
	if [ "$INSTALL_DART_OPTIONAL" = true ] ; then
	    PACKAGES+=" libbullet-dev libnlopt-dev coinor-libipopt-dev"
	fi
    elif [ "$DART_VERSION" = "latest" ] ; then
	PACKAGES+=" libboost-regex-dev libboost-system-dev"
	PACKAGES+=" libopenscenegraph-dev"
	if [ "$INSTALL_DART_OPTIONAL" = true ] ; then
	    PACKAGES+=" libbullet-dev libnlopt-dev coinor-libipopt-dev"
	    PACKAGES+=" libode-dev liboctomap-dev libflann-dev"
	    PACKAGES+=" libtinyxml2-dev liburdfdom-dev"
	    PACKAGES+=" libxi-dev libxmu-dev freeglut3-dev"
	fi
    else
	echo "Unknown DART version: $DART_VERSION"
    fi
    
    sudo apt update
    sudo apt install $PACKAGES
fi


#-------------------------------------------------------------------------------#
# Clone the repositories at the necessary branches                              #
#-------------------------------------------------------------------------------#
if [ "$DART_VERSION" = "5.1" ] ; then
    git clone https://github.com/dartsim/dart.git -b release-5.1
elif [ "$DART_VERSION" = "latest" ] ; then
    git clone https://github.com/dartsim/dart.git -b master
fi


#-------------------------------------------------------------------------------#
# Initialize the catkin workspace and run the build                             #
#-------------------------------------------------------------------------------#
cd ${WORKSPACE_PATH}
catkin init
catkin build

source ${WORKSPACE_PATH}/devel/setup.bash

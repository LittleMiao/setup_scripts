#!/usr/bin/env bash
############################################################################
#                                                                          #
# This script builds Gazebo8 with ROS integration and DART5 from source    #
# using catkin. Set the options below to specify which components should   # 
# be installed and whether or not you want to try to install dependencies. #
#                                                                          #
# A catkin workspace will be created in the path WORKSPACE_PATH specified  #
# below. The script will pull the repositories and build the code. Once it #
# is finished running, you can source the setup.bash and/or add it to your #
# ~/.bashrc file, e.g (renaming the path to specified WORKSPACE_PATH):     #
#                                                                          #
#     source $HOME/gazebo_dart_ws/devel/setup.bash                         #
#
# Check that it worked by running:
#
#     $ which gazebo
#
# It should point to the version in the devel path of the catkin
# workspace created by this script. You can then try:
#
#     $ gazebo -e dart
#
# You should see a Gazebo GUI pop up. In the left-side panel, click
# 'Physics
#                                                                          #
############################################################################

INSTALL_GAZEBO=true         # Install Gazebo8 from source
INSTALL_GAZEBO_ROS=true     # Install gazebo_ros_pkgs from source
INSTALL_DART=true           # Install Dart5 from source (Gazebo+DART physics)
INSTALL_DART_OPTIONAL=true  # Install optional Dart dependencies with apt
INSTALL_DEPENDENCIES=true   # Install dependencies with apt (recommended)

# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/gazebo_dart_ws"


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
# Install dependencies only for the packages specified to be installed          #
#-------------------------------------------------------------------------------#
if [ "$INSTALL_DEPENDENCIES" = true ] ; then
    
    PACKAGES=""

    if [ "$INSTALL_DART" = true ] ; then
	PACKAGES+=" build-essential cmake pkg-config git"
	PACKAGES+=" libeigen3-dev libassimp-dev libccd-dev libfcl-0.5-dev"
	PACKAGES+=" libxi-dev libxmu-dev freeglut3-dev"
	PACKAGES+=" libflann-dev libboost-all-dev"
	PACKAGES+=" libtinyxml-dev libtinyxml2-dev"
	PACKAGES+=" liburdfdom-dev liburdfdom-headers-dev"
	if [ "$INSTALL_DART_OPTIONAL" = true ] ; then
	    PACKAGES+=" libbullet-dev libnlopt-dev coinor-libipopt-dev"
	fi
    fi
    if [ "$INSTALL_GAZEBO" = true ] ; then
	PACKAGES+=" libtar-dev libfreeimage-dev libignition-math3-dev"
	PACKAGES+=" libignition-transport3-dev protobuf-compiler libprotoc-dev"
	PACKAGES+=" libtbb-dev libsdformat5-dev freeglut3-dev libxmu-dev libxi-dev"
	PACKAGES+=" libqwt-qt5-dev libignition-msgs0-dev libtinyxml2-dev"
    fi
    if [ "$INSTALL_GAZEBO_ROS" = true ] ; then
	PACKAGES+=" ros-kinetic-perception ros-kinetic-ros-control ros-kinetic-ros-controllers"
    fi
    
    sudo apt update
    sudo apt install $PACKAGES
fi


#-------------------------------------------------------------------------------#
# Clone the repositories at the necessary branches                              #
#-------------------------------------------------------------------------------#
if [ "$INSTALL_DART" = true ] ; then
    git clone https://github.com/dartsim/dart.git -b release-5.1
fi
if [ "$INSTALL_GAZEBO" = true ] ; then
    hg clone https://bitbucket.org/osrf/gazebo -r gazebo8
    URL_PREFIX="https://raw.githubusercontent.com/adamconkey/setup_scripts/master/package_xml/"
    curl ${URL_PREFIX}gazebo_package.xml > ${WORKSPACE_PATH}/src/gazebo/package.xml
fi
if [ "$INSTALL_GAZEBO_ROS" = true ] ; then
    git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b kinetic-devel
fi


#-------------------------------------------------------------------------------#
# Initialize the catkin workspace and run the build                             #
#-------------------------------------------------------------------------------#
cd ${WORKSPACE_PATH}
catkin init
catkin build

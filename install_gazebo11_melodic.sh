#!/usr/bin/env bash
#=================================================================================#
# This script installs Gazebo11 from source into a catkin workspace. By default   #
# it also installs DART 6.9 from source in the same catkin workspace to enable    #
# Gazebo+DART physics engine. You can configure the installation by setting the   #
# boolean options below, as well as defining where the workspace will be created. #
#                                                                                 #
# It is recommended that you keep this workspace isolated, and extend it in your  #
# other workspaces. For example, you can config your other workspaces with the    #
# following command:                                                              #
#                                                                                 #
#     catkin config --extend $HOME/gazebo11_ws/devel		                  #
#								                  #
# Once you explicitly extend in a workspace you should do a clean build of it.    #
#                                                                                 #
#---------------------------------------------------------------------------------#
# TROUBLESHOOTING                                                                 #
#---------------------------------------------------------------------------------#
# - Errors about libGL.so in building: Try this solution to correct broken        #
#   symbolic links: https://github.com/RobotLocomotion/drake/issues/2087          #
#                                                                                 #
# - Errors about libEGL.so in building: Try this solution to correct broken       #
#   symbolic links: https://askubuntu.com/a/616076                                #
#=================================================================================#

INSTALL_DEPENDENCIES=true  # Install apt dependencies (recommended)
INSTALL_DART=true          # Install DART from source
INSTALL_DART_OPTIONAL=true # Install optional DART dependencies
INSTALL_ROS=true           # Install ROS Melodic (apt)

# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/gazebo11_ws"


#-------------------------------------------------------------------#
# Create the catkin workspace (or bail if it already exists)        #
#-------------------------------------------------------------------#
if [ -d "$WORKSPACE_PATH" ] ; then
    echo -e "\nThe directory $WORKSPACE_PATH already exists. Exiting.\n"
    exit 1
fi

mkdir -p ${WORKSPACE_PATH}/src
cd ${WORKSPACE_PATH}/src


#-------------------------------------------------------------------#
# Install dependencies for the packages specified to be installed   #
#-------------------------------------------------------------------#
if [ "$INSTALL_DEPENDENCIES" = true ] ; then
    # Setup the necessary apt keys
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list'
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
    
    # Populate packages needed by each component
    PACKAGES="mercurial python-catkin-tools curl"

    if [ "$INSTALL_ROS" = true ] ; then
	PACKAGES+=" ros-melodic-desktop"
    fi
    
    # DART dependencies
    if [ "$INSTALL_DART" = true ] ; then
	PACKAGES+=" build-essential cmake pkg-config git"
	PACKAGES+=" libeigen3-dev libassimp-dev libccd-dev libfcl-dev libboost-regex-dev"
	PACKAGES+=" libboost-system-dev libopenscenegraph-dev"	
	if [ "$INSTALL_DART_OPTIONAL" = true ] ; then
     	    PACKAGES+=" libnlopt-dev coinor-libipopt-dev"
	    PACKAGES+=" libbullet-dev libode-dev liboctomap-dev"
	    PACKAGES+=" libflann-dev libtinyxml2-dev liburdfdom-dev"
	    PACKAGES+=" libxi-dev libxmu-dev freeglut3-dev"
	fi
    fi

    # Gazebo dependencies. Run Gazebo's installation script.
    sudo apt update
    wget https://bitbucket.org/osrf/release-tools/raw/default/jenkins-scripts/lib/dependencies_archive.sh -O /tmp/dependencies.sh
    GAZEBO_MAJOR_VERSION=11 ROS_DISTRO=melodic . /tmp/dependencies.sh
    echo $BASE_DEPENDENCIES $GAZEBO_BASE_DEPENDENCIES | tr -d '\\' | xargs sudo apt install -y
    # Gazebo ROS dependencies
    PACKAGES+=" ros-melodic-perception ros-melodic-ros-control ros-melodic-ros-controllers"
    
    sudo apt update
    sudo apt install -y $PACKAGES
fi


#-------------------------------------------------------------------#
# Clone the repositories at the necessary branches                  #
#-------------------------------------------------------------------#
if [ "$INSTALL_DART" = true ] ; then
    git clone https://github.com/dartsim/dart.git -b release-6.9
fi
git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b melodic-devel
hg clone https://bitbucket.org/osrf/gazebo
URL_PREFIX="https://raw.githubusercontent.com/adamconkey/setup_scripts/master/package_xml/"
curl ${URL_PREFIX}gazebo9_package.xml > ${WORKSPACE_PATH}/src/gazebo/package.xml
curl ${URL_PREFIX}gazebo_dev_package.xml > ${WORKSPACE_PATH}/src/gazebo_ros_pkgs/gazebo_dev/package.xml


#-------------------------------------------------------------------#
# Initialize the catkin workspace and run the build                 #
#-------------------------------------------------------------------#
source /opt/ros/melodic/setup.bash

cd ${WORKSPACE_PATH}
catkin init
catkin build

source ${WORKSPACE_PATH}/devel/setup.bash

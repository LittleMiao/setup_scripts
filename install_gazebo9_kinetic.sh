#!/usr/bin/env bash
#===================================================================#
# This script installs Gazebo9 from source into a catkin workspace.
# By default it will also install DART from source in the same
# catkin workspace to enable Gazebo+DART physics engine. You can
# configure the installation by setting the boolean options below,
# as well as defining the where the workspace will be created.
#
# It is recommended that you keep this workspace isolated, and
# extend it in your other workspaces. For example, you can config
# your other workspaces with the following command (assuming you
# adopted the default workspace name provided by this script):
#
#     catkin config --extend $HOME/gazebo9_ws
#
# Once you explicitly extend in a workspace you should do a clean
# build of it.
#===================================================================#


INSTALL_DEPENDENCIES=true  # Install apt dependencies (recommended)
INSTALL_DART=true          # Install DART from source
INSTALL_DART_OPTIONAL=true # Install optional DART dependencies

# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/gazebo9_ws"


# You shouldn't need to edit below this line
#===================================================================#



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
    PACKAGES="mercurial python-catkin-tools curl ros-kinetic-desktop"
    
    # DART dependencies
    if [ "$INSTALL_DART" = true ] ; then
	PACKAGES+=" build-essential cmake pkg-config git"
	PACKAGES+=" libeigen3-dev libassimp-dev libccd-dev"
	PACKAGES+=" libfcl-dev libboost-regex-dev"
	PACKAGES+=" libboost-system-dev libopenscenegraph-dev"	
	if [ "$INSTALL_DART_OPTIONAL" = true ] ; then
     	    PACKAGES+=" libnlopt-dev coinor-libipopt-dev"
	    PACKAGES+=" libbullet-dev libode-dev liboctomap-dev"
	    PACKAGES+=" libflann-dev libtinyxml2-dev liburdfdom-dev"
	    PACKAGES+=" libxi-dev libxmu-dev freeglut3-dev"
	    PACKAGES+=" libopenscenegraph-dev"
	fi
    fi

    # Gazebo dependencies. Run Gazebo's installation script.
    sudo apt update
    wget https://bitbucket.org/osrf/release-tools/raw/default/jenkins-scripts/lib/dependencies_archive.sh -O /tmp/dependencies.sh
    GAZEBO_MAJOR_VERSION=9 ROS_DISTRO=kinetic . /tmp/dependencies.sh
    echo $BASE_DEPENDENCIES $GAZEBO_BASE_DEPENDENCIES | tr -d '\\' | xargs sudo apt install -y
    # Gazebo ROS dependencies
    PACKAGES+=" ros-kinetic-perception ros-kinetic-ros-control ros-kinetic-ros-controllers"
    
    sudo apt update
    sudo apt install -y $PACKAGES
fi


#-------------------------------------------------------------------#
# Clone the repositories at the necessary branches                  #
#-------------------------------------------------------------------#
if [ "$INSTALL_DART" = true ] ; then
    git clone https://github.com/dartsim/dart.git -b release-6.7
fi
git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b kinetic-devel
hg clone https://bitbucket.org/osrf/gazebo
URL_PREFIX="https://raw.githubusercontent.com/adamconkey/setup_scripts/master/package_xml/"
curl ${URL_PREFIX}gazebo9_package.xml > ${WORKSPACE_PATH}/src/gazebo/package.xml


#-------------------------------------------------------------------#
# Initialize the catkin workspace and run the build                 #
#-------------------------------------------------------------------#
source /opt/ros/kinetic/setup.bash

cd ${WORKSPACE_PATH}
catkin init
catkin build

source ${WORKSPACE_PATH}/devel/setup.bash

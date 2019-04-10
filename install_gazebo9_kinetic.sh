#!/usr/bin/env bash

INSTALL_GAZEBO=true        # Install Gazebo9 from source
INSTALL_GAZEBO_ROS=false    # Install gazebo_ros_pkgs from source
INSTALL_DART=true          # Install Dart6.7 from source
INSTALL_DART_OPTIONAL=false # Install optional Dart dependencies (apt)
INSTALL_DEPENDENCIES=true  # Install dependencies with apt (recommended)

# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/gazebo9_ws"


# You shouldn't need to edit below this line
#===================================================================#



#-------------------------------------------------------------------#
# Create the catkin workspace (or bail if it already exists)        #
#-------------------------------------------------------------------#
# if [ -d "$WORKSPACE_PATH" ] ; then
#     echo -e "\nThe directory $WORKSPACE_PATH already exists. Exiting.\n"
#     exit 1
# fi

# mkdir -p ${WORKSPACE_PATH}/src
cd ${WORKSPACE_PATH}/src


#------------------------------------------------------------------#
# Install dependencies for the packages specified to be installed  #
#------------------------------------------------------------------#
if [ "$INSTALL_DEPENDENCIES" = true ] ; then
    # Keys necessary for ROS packages
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt update

    # Run Gazebo's provided dependency install script
    wget https://bitbucket.org/osrf/release-tools/raw/default/jenkins-scripts/lib/dependencies_archive.sh -O /tmp/dependencies.sh
    GAZEBO_MAJOR_VERSION=9 ROS_DISTRO=kinetic . /tmp/dependencies.sh
    echo $BASE_DEPENDENCIES $GAZEBO_BASE_DEPENDENCIES | tr -d '\\' | xargs sudo apt install -y

    # Catkin tools
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list'
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
    
    PACKAGES="mercurial python-catkin-tools curl"
    PACKAGES+=" ros-kinetic-desktop"
    
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
    if [ "$INSTALL_GAZEBO" = true ] ; then
	
	PACKAGES+=" ruby-dev ruby libignition-transport4-dev"

    # 	PACKAGES+=" libtar-dev libfreeimage-dev libignition-math3-dev"
    # 	PACKAGES+=" libignition-transport3-dev protobuf-compiler libprotoc-dev"
    # 	PACKAGES+=" libtbb-dev libsdformat5-dev freeglut3-dev libxmu-dev libxi-dev"
    # 	PACKAGES+=" libqwt-qt5-dev libignition-msgs0-dev libtinyxml2-dev"
    fi
    # if [ "$INSTALL_GAZEBO_ROS" = true ] ; then
    # 	PACKAGES+=" ros-kinetic-perception ros-kinetic-ros-control ros-kinetic-ros-controllers"
    # fi
    
    sudo apt update
    sudo apt install -y $PACKAGES
fi


#-----------------------------------------------------------------#
# Clone the repositories at the necessary branches                #
#-----------------------------------------------------------------#
if [ "$INSTALL_DART" = true ] ; then
    git clone https://github.com/dartsim/dart.git -b release-6.7
fi
if [ "$INSTALL_GAZEBO" = true ] ; then
    # hg clone https://bitbucket.org/osrf/gazebo
    # hg clone https://bitbucket.org/osrf/sdformat -r sdf6
    # hg clone https://bitbucket.org/ignitionrobotics/ign-tools
    URL_PREFIX="https://raw.githubusercontent.com/adamconkey/setup_scripts/master/package_xml/"
    curl ${URL_PREFIX}gazebo9_package.xml > ${WORKSPACE_PATH}/src/gazebo/package.xml
    curl ${URL_PREFIX}ign_tools_package.xml > ${WORKSPACE_PATH}/src/ign-tools/package.xml
    curl ${URL_PREFIX}sdformat_package.xml > ${WORKSPACE_PATH}/src/sdformat/package.xml
fi
if [ "$INSTALL_GAZEBO_ROS" = true ] ; then
    git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b kinetic-devel
fi


#-----------------------------------------------------------------#
# Initialize the catkin workspace and run the build               #
#-----------------------------------------------------------------#
source /opt/ros/kinetic/setup.bash

cd ${WORKSPACE_PATH}
catkin init
catkin build

source ${WORKSPACE_PATH}/devel/setup.bash

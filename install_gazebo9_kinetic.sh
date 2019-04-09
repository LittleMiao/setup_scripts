
# Set the path location where you want the catkin workspace created:
WORKSPACE_PATH="$HOME/gazebo9_ws"


#-------------------------------------------------------------------#
# Create the catkin workspace (or bail if it already exists)        #
#-------------------------------------------------------------------#
if [ -d "$WORKSPACE_PATH" ] ; then
    echo -e "\nThe directory $WORKSPACE_PATH already exists. Exiting.\n"
    exit 1
fi

mkdir -p ${WORKSPACE_PATH}/src
cd ${WORKSPACE_PATH}/src

hg clone https://bitbucket.org/osrf/gazebo

hg clone https://bitbucket.org/osrf/sdformat -r sdf6

hg clone https://bitbucket.org/ignitionrobotics/ign-math -r ign-math4




sudo apt install ruby-dev ruby
sudo apt install libignition-transport4-dev

URL_PREFIX="https://raw.githubusercontent.com/adamconkey/setup_scripts/master/package_xml/"
curl ${URL_PREFIX}gazebo9_package.xml > ${WORKSPACE_PATH}/src/gazebo/package.xml
curl ${URL_PREFIX}ign_tools_package.xml > ${WORKSPACE_PATH}/src/ign_tools/package.xml
curl ${URL_PREFIX}sdformat_package.xml > ${WORKSPACE_PATH}/src/sdformat/package.xml



#-----------------------------------------------------------------#
# Initialize the catkin workspace and run the build               #
#-----------------------------------------------------------------#
cd ${WORKSPACE_PATH}
catkin init
catkin build

source ${WORKSPACE_PATH}/devel/setup.bash



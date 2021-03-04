FROM balenalib/raspberrypi3-ubuntu:focal

RUN ["cross-build-start"]

ENV LANG C.UTF-8

ENV LC_ALL C.UTF-8

ENV ROS_DISTRO noetic

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    build-essential \
    libmysqlcppconn-dev \
    python3-rosdep \
    python3-pip \
    python3-wstool \
    python3-catkin-tools \ 
    python3-catkin-lint \
    python3-osrf-pycommon \
    automake \
    autoconf \
    libtool \
    libmodbus-dev \
    libmodbus5 \
    ros-noetic-ros-core=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

COPY libs/WiringPi /opt/ros/noetic/lib/WiringPi

WORKDIR /opt/ros/noetic/lib/WiringPi

RUN ./build

COPY ros_ws/src /ws/src

WORKDIR /ws

RUN rosdep init && rosdep update

RUN . /opt/ros/noetic/setup.sh && \
    apt-get update && rosdep install -y \
      --from-paths /ws/src \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# RUN . /opt/ros/noetic/setup.sh && catkin_make 

WORKDIR /

RUN ["cross-build-end"]

CMD ["bash"]
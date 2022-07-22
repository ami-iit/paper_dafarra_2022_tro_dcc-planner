FROM nvidia/opengl:1.2-glvnd-devel-ubuntu20.04
LABEL org.opencontainers.image.title="Dynamic Complementarity Conditions and Whole-Body Trajectory Optimization for Humanoid Robot Locomotion"
LABEL org.opencontainers.image.description="Infrastructure for reproducing walking tests using the planner presented in the paper"
LABEL org.opencontainers.image.source="https://raw.githubusercontent.com/ami-iit/paper_dafarra_2022_tro_dcc-planner/main/dockerfiles/Dockerfile"
LABEL org.opencontainers.image.authors="Stefano Dafarra <stefano.dafarra@iit.it>"

ARG USERNAME=user
ARG USERID=1000

ARG iDynTree_TAG=4aabb8525e95af161e916a8dfb85fbf994bb7aeb
ARG coinbrew_TAG=cc905f64c39ebe430dd80d28b3d17207e04bf01d
ARG ipopt_TAG=641f2202f5594018ab0ebee6d1b7c6853ef83343
ARG MUMPS_TAG=2fc1a186fa118eccfeb76657424d43063b67b393
ARG ASL_TAG=d9e058561ec67b1440761f64fa94e28a6078fe95
ARG HSL_TAG=972b202b6d01c39221fe6fbe90f42779edf70e49
ARG matiocpp_TAG=ed9b196360b8083c3eccd3348afa7969d3a4f1fa
ARG dynamical_planner_TAG=09efc88679ab7a1cd8c94485c347870be63b8ebe

SHELL ["/bin/bash", "-c"]

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Set the locale
RUN apt install -y -qq apt-utils locales && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Install essentials
COPY deps.sh .
RUN  chmod +x ./deps.sh
RUN ./deps.sh && rm ./deps.sh && rm -rf /var/lib/apt/lists/*

# Create the user
RUN useradd --create-home -s /bin/bash --no-user-group -u $USERID $USERNAME && \
    adduser $USERNAME sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir cpp_ws && \
    cd cpp_ws && \
    mkdir -p build/install && \
    mkdir coin-or && \
    cd coin-or && \
    git clone https://github.com/coin-or/coinbrew && \
    cd coinbrew/ && \
    git reset ${coinbrew_TAG} --hard && \
    chmod u+x coinbrew && \
    cd ../ && \
    git clone https://github.com/coin-or/Ipopt && \
    cd Ipopt/ && \
    git checkout -b master && \
    git reset ${ipopt_TAG} --hard && \
    cd ../ && \
    mkdir ThirdParty && \
    cd ThirdParty/ && \
    git clone https://github.com/coin-or-tools/ThirdParty-Mumps Mumps && \
    cd Mumps/ && \
    git checkout -b stable/2.1 && \
    git reset ${MUMPS_TAG} --hard && \
    ./get.Mumps && \
    touch .build && \
    cd ../ && \
    git clone https://github.com/coin-or-tools/ThirdParty-ASL ASL && \
    cd ASL/ && \
    git checkout -b stable/2.0 && \
    git reset ${ASL_TAG} --hard && \
    ./get.ASL && \
    cd ../ && \
    git clone https://github.com/coin-or-tools/ThirdParty-HSL HSL && \
    cd HSL/ && \
    git checkout -b stable/2.1 && \
    git reset ${HSL_TAG} --hard  && \
    cd /home/$USERNAME/cpp_ws/coin-or && \
    coinbrew/coinbrew fetch Ipopt --no-prompt --skip-update &&\
    coinbrew/coinbrew build Ipopt -b /home/$USERNAME/cpp_ws/build/ipopt \
                                  --prefix=/home/$USERNAME/cpp_ws/build/install/ \
                                  --no-prompt --tests none --verbosity=3 \
                                  ADD_CFLAGS=-fopenmp ADD_FFLAGS=-fopenmp ADD_CXXFLAGS=-fopenmp && \
     cd /home/$USERNAME/cpp_ws/ && \
     git clone https://github.com/ami-iit/matio-cpp && \
     cd matio-cpp && \
     git checkout ${matiocpp_TAG} && \
     cd /home/$USERNAME/cpp_ws/build && \
     mkdir matio-cpp && \
     cd matio-cpp && \
     cmake -DCMAKE_INSTALL_PREFIX=/home/$USERNAME/cpp_ws/build/install \
           -DCMAKE_BUILD_TYPE=Release /home/$USERNAME/cpp_ws/matio-cpp && \
     make install && \
     export IPOPT_DIR=/home/$USERNAME/cpp_ws/build/install && \
     export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${IPOPT_DIR}/lib/pkgconfig/ && \
     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${IPOPT_DIR}/lib && \
     cd /home/$USERNAME/cpp_ws && \
     git clone https://github.com/robotology/idyntree && \
     cd idyntree && \
     git checkout ${iDynTree_TAG} && \
     cd /home/$USERNAME/cpp_ws/build && \
     mkdir idyntree && cd idyntree && \
     cmake -DCMAKE_INSTALL_PREFIX=/home/$USERNAME/cpp_ws/build/install \
           -DCMAKE_BUILD_TYPE=Release -DIDYNTREE_USES_IRRLICHT:BOOL=ON \
           /home/$USERNAME/cpp_ws/idyntree && \
     make install && \
     cd /home/$USERNAME/cpp_ws && \
     find . -mindepth 1 ! -regex '^./install\(/.*\)?' -delete && \
     git clone https://github.com/ami-iit/dynamical-planner && \
     cd dynamical-planner && \
     git checkout ${dynamical_planner_TAG} && \
     mkdir /home/$USERNAME/cpp_ws/build &&\
     cd /home/$USERNAME/cpp_ws/build && \
     mkdir dynamical-planner && cd dynamical-planner && \
     cmake -DCMAKE_PREFIX_PATH=/home/$USERNAME/cpp_ws/build/install -DCMAKE_BUILD_TYPE=Release \
           -DCMAKE_INSTALL_PREFIX=/home/$USERNAME/cpp_ws/build/install -DBUILD_TESTING:BOOL=ON \
           /home/$USERNAME/cpp_ws/dynamical-planner && \
     make

RUN mkdir -p /home/${USERNAME}/.config/tmuxinator
COPY dcc-planner.yml /home/${USERNAME}/.config/tmuxinator/.

CMD ["tmuxinator", "start", "dcc-planner"]


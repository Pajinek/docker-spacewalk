#!/usr/bin/bash
# author: Pavel Studenik <studenik@varhoo.cz>

# currently support only RHELs
BUILD_OS="6" 

GIT_PATH_SPEC=$(dirname $(git rev-parse --git-common-dir))
GIT_PATH=$(git rev-parse --show-toplevel)
BUILD_NAME="tito-build-$BUILD_OS"
DEFAULT_PACKAGES="redhat-logos intltool gettext python-devel make tito"

echo """
FROM centos:$BUILD_OS
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$BUILD_OS.noarch.rpm && \
    yum install -y $DEFAULT_PACKAGES
CMD /bin/bash
""" | docker build -t $BUILD_NAME -

# check selinux
if [[ $(getenforce) == Enforcing ]]; then
    echo "Selinux is enable; update selinux for directories"
    chcon -Rt svirt_sandbox_file_t $GIT_PATH /tmp/tito/
fi

BUILD_CMD="cd /root/git/$GIT_PATH_SPEC; tito build --test --rpm"
if docker ps -a | grep $BUILD_NAME; then
    docker start $BUILD_NAME && \
    docker exec -it $BUILD_NAME /bin/bash -c "$BUILD_CMD"
else
    docker run --name $BUILD_NAME -v $GIT_PATH:/root/git \
        -v /tmp/tito:/tmp/tito -it $BUILD_NAME /bin/bash -c "$BUILD_CMD"
fi

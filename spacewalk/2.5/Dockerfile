FROM centos:7
MAINTAINER Pavel Studenik <pstudeni@redhat.com>

RUN URL_SW=http://yum.spacewalkproject.org/2.5/RHEL/7/x86_64/ && \
    rpm -Uvh $URL_SW/$( curl --silent $URL_SW | grep spacewalk-repo-[0-9] |  grep -Po '(?<=href=")[^"]*' ) && \
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum install yum-utils -y && yum-config-manager repo --enable epel-testing

ADD jpackage-generic.repo /etc/yum.repos.d/jpackage-generic.repo

RUN yum install -y spacewalk-postgresql perl-DBD-Pg \
                   spacewalk-taskomatic spacewalk-common c3p0 && \
    yum -y downgrade c3p0 && \
    yum clean all

ADD answer.txt /root/answer.txt
ADD bin/docker-spacewalk-setup.sh /root/docker-spacewalk-setup.sh
ADD bin/docker-spacewalk-run.sh /root/docker-spacewalk-run.sh
ADD bin/spacewalk-hostname-rename.sh /root/spacewalk-hostname-rename.sh

RUN chmod a+x /root/docker-spacewalk-{run,setup}.sh

EXPOSE 69 80 443 5222

CMD /root/docker-spacewalk-run.sh


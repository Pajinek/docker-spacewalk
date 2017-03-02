from centos:6
# author: Pavel Studenik <pstudeni@redhat.com>

RUN URL_SW=http://yum.spacewalkproject.org/nightly/RHEL/6/x86_64/ && \
rpm -Uvh $URL_SW/$( curl --silent $URL_SW | grep spacewalk-repo-[0-9] |  grep -Po '(?<=href=")[^"]*' ) && \
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN sed s/enabled=0/enabled=1/g /etc/yum.repos.d/spacewalk-nightly.repo -i && \
    sed s/enabled=1/enabled=0/g /etc/yum.repos.d/spacewalk.repo -i

ADD jpackage-generic.repo /etc/yum.repos.d/jpackage-generic.repo

RUN yum update -y && \
    yum install -y spacewalk-setup-postgresql spacewalk-postgresql tomcat \
                   spacewalk-taskomatic spacewalk-common && \
    yum clean all

ADD answer.txt /root/answer.txt
ADD bin/docker-spacewalk-setup.sh /root/docker-spacewalk-setup.sh
ADD bin/docker-spacewalk-run.sh /root/docker-spacewalk-run.sh

RUN chmod a+x /root/docker-spacewalk-{run,setup}.sh

EXPOSE 69 80 443 5222

CMD /root/docker-spacewalk-run.sh


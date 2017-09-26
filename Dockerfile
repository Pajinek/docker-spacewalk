FROM centos:7
MAINTAINER Pavel Studenik <pstudeni@redhat.com>

ENV SW_REPO_RPM spacewalk-repo-2.8-7.el7.centos.noarch.rpm

ADD copr-java-packages.repo /etc/yum.repos.d/copr-java-packages.repo

RUN rpm -Uvh https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/nightly/epel-7-x86_64/00607556-spacewalk-repo/"$SW_REPO_RPM" && \
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    sed s/enabled=0/enabled=1/g /etc/yum.repos.d/spacewalk-nightly.repo -i && \
    sed s/enabled=1/enabled=0/g /etc/yum.repos.d/spacewalk.repo -i && \
    yum update -y && \
    yum install -y spacewalk-postgresql spacewalk-taskomatic spacewalk-common spacewalk-utils && \
    yum clean all

ADD answer.txt /root/answer.txt
ADD bin/docker-spacewalk-setup.sh /root/docker-spacewalk-setup.sh
ADD bin/docker-spacewalk-run.sh /root/docker-spacewalk-run.sh
ADD bin/spacewalk-hostname-rename.sh /root/spacewalk-hostname-rename.sh

RUN chmod a+x /root/docker-spacewalk-{run,setup}.sh

EXPOSE 69 80 443 5222

VOLUME ["/var/satellite", "/root/ssl-build"]

CMD /root/docker-spacewalk-run.sh


FROM centos:7
MAINTAINER Pavel Studenik <pstudeni@redhat.com>

ENV SW_REPO_RPM spacewalk-repo-2.8-7.el7.centos.noarch.rpm

ADD copr-java-packages.repo /etc/yum.repos.d/copr-java-packages.repo

RUN yum install -y yum-plugin-copr && \
    yum copr enable @spacewalkproject/nightly -y && yum install -y spacewalk-repo && \
    yum copr disable @spacewalkproject/nightly -y && \
    sed s/enabled=0/enabled=1/g /etc/yum.repos.d/spacewalk-nightly.repo -i && \
    sed s/enabled=1/enabled=0/g /etc/yum.repos.d/spacewalk.repo -i && \
    yum update -y && \
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y spacewalk-postgresql spacewalk-taskomatic spacewalk-common spacewalk-utils && \
    yum remove -y yum-plugin-copr && \
    yum clean all

ADD answer.txt /root/answer.txt
ADD bin/docker-spacewalk-setup.sh /root/docker-spacewalk-setup.sh
ADD bin/docker-spacewalk-run.sh /root/docker-spacewalk-run.sh
ADD bin/spacewalk-hostname-rename.sh /root/spacewalk-hostname-rename.sh

RUN chmod a+x /root/docker-spacewalk-{run,setup}.sh

EXPOSE 69 80 443 5222

VOLUME ["/var/satellite", "/root/ssl-build"]

CMD /root/docker-spacewalk-run.sh


FROM fabric8/s2i-java:2.1

#
# A custom base image for running our applications
#

MAINTAINER Jens Reimann <jreimann@redhat.com>
LABEL maintainer "Jens Reimann <jreimann@redhat.com>"

USER root

RUN yum update -y
RUN yum install -y iproute
RUN yum install -y --enablerepo=base-debuginfo java-1.8.0-openjdk-debuginfo
#RUN debuginfo-install -y $(rpm -qa | egrep "^java"  | grep -v debuginfo)

USER 1000

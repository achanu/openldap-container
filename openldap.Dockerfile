FROM quay.io/centos/centos:7 AS build

RUN mkdir -p /rootfs
RUN \
  yum install -y \
  --installroot /rootfs --releasever 7 \
  --setopt=tsflags=nodocs \
    coreutils-single \
    glibc \
    openldap-servers \
  && \
  cp -v /etc/yum.repos.d/*.repo /rootfs/etc/yum.repos.d/ && \
  yum clean all && \
  rm -rf /rootfs/var/cache/*


FROM scratch AS openldap-micro
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

COPY --from=build /rootfs/ /

RUN \
  chown -R ldap:ldap /etc/openldap /var/lib/ldap /etc/sysconfig/slapd /var/run/openldap && \
  >/etc/sysconfig/slapd

USER ldap
CMD ["/usr/sbin/slapd", "-h", "ldap://0.0.0.0:10389/", "-d", "1"]

VOLUME /etc/openldap
VOLUME /var/lib/ldap
EXPOSE 389/tcp
EXPOSE 636/tcp

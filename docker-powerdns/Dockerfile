ARG PDNS_AUTH_RELEASE=4.6.3
ARG PDNS_AUTH_IMAGE=powerdns/pdns-auth-46

FROM $PDNS_AUTH_IMAGE:$PDNS_AUTH_RELEASE

ENV POWERDNS_VERSION=$PDNS_AUTH_RELEASE \
    PDNS_socket_dir=/var/run/pdns \
    PDNS_master=yes \
    # PDNS_daemon=no \ 
    # PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=0 \
    PDNS_launch=gmysql

USER root

RUN apt-get update &&  apt-get install python3-pip -y && pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir envtpl

RUN chown -Rf pdns:pdns /etc/powerdns

USER pdns

COPY pdns.conf.tpl /
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

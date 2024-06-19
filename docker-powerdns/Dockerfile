ARG PDNS_AUTH_RELEASE=4.6.3
ARG PDNS_AUTH_IMAGE=powerdns/pdns-auth-46

FROM $PDNS_AUTH_IMAGE:$PDNS_AUTH_RELEASE

ENV POWERDNS_VERSION=$PDNS_AUTH_RELEASE \
    PDNS_socket_dir=/run/pdns \
    PDNS_primary=yes \
    # PDNS_daemon=no \ 
    # PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=0 \
    PDNS_launch=gmysql

USER root

RUN apt-get update &&  apt-get install python3-pip -y && pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir envtpl

# Add proper permissions for non-root containers running arbitrary UIDs
RUN chown -Rf pdns:0 /etc/powerdns && chgrp -R 0 /etc/powerdns && chmod -R g+rwX /etc/powerdns
RUN mkdir -p /run/pdns && chown -Rf pdns:0 /run/pdns && chgrp -R 0 /run/pdns && chmod -R g+rwX /run/pdns
RUN setcap 'cap_net_bind_service=+ep' /usr/local/sbin/pdns_server

USER pdns

COPY pdns.conf.tpl /
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

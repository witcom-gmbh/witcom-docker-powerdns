FROM redgate/flyway:11-alpine

ENV FLYWAY_DBTYPE=postgresql \
    FLYWAY_DBHOST=localhost \
    FLYWAY_DBNAME=powerdns

ADD entrypoint.sh /

USER root

# CLEANUP
RUN mkdir -p /tmp/drivers && \
    cp /flyway/drivers/mariadb* /tmp/drivers/ && \
    cp /flyway/drivers/postgresql* /tmp/drivers/ && \  
    rm -rf /flyway/drivers/* && \
    cp /tmp/drivers/* /flyway/drivers/

RUN addgroup -S flyway && \
    adduser -S -D -H -h /var/empty -s /bin/false -G flyway -g flyway flyway

RUN chgrp -R 0 /flyway && \
    chmod -R g+rwX /flyway 

USER flyway

COPY migrations/ /flyway/sql/

ENTRYPOINT ["/entrypoint.sh"]

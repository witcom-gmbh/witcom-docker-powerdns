FROM flyway/flyway:10-alpine

ENV FLYWAY_DRIVER="org.mariadb.jdbc.Driver" \
    FLYWAY_DBTYPE=mysql \
    FLYWAY_DBHOST=localhost \
    FLYWAY_DBPORT=3306 \
    FLYWAY_DBNAME=powerdns

ADD entrypoint.sh /

USER root
RUN addgroup -S flyway && \
    adduser -S -D -H -h /var/empty -s /bin/false -G flyway -g flyway flyway

RUN chgrp -R 0 /flyway && \
    chmod -R g+rwX /flyway 

USER flyway

COPY migrations/*.sql /flyway/sql/

ENTRYPOINT ["/entrypoint.sh"]

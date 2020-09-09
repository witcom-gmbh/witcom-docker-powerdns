FROM flyway/flyway

ENV REFRESHED_AT="2020-09-07" \
    FLYWAY_DRIVER="org.mariadb.jdbc.Driver" \
    FLYWAY_DBTYPE=mysql \
    FLYWAY_DBHOST=localhost \
    FLYWAY_DBPORT=3306 \
    FLYWAY_DBNAME=powerdns

ADD entrypoint.sh /

USER root

RUN chgrp -R 0 /flyway && \
    chmod -R g+rwX /flyway 

USER flyway

COPY migrations/*.sql /flyway/sql/

ENTRYPOINT ["/entrypoint.sh"]

ARG BASE

FROM $BASE

ARG AUTHOR
ARG VERSION

LABEL maintainer=$AUTHOR version=$VERSION

ARG TARGETOS
ARG TARGETARCH

COPY ./server/server.yaml /etc/
RUN mkdir /etc/mysql
COPY ./server/controller/db/mysql/migration/rawsql /etc/mysql
COPY ./server/controller/cloud/filereader/manual_data_samples.yaml /etc/
COPY ./server/querier/db_descriptions /etc/db_descriptions/

COPY ./server/bin/deepflow-server-$TARGETARCH /bin/btel-ebpf-server

CMD /bin/btel-ebpf-server
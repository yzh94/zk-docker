FROM 172.16.100.249:5000/centos:6.6

ADD zookeeper.tar.gz /data/
COPY entrypoint.sh /data/zookeeper

RUN set -eux; \
    mkdir -p /data/zookeeper/data ;\
    mkdir -p /data/zookeeper/logs;\
    chmod 777 /data/zookeeper/entrypoint.sh;

WORKDIR /data/zookeeper

EXPOSE 2181 2888 3888 

ENTRYPOINT ["/data/zookeeper/entrypoint.sh"]

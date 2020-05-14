#!/bin/bash

cd /data/zookeeper
if [ "$port" == "" ];then
        port=2181
fi
sed -i 's#^clientPort=.*#clientPort='"${port}"'#g' conf/zoo.cfg


if [ "$adport" == "" ];then
        adport=2080
fi
sed -i 's#^admin.serverPort=.*#admin.serverPort='"${adport}"'#g' conf/zoo.cfg


if [ "$MYID" == "" ]; then
        /sbin/ifconfig |grep "addr:"
        if [ $? -eq 0 ] ; then
                if [ "$ip_range" != "" ]; then
                        host_name=`/sbin/ifconfig |grep "inet addr"|egrep "$ip_range"|egrep -v "Bcast:0.0.0.0|cast 0.0.0.0|docker|cni|virbr|veth|flannel|tun"|awk -F : '{print $2}' |awk '{print $1}'|head -n 1 `
                else
                        host_name=`/sbin/ifconfig |grep "inet addr"|egrep -v "Bcast:0.0.0.0|cast 0.0.0.0|docker|cni|virbr|veth|flannel|tun"|awk -F : '{print $2}' |awk '{print $1}'|grep -v "^172.17.0"|head -n 1 `
                fi
        else
                if [ "$ip_range" != "" ]; then
                        host_name=`/sbin/ifconfig |grep "inet "|egrep "$ip_range"|egrep -v "Bcast:0.0.0.0|cast 0.0.0.0|docker|cni|virbr|veth|flannel|tun"|awk '{print $2}'|awk '{print $1}'|head -n 1`
                else
                        host_name=`/sbin/ifconfig |grep "inet "|egrep -v "Bcast:0.0.0.0|cast 0.0.0.0|docker|cni|virbr|veth|flannel|tun"|awk '{print $2}'|awk '{print $1}'|grep -v "^172.17.0"|head -n 1`
                fi
        fi
     if [ "$WEIGHT" == "" ]; then
        MYID=`echo $host_name | awk -F'.' '{print $NF}'`
     else
        echo $SERVERS  | awk -F ',' '{for (i=1;i<NF+1;i++) print $i}' >SERVERS
                                MYID=`grep $host_name SERVERS| awk -F':' '{print $2}'`
     fi
fi

echo $MYID > data/myid

sed -i '/server./ d' conf/zoo.cfg
if [ "$WEIGHT" == "" ]; then
        echo $SERVERS  | awk -F ',' '{for (i=1;i<NF+1;i++) print "server."$i"="$i":2888:3888"; }' |awk -F'.' '{print $1"."$5"."$6"."$7"."$8}' >> conf/zoo.cfg
else
        echo $SERVERS  | awk -F ',' '{for (i=1;i<NF+1;i++) print $i}' >SERVERS
        cat SERVERS |awk -F':' '{print "server."$2"="$1":2888:3888"}' >> conf/zoo.cfg
fi
if [ "$PortRange" != "" ]; then
        sed -i 's/2888:3888/'${PortRange}'/g' conf/zoo.cfg
fi
# Concatenate the IP:PORT for ZooKeeper to allow setting a full connection
# string with multiple ZooKeeper hosts

echo 'ls -alh --color=auto $@'>/bin/l
chmod +x /bin/l
export JAVA_HOME=/data/java/jdk1.8
export PATH=$JAVA_HOME/bin:$PATH

cd bin
nohup sh zkServer.sh start
tail -f /data/zookeeper/conf/zoo.cfg

#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

rm -rf /usr/bin/java
ln -s $JAVA_HOME/bin/java /usr/bin/java

echo $JAVA_HOME
java -V

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi

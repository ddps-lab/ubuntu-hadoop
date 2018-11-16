FROM kmubigdata/ubuntu-1604
MAINTAINER kimjeongchul

USER root

# install dev tools
RUN apt-get install -y curl openssh-server openssh-client rsync wget

# passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# java
RUN mkdir -p /usr/java/default
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
RUN tar -xzvf jdk-8u131-linux-x64.tar.gz -C /usr/java/default --strip-components=1
RUN rm jdk-8u131-linux-x64.tar.gz

# java env
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

RUN rm -rf /usr/bin/java
RUN ln -s $JAVA_HOME/bin/java /usr/bin/java


# hadoop
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-3.1.1/hadoop-3.1.1.tar.gz
RUN tar -xvzf hadoop-3.1.1.tar.gz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.1.1 hadoop
RUN rm hadoop-3.1.1.tar.gz

# hadoop env
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \


RUN mkdir -pv $HADOOP_HOME/input
RUN mkdir -pv $HADOOP_HOME/dfs
RUN mkdir -pv $HADOOP_HOME/dfs/name
RUN mkdir -pv $HADOOP_HOME/dfs/data
RUN mkdir -pv $HADOOP_HOME/tmp

RUN cp $HADOOP_HOME/etc/hadoop/*.xml $HADOOP_HOME/input

# pseudo distributed
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD slaves $HADOOP_HOME/etc/hadoop/slaves

RUN $HADOOP_HOME/bin/hdfs namenode -format

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# workingaround docker.io build error
RUN ls -la $HADOOP_HOME/etc/hadoop/*-env.sh
RUN chmod +x $HADOOP_HOME/etc/hadoop/*-env.sh
RUN ls -la $HADOOP_HOME/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# HDFS ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000

# Mapred ports
EXPOSE 10020 19888

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088

# Other ports
EXPOSE 49707 2122

ENTRYPOINT ["/etc/bootstrap.sh"]

                                                                                    106,0-1       Bot


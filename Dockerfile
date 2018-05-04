FROM kmubigdata/ubuntu-1604
MAINTAINER kimjeongchul

USER root

# install dev tools
RUN apt-get update
RUN apt-get install -y curl openssh-server openssh-client rsync wget

# passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# java
RUN apt-get install -y --no-install-recommends openjdk-8-jdk

# java env
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

#RUN rm -rf /usr/bin/java
#RUN ln -s $JAVA_HOME/bin/java /usr/bin/java

# hadoop
RUN wget http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-2.8.3/hadoop-2.8.3.tar.gz
RUN tar -xvzf hadoop-2.8.3.tar.gz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-2.8.3 hadoop
RUN rm hadoop-2.8.3.tar.gz

# hadoop env
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_PREFIX $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

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

#COPY bootstrap.sh /etc/bootstrap.sh
#RUN chown root.root /etc/bootstrap.sh
#RUN chmod 700 /etc/bootstrap.sh

# HDFS ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000

# Mapred ports
EXPOSE 10020 19888

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088

# Other ports
EXPOSE 49707 2122

#ENTRYPOINT ["/etc/bootstrap.sh"]

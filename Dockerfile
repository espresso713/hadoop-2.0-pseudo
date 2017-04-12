FROM ubuntu:16.04

#ssh
RUN apt-get update && apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

#env - account: hadoop
ENV HADOOP_ACCOUNT=/home/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle 
ENV	HADOOP_HOME=$HADOOP_ACCOUNT/soft/apache/hadoop/hadoop-2.6.0
ENV	HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop
ENV	PATH=$PATH:$HADOOP_HOME/bin 
ENV	PATH=$PATH:$HADOOP_HOME/sbin 


#java
RUN apt-get -y install software-properties-common
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

#account
USER root
RUN adduser hadoop
RUN echo 'hadoop:hadoop' | chpasswd

#hadoop
USER hadoop   
RUN mkdir -p $HADOOP_ACCOUNT/soft/apache/hadoop
WORKDIR $HADOOP_ACCOUNT/soft/apache/hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
RUN tar xvzf hadoop-2.6.0.tar.gz

#hadoop-conf
USER root
ADD ./hadoop-conf/core-site.xml $HADOOP_CONFIG_HOME
ADD ./hadoop-conf/hdfs-site.xml $HADOOP_CONFIG_HOME
ADD ./hadoop-conf/mapred-site.xml $HADOOP_CONFIG_HOME
ADD ./hadoop-conf/yarn-site.xml $HADOOP_CONFIG_HOME
RUN chown hadoop:hadoop $HADOOP_CONFIG_HOME/core-site.xml
RUN chown hadoop:hadoop $HADOOP_CONFIG_HOME/hdfs-site.xml
RUN chown hadoop:hadoop $HADOOP_CONFIG_HOME/mapred-site.xml
RUN chown hadoop:hadoop $HADOOP_CONFIG_HOME/yarn-site.xml

#hadoop example
USER root
RUN mkdir $HADOOP_ACCOUNT/work
ADD ./work $HADOOP_ACCOUNT/work
RUN chown -R hadoop:hadoop $HADOOP_ACCOUNT/work

#hadoop bootstrap.sh
USER root
ADD bootstrap.sh /etc
RUN chown hadoop:hadoop /etc/bootstrap.sh

#etc
USER hadoop
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-2.6.0/hadoop-data
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-2.6.0/pids

#protobuf
USER root  
RUN apt-get update
RUN apt-get -y install make
RUN apt-get -y install gcc
RUN apt-get -y install g++

WORKDIR /usr/local
RUN wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
RUN tar xvzf protobuf-2.5.0.tar.gz
WORKDIR /usr/local/protobuf-2.5.0
RUN ./configure
RUN make && make install
RUN ldconfig

CMD ["/usr/sbin/sshd", "-D"]













	



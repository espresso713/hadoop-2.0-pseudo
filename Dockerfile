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
ENV MY_HOME=/home/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle 
ENV	HADOOP_HOME=$MY_HOME/soft/apache/hadoop/hadoop-2.6.0
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
RUN adduser hadoop
RUN echo 'hadoop:m40931gf' | chpasswd
USER hadoop    

#hadoop
RUN mkdir -p $HOME/soft/apache/hadoop
WORKDIR $MY_HOME/soft/apache/hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
RUN tar xvzf hadoop-2.6.0.tar.gz

ADD core-site.xml $HADOOP_CONFIG_HOME
ADD hdfs-site.xml $HADOOP_CONFIG_HOME
ADD mapred-site.xml $HADOOP_CONFIG_HOME

WORKDIR $HADOOP_CONFIG_HOME
RUN touch masters


RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> hadoop-env.sh
RUN echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> hadoop-env.sh
RUN echo 'export HADOOP_PID_DIR=$HOME/soft/apache/hadoop/hadoop-2.6.0/pids' >> hadoop-env.sh

#etc
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-2.6.0/hadoop-data
RUN mkdir -p $HOME/soft/apache/hadoop/hadoop-2.6.0/pids

#protobuf
USER root  
RUN apt-get update
RUN mkdir -p $HOME/soft/protobuf
WORKDIR $MY_HOME/soft/protobuf
RUN wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
RUN tar xvzf protobuf-2.5.0.tar.gz
WORKDIR $MY_HOME/soft/protobuf/protobuf-2.5.0
RUN apt-get -y install make
RUN apt-get -y install gcc
RUN apt-get -y install g++
RUN ./configure
RUN make && make install
RUN ldconfig


CMD ["/usr/sbin/sshd", "-D"]













	



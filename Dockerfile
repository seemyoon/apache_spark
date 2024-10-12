FROM ubuntu:22.04
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

RUN apt-get install -y --no-install-recommends build-essential curl libfreetype6-dev python3.7 python3.7-dev libhdf5-dev libpng-dev libzmq3-dev pkg-config python3-pip python3.7-venv rsync unzip && apt-get clean
#1.-------install JDK--HADOOP--SPARK

RUN cd /tmp && \
    curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "https://download.java.net/openjdk/jdk8u40/ri/openjdk-8u40-b25-linux-x64-10_feb_2015.tar.gz" && \
    tar -xf openjdk-8u40-b25-linux-x64-10_feb_2015.tar.gz -C /opt && rm -f openjdk-8u40-b25-linux-x64-10_feb_2015.tar.gz && \
    ln -s /opt/java-* /opt/jdk
# Define commonly used JAVA_HOME variable

ENV JAVA_HOME /opt/jdk
#install HADOOP
RUN cd /tmp && curl -L -O -k "https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz" && \
    tar -xf hadoop-2.7.7.tar.gz -C /opt && rm -f hadoop-2.7.7.tar.gz && \
    ln -s /opt/hadoop* /opt/hadoop
ENV HADOOP_HOME /opt/hadoop
#install SPARK
RUN cd /tmp && curl -L -O -k "https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz" && \
    tar -xf spark-2.4.4-bin-hadoop2.7.tgz -C /opt && rm -f spark-2.4.4-binhadoop2.7.tgz && \
    ln -s /opt/spark* /opt/spark

ENV SPARK_HOME /opt/spark
# Add JDK,HADOOP and SPARK on PATH variable
ENV PATH ${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${SPARK_HOME}/bin

VOLUME ["/hdfs","/var/logs"]
#--------copy hadoop & spark config
COPY hadoop-conf/* /opt/hadoop/etc/hadoop/
COPY spark-conf/* /opt/spark/conf/
#2.----------- setup ssh client keys for root
RUN curl -o /etc/apt/sources.list http://mirrors.163.com/.help/sources.list.jammy
RUN apt-get update && apt-get install -y openssh-client openssh-server && \
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config
#3.-----------install docker-gen
RUN apt-get install -y dnsmasq && apt-get clean
ENV DOCKER_HOST unix:///var/run/docker.sock
RUN cd /tmp && curl -L -O -k "https://github.com/jwilder/docker-gen/releases/download/0.7.3/docker-gen-linux-amd64-0.7.3.tar.gz" && \
    tar xf docker-gen-linux-amd64-0.7.3.tar.gz -C /usr/local/bin && rm -f docker-gen-linux-amd64-0.7.3.tar.gz
COPY etc-hosts.tmpl /etc/etc-hosts.tmpl
COPY shell/* /shell/
RUN chmod +x /shell/*.sh
#4.-----------tensoronspark install
RUN python3.7 -m pip install pip --upgrade && python3.7 -m pip install wheel && pip install --upgrade setuptools
RUN pip install protobuf tensorflow tensorflowonspark pyspark && apt-get clean
#-------enviroment
ENV NAMENODE localhost
ENV DATANODE localhost
ENV TFOS_HOME /tmp/data/examples
ENV PYSPARK_PYTHON python3.7
LABEL dns.inspected="true"
#--------expose ports
EXPOSE 50070 50020 8020 8888 6060 7077 4040 8080 8081
CMD ["/shell/bootALL.sh"]
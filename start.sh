docker rm -f node1

#network
docker network rm mynet
docker network create --subnet=172.19.0.0/16 mynet

docker run -it --net mynet -h node1 --ip 172.19.0.2 \
	-p 50070:50070 \
	-p 50090:50090 \
	-p 50075:50075 \
	-p 19888:19888 \
	-p 8088:8088 \
	-p 8042:8042 \
	-p 8082:22 \
	-d --name node1 host1:1.0 


#ssh without a prompt
docker exec -it -u hadoop node1 ssh-keygen -t rsa -q -f "/home/hadoop/.ssh/id_rsa" -N ""
docker exec -it -u hadoop node1 ssh-copy-id -i /home/hadoop/.ssh/id_rsa.pub -o StrictHostKeyChecking=no hadoop@node1

#run bootstrap.sh
docker exec -it -u hadoop node1 sh -c '/etc/bootstrap.sh';

#hadoop start
docker exec -it -u hadoop node1 sh -c '$HADOOP_HOME/bin/hdfs namenode -format';
docker exec -it -u hadoop node1 sh -c '$HADOOP_HOME/sbin/start-all.sh';

#history server
docker exec -it --user hadoop node1 sh -c '$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver';

docker exec -it -u hadoop node1 /bin/bash;







docker rm -f node1

#network
docker network rm mynet
docker network create --subnet=172.19.0.0/16 mynet

docker run -it --net mynet -h node1 --ip 172.19.0.2 -p 8081:50070 \
	-d --name node1 host1:1.0 


#ssh without a prompt
docker exec -it -u hadoop node1 ssh-keygen -t rsa -q -f "/home/hadoop/.ssh/id_rsa" -N ""
docker exec -it -u hadoop node1 ssh-copy-id -i /home/hadoop/.ssh/id_rsa.pub -o StrictHostKeyChecking=no hadoop@node1

#run bootstrap.sh
docker exec -it -u hadoop node1 sh -c '/etc/bootstrap.sh';

#hadoop start
docker exec -it -u hadoop node1 sh -c '$HADOOP_HOME/bin/hdfs namenode -format';
docker exec -it -u hadoop node1 sh -c '$HADOOP_HOME/sbin/start-all.sh';
docker exec -it -u hadoop node1 /bin/bash;







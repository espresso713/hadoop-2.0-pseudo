docker rm -f master

#network
docker network rm mynet
docker network create --subnet=172.19.0.0/16 mynet

docker run -it --net mynet -h master --ip 172.19.0.2 -p 8081:50070 \
	-d --name master namenode:1.0 

#masters
mkdir tmpMasters
touch tmpMasters/masters

echo master >> tmpMasters/masters

docker exec -i master sh -c 'cat > $HADOOP_CONFIG_HOME/masters' < tmpMasters/masters

rm -r tmpMasters

#slaves
mkdir tmpSlaves
touch tmpSlaves/slaves

echo master >> tmpSlaves/slaves

docker exec -i master sh -c 'cat > $HADOOP_CONFIG_HOME/slaves' < tmpSlaves/slaves

rm -r tmpSlaves	

#ssh without a prompt
docker exec -it master ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""
docker exec -it master ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@master

#hadoop start
docker exec -it --user hadoop master sh -c '$HADOOP_HOME/bin/hdfs namenode -format';
docker exec -it --user hadoop master sh -c '$HADOOP_HOME/sbin/start-all.sh';







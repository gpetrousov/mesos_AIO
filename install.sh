#!/bin/bash

# 09-Mar-16
# Ioannis Petrousov
# petrousov@gmail.com

# Install mesos, marathon, zookeeper, docker on a single box.
# Created for demonstration putposes only.

rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm

yum -y install mesos marathon mesosphere-zookeeper.x86_64
# Unique ID for each master
my_id=1
my_ip=$(ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo $my_id > /var/lib/zookeeper/myid
# This might fail if you have multiple interfaces
echo "server.$my_id=$my_ip:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

echo $my_ip > /etc/mesos-master/ip
cp /etc/mesos-master/ip /etc/mesos-master/hostname
echo "athina" > /etc/mesos-master/cluster
echo "zk://$my_ip:2181/mesos" > /etc/mesos/zk

# install docker the wrong way
curl -sSL https://get.docker.com/ | sh
service docker start

# install slave
echo $my_ip > /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
echo 'docker,mesos' > /etc/mesos-slave/containerizers
echo '10mins' > /etc/mesos-slave/executor_registration_timeout

chkconfig docker on
chkconfig marathon on
chkconfig mesos-master on
chkconfig zookeeper on
chkconfig mesos-slave on
systemctl start marathon
systemctl start zookeeper
systemctl restart  mesos-master.service
systemctl restart mesos-slave.service

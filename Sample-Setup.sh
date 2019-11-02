# This file can be used after downloading the files 
# from OpenText and Cloning the Project
# into a working directory 
###########################################################
######################## Content Dependencies #############
###########################################################
# 1. documentum-environment.profile [Sample File]
# 2. CS-Docker-Compose_Stateless.yml [Sample File]
# 3. web.xml [Tag Pooling Disabled] [Sample File]
# 4. server.xml [SSL Enabled] [Sample File]
# 5. tomcat.keystore [Key for Tomcat SSL]
# 6. da [Documentum Administrator with dfc.properties]
# 7. dctm-rest [DCTM REST with dfc.properties]
# 8. Contentserver_Ubuntu.tar [Documentum CS Docker Image]
# 9. dfc.properties [Sample Properties File]
###########################################################
###########################################################
###########################################################

#Extract and load Documentum CS Docker Image
tar -xvf contentserver_docker_ubuntu.tar
docker load -i Contentserver_Ubuntu.tar

#Docker Networking Interface
docker network create documentum
sleep 5s

#Postgres Setup
docker run --network documentum --name postgres --hostname postgres -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres:9.6
sleep 5s
docker exec -it postgres su -c "mkdir /var/lib/postgresql/data/db_centdb_dat.dat" postgres
docker run --rm --network documentum mikesplain/telnet postgres 5432

#Documentum CS Setup
source documentum-environment.profile
docker-compose -f CS-Docker-Compose_Stateless.yml up -d
sleep 25m

#Tomcat Setup with SSL
docker run --network documentum -d --name tomcat --hostname tomcat -p 8080:8080 -p 443:8443 tomcat
docker cp web.xml tomcat:/usr/local/tomcat/conf/web.xml
docker cp server.xml tomcat:/usr/local/tomcat/conf/server.xml
#Refer https://dzone.com/articles/setting-ssl-tomcat-5-minutes
docker cp tomcat.keystore tomcat:/root/tomcat.keystore
docker restart tomcat

#Deployment of Documentum Administrator
docker cp da tomcat:/usr/local/tomcat/webapps

#Deployment of DCTM REST
docker cp dctm-rest tomcat:/usr/local/tomcat/webapps

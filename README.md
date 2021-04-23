Documentum 16.4 Docker (Postgres) with Documentum Administrator and DCTM REST
=============================================================================

Setup Instructions for Documentum Content Server with Documentum Administrator
on CentOS environment.

Prerequisites:
--------------

| Title                           | Description                                                                                                                            |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| CentOS Image (HOST)                   | 7 or 8                                                                                                                                 |
| contentserver_docker_ubuntu.tar | <https://mimage.opentext.com/support/ecm/secure/software/dell/documentum/documentumcontentserver/16.4/contentserver_docker_ubuntu.tar> |
| DA                     | <https://mimage.opentext.com/support/ecm/secure/software/dell/documentum/documentumadministrator/16.4/da.war>                                                                                                                                        |
| DCTM REST                     | <https://mimage.opentext.com/support/ecm/secure/software/dell/documentum/documentumrestservices/16.4/dctm-rest.war>                                                                                                                                        |
| Minimum RAM                     | 8 GB                                                                                                                                   |
| Minimum Storage                 | 40 GB                                                                                                                                  |

Implementation Steps
--------------------

The steps mentioned below are for Developer Environment. It is highly
recommended to follow product documentation for High Availability and Data
Recovery options.

### Setup Docker Engine with the Composer

The instructions below can also be used in other Unix OS, but if you already
know how to setup this, please use your local instructions and ignore this step!
We mindful to use latest composer version that supports version 3.0 compose
file.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sudo yum install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker your-user
systemctl start docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Create Documentum Bridge Network

This step is required for inter-docker communications. If you do not follow this
step, the database will not be reachable to Documentum Content Server.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker network create documentum
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Setup Postgres DB (not the latest!)

*Run Postgres Container*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run --network documentum --name postgres --hostname postgres -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres:9.6
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Prepare DB for Documentum Repository

This is being assumed that the repository name is *centdb* here. If you want to
create repository with another name, feel free to replace all (includes \*.yml
and other instructions in this repo)!

*Create Tablespace on Postgres Container*

`docker exec -it postgres su -c "mkdir /var/lib/postgresql/data/db_centdb_dat.dat" postgres`

*Test Connectivity on documentum bridge network*

`docker run --rm --network documentum mikesplain/telnet postgres 5432`

### Prepare Content Server and Repository

If you have not yet cloned this project, no issues! But open the files mentioned
below directly and copy paste the content to your local files (do name the files
as found).

Place the tar file (downloaded from OpenText), yml and profile files in your
working directory. The sample *yml* and *profile* files are attached!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tar -xvf contentserver_docker_ubuntu.tar
docker load -i Contentserver_Ubuntu.tar
source documentum-environment.profile
docker-compose -f CS-Docker-Compose_Stateless.yml up -d
docker logs -f centdb
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Give at least 30 minutes to finish this. Follow the next steps once you feel all went ok.

### Install Tomcat and Documentum Administrator with DCTM REST

The sample web.xml with disabled tag pooling has been attached. The da.war and dctm-rest.war are
the recompressed WAR files with the right dfc.properties. 
Sample dfc.properties is attached!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run --network documentum -d --name tomcat --hostname tomcat -p 8080:8080 tomcat
sleep 5s
docker cp web.xml tomcat:/usr/local/tomcat/conf/web.xml
docker restart tomcat
sleep 5s
docker cp da.war tomcat:/usr/local/tomcat/webapps
docker cp dctm-rest.war tomcat:/usr/local/tomcat/webapps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Test the Documentum Administrator and DCTM REST
<http://{CentOS-IP}:8080/da>

<http://{CentOS-IP}:8080/dctm-rest>

Next Steps
----------

If you are planning to setup xCP 16.4 environment, follow and download all mentioned files in the document below or simply follow some sections in https://github.com/amit17051980/DCTM-xCP-16.4.0/wiki.

https://github.com/amit17051980/documentum-16.4-docker/blob/master/README_xCP_Setup.pdf

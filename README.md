Documentum 16.4 Docker (Postgres) with Documentum Administrator
===============================================================

Setup Instructions for Documentum Content Server with Documentum Administrator
on CentOS environment.

Prerequisites:
--------------

| Title                           | Description                                                                                                                            |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| CentOS Image                    | 7 or 8                                                                                                                                 |
| contentserver_docker_ubuntu.tar | <https://mimage.opentext.com/support/ecm/secure/software/dell/documentum/documentumcontentserver/16.4/contentserver_docker_ubuntu.tar> |
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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run --rm --network documentum --name postgres --hostname postgres -e POSTGRES_PASSWORD=password -d -p 5432:5432 -v \$HOME/docker/volumes/postgres:/var/lib/postgresql/data postgres:9.6
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Prepare DB for Documentum Repository

This is being assumed that the repository name is *centdb* here. If you want to
create repository with another name, feel free to replace all (includes \*.yml
and other instructions in this repo)!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker exec -it postgres su -c "mkdir /var/lib/postgresql/data/db_centdb_dat.dat" postgres
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run --rm --network documentum mikesplain/telnet postgres 5432
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

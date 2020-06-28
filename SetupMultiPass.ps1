# Launch Ubuntu-18-LTS 
multipass launch --cpus 4 --disk 60G --mem 6G --name dctm-16-4 lts

# Mount the current directory on to created VM
multipass exec -v dctm-16-4 -- mkdir -p /home/ubuntu/media
multipass mount . dctm-16-4:/home/ubuntu/media

# Clone the project 
$user = read-host -Prompt "Enter GitHub User Name: "
$pass = Read-Host -Prompt "Enter GitHub Password: " -AsSecureString

multipass exec -v dctm-16-4 -- git config --global credential.helper store
multipass exec -v dctm-16-4 -- git clone https://${user}:${pass}@github.com/amit17051980/DCTM-xCP-16.4.0.git

# Install Docker & Docker Compose
multipass exec -v dctm-16-4 -- sudo snap install docker

# Compose Documentum DB, CS
$user = read-host -Prompt "Enter DockerHub User Name: "
$pass = Read-Host -Prompt "Enter DockerHub Password: "

multipass exec -v dctm-16-4 -- sudo docker login -u ${user} -p ${pass}
multipass exec -v dctm-16-4 -- bash -c ~/DCTM-xCP-16.4.0/Setup.sh




# Clone the project
multipass shell dctm-16-4
cd /home/ubuntu/project
ls -ltr

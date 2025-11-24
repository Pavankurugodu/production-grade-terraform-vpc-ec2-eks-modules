#!/bin/bash
set -e  # Exit on any error

# Update the system's package list
sudo apt update -y

# Install Java (OpenJDK 17 JRE) and required dependencies
sudo apt install fontconfig openjdk-17-jre -y

# Import the Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

// ...existing code...
# Import the Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins repository to the system's sources list (single valid line)
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Add the Jenkins repository to the system's sources list
#echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
#echo "https://pkg.jenkins.io/debian-stable binary/" | sudo tee -a /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package list again
sudo apt update -y

# Install Jenkins
sudo apt install jenkins -y

# Enable and start the Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 10  # Wait for Jenkins to start

# Add Docker's official GPG key and repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# ...existing code...
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# ...existing code...
# Update package index and install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# User group permission - use ubuntu user (common in AWS AMIs)
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

# Install dependencies and Trivy
sudo apt-get install -y wget apt-transport-https gnupg lsb-release snapd git
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# AWS CLI installation
sudo snap install aws-cli --classic

# Install Kubectl
sudo snap install kubectl --classic

# Helm installation
sudo snap install helm --classic

echo "All tools installed successfully!"
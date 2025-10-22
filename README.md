Step 1: Update and Install Prerequisites

Update your package lists and install necessary packages to allow apt to use a repository over HTTPS.
```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

Step 2: Add Docker's Official GPG Key

Add Docker's official GPG key to verify the downloaded packages.
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Step 3: Set up the Docker Repository

Add the Docker stable repository to your APT sources. This uses the codename of your specific Ubuntu version (like jammy, focal, etc.) to get the correct package list.
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Step 4: Install Docker Engine and Docker Compose V2

Update your package list again to pull the Docker packages, then install the core components and the Docker Compose plugin.
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Step 5: Verify the Installation

Check the versions to confirm everything is installed correctly:
```bash
docker --version
docker compose version
```

You should see output confirming both the Docker Engine and the Docker Compose V2 plugin are installed.

Step 6: Configure Non-Root User Access (Crucial EC2 Step)

The initial errors you had were due to permission denied issues. You must add the EC2 user (usually ubuntu) to the docker group to run commands without sudo.

  Add your user to the docker group:
  ```bash
  sudo usermod -aG docker $USER
  ```
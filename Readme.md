# 🐳 GitHub Actions Self-Hosted Runner (Dockerized)

This project provides a Dockerized GitHub Actions self-hosted runner that can be deployed on any host, including Windows, Linux, and macOS. It registers automatically with a GitHub repository or organization and runs workflows as assigned.

## 🚀 Features

- Fully Dockerized GitHub Actions self-hosted runner

- Automatic registration and deregistration

- Supports both repo-level and org-level runners

- Optional Docker-in-Docker support

- Custom labels and runner name

## 📁 Directory Structure

```plaintext
github-runner/
├── Dockerfile         # Defines runner environment
├── entrypoint.sh      # Bootstrap and cleanup logic
├── config.env         # Configurable environment variables
```

## 🔧 Configuration

Edit the `config.env` file to set your GitHub repository or organization details, runner token, name, and labels:

```plaintext# config.env

.env

REPO_URL=https://github.com/your-org/your-repo
RUNNER_TOKEN=your_runner_registration_token
RUNNER_NAME=dockerized-runner
RUNNER_LABELS=docker,linux,self-hosted
```

📝 Note: You can get the RUNNER_TOKEN via GitHub REST API:

- For repositories:
https://api.github.com/repos/OWNER/REPO/actions/runners/registration-token

- For organizations:
https://api.github.com/orgs/ORG/actions/runners/registration-token

## 🏗️ Build & Run

Build the Docker image:

```bash
docker build -t github-runner .
```

Run the Docker container:

```bash
docker run -d \
  --name my-gh-runner \
  --restart always \
  --env-file ./config.env \
  --volume "$(pwd)/_work:/runner/_work" \
  github-runner
```

To allow docker builds within workflows:
Add this volume mount:
> -v /var/run/docker.sock:/var/run/docker.sock

## 📦 Docker Compose (Optional)

If you prefer using Docker Compose, create a `docker-compose.yml` file:

```yaml
version: "3"
services:
  runner:
    build: .
    env_file: config.env
    volumes:
      - ./_work:/runner/_work
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
restart: always
Start with:
docker-compose up -d
```

## 🧹 Automatic Cleanup

The entrypoint script (`entrypoint.sh`) handles automatic cleanup on shutdown. It traps SIGINT and SIGTERM signals to deregister the runner from GitHub before exiting.

```bash
#!/bin/bash
set -e
cleanup() {
  echo "Deregistering runner..."
  ./config.sh remove --unattended --token "$RUNNER_TOKEN"
  exit 0
}
trap cleanup SIGINT SIGTERM
# Load config from env file or container env vars
REPO_URL=${REPO_URL:-"https://github.com/your-org/your-repo"}
RUNNER_TOKEN=${RUNNER_TOKEN:-"your_runner_registration_token"}
RUNNER_NAME=${RUNNER_NAME:-"dockerized-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"docker,linux,self-hosted"}
# Configure the runner
./config.sh --unattended \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work "_work"
# Run the runner
./run.sh &
wait $!
```

This ensures that when the container stops, the runner is properly deregistered from GitHub, preventing orphaned runners.
On shutdown (SIGINT/SIGTERM), the runner will deregister automatically from GitHub to avoid orphaned runners.

## ✅ Validation  

After running the container, you can validate the setup by checking the logs:

```bash
docker logs my-gh-runner
```

You should see messages indicating the runner has registered successfully.

```bash
# entrypoint.sh
#!/bin/bash
set -e
cleanup() {
  echo "Deregistering runner..."
  ./config.sh remove --unattended --token "$RUNNER_TOKEN"
  exit 0
}
trap cleanup SIGINT SIGTERM
# Load config from env file or container env vars
REPO_URL=${REPO_URL:-"https://github.com/your-org/your-repo"}
RUNNER_TOKEN=${RUNNER_TOKEN:-"your_runner_registration_token"}
RUNNER_NAME=${RUNNER_NAME:-"dockerized-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"docker,linux,self-hosted"}
# Configure the runner
./config.sh --unattended \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work "_work"
# Run the runner
./run.sh &
wait $!
```

Go to:

GitHub → Settings → Actions → Runners

You should see the registered runner with your defined name and labels.

## 🛑 Unregister Manually (if needed)

If you need to unregister the runner manually, you can run:

```bash
docker exec -it my-gh-runner ./config.sh remove --unattended --token YOUR_TOKEN
```

---

📄 License
MIT License
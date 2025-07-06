FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl jq git sudo unzip build-essential docker.io \
  && useradd -m runner

WORKDIR /home/runner

# Download the runner binary
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.315.0/actions-runner-linux-x64-2.315.0.tar.gz && \
    tar xzf actions-runner.tar.gz && rm actions-runner.tar.gz
RUN /home/runner/bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
RUN chown -R runner:runner /home/runner
USER runner

ENTRYPOINT ["./entrypoint.sh"]

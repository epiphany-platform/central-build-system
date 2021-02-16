FROM ubuntu:21.04

RUN apt-get update; apt-get install -y curl jq

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

RUN curl -LO https://aka.ms/downloadazcopy-v10-linux
RUN tar -xvf downloadazcopy-v10-linux
RUN chmod +x azcopy_linux_amd64_10.8.0/azcopy
RUN mv azcopy_linux_amd64_10.8.0/azcopy /usr/local/bin

RUN mkdir /app
COPY backup.sh /app/

WORKDIR /app
CMD ["/app/backup.sh"]

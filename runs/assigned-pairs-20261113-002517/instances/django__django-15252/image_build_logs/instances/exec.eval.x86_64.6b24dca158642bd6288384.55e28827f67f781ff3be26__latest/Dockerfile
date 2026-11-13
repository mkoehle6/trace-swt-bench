FROM --platform=linux/x86_64 exec.env.x86_64.6b24dca158642bd6288384:latest

COPY ./setup_repo.sh /root/
RUN /bin/bash /root/setup_repo.sh

WORKDIR /testbed/

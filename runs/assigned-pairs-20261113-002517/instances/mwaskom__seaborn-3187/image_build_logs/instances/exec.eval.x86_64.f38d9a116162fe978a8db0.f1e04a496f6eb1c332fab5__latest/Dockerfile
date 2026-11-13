FROM --platform=linux/x86_64 exec.env.x86_64.f38d9a116162fe978a8db0:latest

COPY ./setup_repo.sh /root/
RUN /bin/bash /root/setup_repo.sh

WORKDIR /testbed/

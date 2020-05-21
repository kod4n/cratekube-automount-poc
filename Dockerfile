FROM ubuntu:16.04
RUN apt-get update &&\
    apt-get install -y autofs cifs-utils bash curl ca-certificates &&\
    touch /etc/auto.cifs &&\
    echo "/auto /etc/auto.cifs" >> /etc/auto.master
WORKDIR /app
COPY app /app
ENTRYPOINT ["/app/entrypoint.sh"]

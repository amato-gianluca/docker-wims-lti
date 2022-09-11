FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y --no-install-recommends install \
      apache2 \
      libapache2-mod-wsgi-py3 \
      git \
      python3-pip

RUN git clone https://github.com/PremierLangage/wims-lti.git

WORKDIR wims-lti

RUN git checkout $DOCKER_TAG && ./install.sh

RUN mkdir data && \
    mv wimsLTI/config.py data/ && \
    mv db.sqlite3 data/  && \
    ln -s ../data/config.py wimsLTI && \
    ln -s data/db.sqlite3 . && \
    chown www-data: . -R

COPY apache.conf /etc/apache2/sites-available/wims-lti.conf

RUN a2ensite wims-lti

# Metadata
LABEL maintainer="Gianluca Amato <gianluca.amato.74@gmail.com>"
VOLUME /wims-lti/data
ENTRYPOINT [ "apachectl", "-D", "FOREGROUND" ]
EXPOSE 80/tcp

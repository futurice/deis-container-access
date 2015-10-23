FROM ubuntu:14.04
MAINTAINER Jussi Vaihia <jussi.vaihia@futurice.com>

WORKDIR /opt/app
RUN useradd -m app

# Configure apt to automatically select mirror
RUN echo "deb http://fi.archive.ubuntu.com/ubuntu/ trusty main restricted universe\n\
deb http://fi.archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe\n\
deb http://fi.archive.ubuntu.com/ubuntu/ trusty-security main restricted universe" > /etc/apt/sources.list
RUN apt-get update -y

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y \
    build-essential vim \
    libtool libreadline6 libreadline6-dev libncurses5-dev libffi-dev \
    python python-pip python-dev

RUN pip install gunicorn flask

RUN echo 'Europe/Helsinki' > /etc/timezone && rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /opt/app/static
RUN chown -R app /opt/app

USER app

COPY app.py /opt/app/app.py

EXPOSE 8000

USER root
CMD ["gunicorn", "app:app", "-b 0.0.0.0:8000"]

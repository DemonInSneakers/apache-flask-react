# File Author / Maintainer
MAINTAINER Ivan Kaigorodov

FROM node:12-alpine as client
WORKDIR /app
COPY ./client /app
RUN npm install
RUN npm run build


FROM python:3.6

RUN apt-get update && apt-get install -y apache2

# Copy over the apache configuration file and enable the site
COPY ./server/apache-flask.conf /etc/apache2/sites-available/apache-flask.conf
RUN a2ensite apache-flask
RUN a2enmod headers

# Copy over the wsgi file
COPY ./server/apache-flask.wsgi /var/www/apache-flask/apache-flask.wsgi

COPY ./server/app /var/www/apache-flask/app

RUN a2dissite 000-default.conf
RUN a2ensite apache-flask.conf

COPY --from=client /app/build  /var/www/apache-flask/app/templates

EXPOSE 80

WORKDIR /var/www/apache-flask

CMD  /usr/sbin/apache2ctl -D FOREGROUND
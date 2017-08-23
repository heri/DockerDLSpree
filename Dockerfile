FROM ubuntu:trusty
LABEL maintainer="heri <heri@studiozenkai.com>"

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get update && apt-get install -yq \
   build-essential \
   libcurl4-openssl-dev \
   libffi-dev \
   libreadline-dev \
   libssl-dev \
   libxml2-dev \
   libxslt1-dev \
   python-software-properties \
   zlib1g-dev \
    git \
    imagemagick \
    libmysqlclient-dev \
    mysql-server-5.5 \
    nodejs \
    pwgen \
    supervisor \
    zlib1g-dev \
    wget

# Ensure UTF-8
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    export LC_ALL=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Install Ruby
RUN cd /tmp/ && wget http://ftp.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz && tar -xzvf ruby-2.4.0.tar.gz && \
  rm -f ruby-2.4.0.tar.gz && \
  cd ruby-2.4.0 && \
  ./configure --disable-install-doc && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-2.4.0

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Install Ruby Gems
RUN gem install bundler

# Install Rails
RUN gem install rails -v 5.0.5

# Install Passenger
RUN gem install passenger -v=5.0.6

# Install Passenger module nginx
RUN passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx

# Copy configuration file
COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY supervisord-nginx.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# Generate self-signed certificate to enable HTTPS
RUN mkdir /opt/nginx/ssl_certs && \
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /opt/nginx/ssl_certs/nginx.key -out /opt/nginx/ssl_certs/nginx.crt \
    -subj '/O=Dell/OU=MarketPlace/CN=www.dell.com'

# Create directory for Nginx logs
RUN mkdir -p /var/log/nginx/

# Clean package cache
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY run.sh /run.sh
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
COPY create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# Install adapter for mysql
RUN gem install mysql2

# Install Spree
RUN gem install spree -v 3.2.3

# Install sidekiq
RUN gem install sidekiq

# Make ssh dir
RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
RUN chown -R root:root /root/.ssh
RUN ls -l /root/.ssh

# Create known_hosts
RUN touch /root/.ssh/known_hosts

# Add  key
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Create Rails application
RUN git clone git@github.com:heri/BC.git /app
# RUN rails _5.0.5_ new /app -s -d mysql

RUN cp -r /app /tmp/
RUN cp -r /opt/nginx/conf /tmp/

# Set volume folder for spree application files
VOLUME ["/app", "/var/lib/mysql","/opt/nginx/conf","/var/log/nginx"]

# Environmental variables
ENV MYSQL_PASS ""

# Expose port
EXPOSE 3306 3000 443 80 6379

CMD ["/run.sh"]
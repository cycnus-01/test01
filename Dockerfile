FROM centos:7
ENV container docker
#タイムゾーンをJSTに変更
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y update && \
    yum clean all && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
ENV LANG="ja_JP UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    TZ="Asia/Tokyo"

#unzipインストール
RUN yum update -y

# Apacheインストール
RUN yum install -y httpd

#unzipインストール
RUN yum install -y unzip

#cronインストール
# 通常のcronのインストール
RUN yum install -y cronie-noanacron
# anacronの削除
RUN yum remove -y cronie-anacron

#php composerインストール
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum install -y yum-utils
RUN yum-config-manager --disable 'remi-php*'
RUN yum-config-manager --enable remi-php81
RUN yum update -y
RUN yum -y install --enablerepo=remi,epel,remi-php80 php php-mysqlnd php-mbstring php-gd php-xml php-xmlrpc php-pecl-mcrypt php-fpm php-opcache php-apcu php-pear php-pdo php-zip php-unzip php-pecl-zip php-bcmath phpMyAdmin
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# node.js 導入
RUN yum install -y https://rpm.nodesource.com/pub_16.x/el/9/x86_64/nodesource-release-el9-1.noarch.rpm

# lsof は、サーバーで特定のポート番号を待ち受けているかどうか、指定ファイルは誰が読み込んでいるのかを調べる
RUN yum install -y nodejs \
    yum install -y vim \
    yum -y install lsof

# グローバル にgulpを導入
RUN npm install -g gulp

# ホストで用意した設定ファイルを反映
COPY ./docker/apache/httpd.conf /etc/httpd/conf/httpd.conf
COPY ./docker/apache/v_host.conf /etc/httpd/conf.d/v_host.conf
COPY ./docker/php/php.ini /etc/php.ini

#laravel
RUN composer global require "laravel/installer"

#公開ポート番号
EXPOSE 80

#コンテナ起動時、apacheとcronを起動
COPY command.sh /command.sh
RUN chmod 744 /command.sh
CMD ["/command.sh"]
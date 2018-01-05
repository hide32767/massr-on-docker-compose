FROM ruby:2.4.3-stretch
MAINTAINER hide32767 <hide.in@gmail.com>

RUN : \
    && apt -yqq update \
    && apt -yqq install apt-utils \
    && apt -yqq upgrade \
    && apt -yqq install locales build-essential nodejs openjdk-8-jre \
    && apt -yqq clean \
    && perl -i -pe 's/#\s(ja_JP.UTF-8 UTF-8)/$1/' /etc/locale.gen \
    && locale-gen \
    && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10 \
    && echo -e "install: --no-document\nupdate: --no-document" >/etc/gemrc \
    && groupadd webapp \
    && useradd -g webapp -m -s /bin/dash webapp \
    && mkdir -m 755 /srv/webapp \
    && chown webapp:webapp /srv/webapp

USER webapp
WORKDIR /srv/webapp
RUN : \
    && git clone https://github.com/tdtds/massr.git . \
    && echo "export LANG=ja_JP.utf8\nexport RACK_ENV='production'" >./.env \
    && chmod 600 .env \
    && . ./.env \
    && mkdir -p vendor/bundle \
    && bundle install --path vendor/bundle --quiet \
    && bundle exec rake assets:precompile

EXPOSE 9393:9393
ENTRYPOINT ["bundle", "exec", "puma", "--port", "9393"]

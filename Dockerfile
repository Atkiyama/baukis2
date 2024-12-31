FROM oiax/rails6-deps:latest

ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=16.20.0
ARG ARCH=arm64  
# 必要に応じて `arm64` に変更

RUN mkdir /var/mail
RUN groupadd -g $GID devel
RUN useradd -u $UID -g devel -m devel
RUN echo "devel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 必要なパッケージのインストール
RUN apk update && apk add --no-cache \
    curl \
    bash \
    openssl \
    shared-mime-info \
    ruby ruby-dev build-base \
    postgresql-dev \
    libstdc++ \
    libgcc \
    tar

# Node.jsをインストール (Alpineリポジトリを使用)
# RUN apk update && apk add --no-cache \
#     nodejs \
#     npm
# Node.jsの公式バイナリ（ARM向け）を使用してインストール
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.gz | \
    tar -xz -C /usr/local --strip-components=1 

WORKDIR /tmp


COPY init/Gemfile /tmp/Gemfile
COPY init/Gemfile.lock /tmp/Gemfile.lock
RUN bundle install

COPY ./apps /apps

RUN apk add --no-cache openssl shared-mime-info

# Rubyをアップデートするための行を追加
RUN apk update && apk add --no-cache ruby ruby-dev build-base && \
    gem install rubygems-update -v 3.2.33 && \
    update_rubygems && \
    gem update --system



USER devel

RUN openssl rand -hex 64 > /home/devel/.secret_key_base
RUN echo $'export SECRET_KEY_BASE=$(cat /home/devel/.secret_key_base)' \
  >> /home/devel/.bashrc

WORKDIR /apps

## 諸々インストール
## rspecもいるかも
RUN cd baukis2 && bundle install && bin/rails db:create

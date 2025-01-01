FROM ruby:2.7.8

# ビルド時引数の定義
ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=16.20.0
ARG ARCH=arm64

# Node.jsおよびyarnのインストール
# RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.gz | \
#     tar -xz -C /usr/local --strip-components=1 && \
#     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#     echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#     apt-get update && apt-get install -y --no-install-recommends yarn
RUN apt-get update -qq
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
&& apt-get install -y nodejs
RUN npm install --global yarn

# 必要なシステムパッケージのインストール
RUN apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    curl \
    bash \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 開発者ユーザーの作成
RUN groupadd -g $GID devel && \
   useradd -m -u $UID -g devel -s /bin/bash devel && \
   echo "devel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# アプリケーションの作業ディレクトリ
WORKDIR /tmp

# Gemfileのコピーとインストール
COPY init/Gemfile /tmp/Gemfile
COPY init/Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs=4 --retry=3

# アプリケーションコードのコピー
COPY ./apps /apps

# SECRET_KEY_BASEの生成
USER devel
RUN openssl rand -hex 64 > /home/devel/.secret_key_base && \
    echo "export SECRET_KEY_BASE=$(cat /home/devel/.secret_key_base)" >> /home/devel/.bashrc

# アプリケーションのディレクトリを作業ディレクトリとして設定
WORKDIR /apps

# データベースの作成（必要に応じてコメントアウト可能）
#RUN cd baukis2 && bundle install && bin/rails db:create


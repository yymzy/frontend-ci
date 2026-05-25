# =========================================
# Frontend CI Base Image
# Node.js 24.16.0 + npm/yarn/pnpm
# Python 3.12 + pip
# 国内淘宝/npmmirror镜像
# 适用于：
# - React
# - Next.js
# - Taro
# - Vue
# - 微信小游戏
# - Vite
# - Webpack
# - CI/CD
# =========================================

FROM node:24.16.0-bookworm

# 避免交互
ENV DEBIAN_FRONTEND=noninteractive

# 时区
ENV TZ=Asia/Shanghai

# Python & pip 镜像
ENV PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
ENV PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn

# npm 镜像
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# yarn 镜像
ENV YARN_REGISTRY=https://registry.npmmirror.com

# pnpm 镜像
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# =========================================
# 安装系统基础依赖
# =========================================
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    zip \
    tar \
    gzip \
    xz-utils \
    vim \
    nano \
    openssh-client \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    make \
    gcc \
    g++ \
    build-essential \
    libc6-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    sqlite3 \
    rsync \
    tree \
    procps \
    net-tools \
    iputils-ping \
    dnsutils \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# =========================================
# Python 配置
# =========================================
RUN ln -sf /usr/bin/python3 /usr/bin/python \
    && python --version \
    && pip3 --version

# pip 国内源
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip3 config set install.trusted-host pypi.tuna.tsinghua.edu.cn

# 升级 pip
RUN pip3 install --upgrade pip setuptools wheel

# =========================================
# Node.js 工具配置
# =========================================

# npm 国内源
RUN npm config set registry https://registry.npmmirror.com

# corepack
RUN corepack enable

# Yarn
RUN corepack prepare yarn@stable --activate

# pnpm
RUN corepack prepare pnpm@latest --activate

# yarn 国内源
RUN yarn config set registry https://registry.npmmirror.com

# pnpm 国内源
RUN pnpm config set registry https://registry.npmmirror.com

# =========================================
# 常用全局工具
# =========================================
RUN npm install -g \
    typescript \
    ts-node \
    vite \
    webpack \
    webpack-cli \
    turbo \
    rimraf \
    cross-env \
    concurrently \
    npm-check-updates \
    serve \
    http-server \
    eslint \
    prettier

# =========================================
# 微信/小程序相关常用依赖
# =========================================
RUN npm install -g \
    @tarojs/cli \
    miniprogram-ci

# =========================================
# Git 配置（避免 CI warning）
# =========================================
RUN git config --global init.defaultBranch main

# =========================================
# SSH known_hosts（避免首次连接卡住）
# =========================================
RUN mkdir -p /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && ssh-keyscan gitlab.com >> /root/.ssh/known_hosts

# =========================================
# 工作目录
# =========================================
WORKDIR /app

# =========================================
# 默认 shell
# =========================================
CMD ["bash"]
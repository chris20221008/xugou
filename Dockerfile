# 使用 Node.js 18 Alpine 作为基础镜像
FROM node:18-alpine

# 安装 cron 和 curl
RUN apk add --no-cache dcron curl

# 设置工作目录
WORKDIR /app

# 复制源代码
COPY . .

# 安装依赖
RUN cd frontend && npm install --include=dev && cd ../backend && npm install --include=dev

RUN npm run build

# 创建 crontab 文件
RUN echo '* * * * * curl "http://localhost:8080/__scheduled?cron=*+*+*+*+*" > /proc/1/fd/1 2>&1' > /etc/crontabs/root

# 创建启动脚本
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting cron daemon..."' >> /start.sh && \
    echo 'crond -f -d 8 &' >> /start.sh && \
    echo 'echo "Starting application..."' >> /start.sh && \
    echo 'npm run preview' >> /start.sh && \
    chmod +x /start.sh

# 暴露端口
EXPOSE 8080

# 启动服务
CMD ["/start.sh"]
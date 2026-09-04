FROM debian:bookworm-slim
WORKDIR /app
# COPY conf/requirement.txt .
COPY . .

RUN apt-get update && apt-get install --no-install-recommends -y nginx;

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
# VOLUME
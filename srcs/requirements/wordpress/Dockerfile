FROM debian:bookworm-slim
WORKDIR /app
# COPY conf/requirement.txt .
COPY . .

RUN apt-get update && apt-get install --no-install-recommends -y wordpress;

CMD ["/usr/sbin/wordpress", "-g", "daemon off;"]
# VOLUME
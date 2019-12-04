FROM openjdk:11.0.5-jre-stretch
ARG  KAFKA_DOWNLOAD_URL
RUN  apt-get update && \
     apt-get install -y procps && \
     bash -c "curl -O $KAFKA_DOWNLOAD_URL" && \
     FILE_NAME=$(find . -iname "kafka*" -type f) && \
     tar xzf $FILE_NAME && \
     rm -f $FILE_NAME && \
     EXT_DIR=$(basename $(find . -iname "kafka*" -type d)) && \
     mv $EXT_DIR /kafka
COPY kafka.sh kafka.sh
CMD ["/kafka.sh"]

FROM alpine

COPY ./tlapbot /usr/bin/tlapbot

RUN chmod +x /usr/bin/tlapbot

RUN adduser -D tlapbot

RUN chown -R tlapbot:tlapbot /home/tlapbot

USER tlapbot

WORKDIR /home/tlapbot

CMD ["/usr/bin/tlapbot"]

FROM ubuntu

# Set environment variables
ENV USER_NAME=tlapbot
ENV USER_ID=1000
ENV GROUP_ID=1000

COPY ./tlapbot /usr/bin/tlapbot

RUN chmod +x /usr/bin/tlapbot

# Create a non-root user with a specified UID and GID
RUN groupadd -g $GROUP_ID $USER_NAME && \
    useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash $USER_NAME

USER tlapbot

WORKDIR /home/tlapbot

CMD ["/usr/bin/tlapbot"]

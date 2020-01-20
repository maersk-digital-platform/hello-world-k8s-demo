FROM python:3.7.3-alpine3.9

RUN apk --no-cache add ca-certificates curl jq bash

RUN cd
WORKDIR /app

RUN \
    # Install kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/1.14.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl;

COPY ./src /app
COPY ./requirements.txt /app
COPY ./startup.sh /app

RUN pip install -r requirements.txt

EXPOSE 80

RUN chmod +x startup.sh
ENTRYPOINT ["/bin/bash", "startup.sh"]

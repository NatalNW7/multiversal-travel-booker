FROM crystallang/crystal

RUN apt-get update && apt-get install -y postgresql-client

COPY . /api

WORKDIR /api

EXPOSE 3000

ENTRYPOINT [ "/usr/bin/bash", "entrypoint.sh" ]
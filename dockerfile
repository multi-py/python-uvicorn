ARG version=3.9
ARG build_target=$version
ARG publish_target=$version
FROM python:$build_target

RUN pip install uvicorn[standard]


FROM python:$publish_target

LABEL maintainer="Robert Hafner <tedivm@tedivm.com>"

ARG version
COPY --from=0 /usr/local/lib/python$version /usr/local/lib/python$version

COPY ./assets/start.sh /start.sh
RUN chmod +x /start.sh

COPY ./assets/main.py /app/main.py
WORKDIR /app/

ENV PYTHONPATH=/app

CMD ["/start.sh"]

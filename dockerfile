ARG version=3.9
ARG build_target=$version
ARG publish_target=$version

FROM python:$build_target as Builder

# Add build_target to container scope
ARG build_target

# Only add build tools for alpine image. The ubuntu based images have build tools already.
RUN if [[ "$build_target" == *"alpine" ]] ; then apk add build-base ; fi

# Install uvicorn and build all of it's fancy C dependencies.
RUN pip install uvicorn[standard]

# Build our actual container now
FROM python:$publish_target
LABEL maintainer="Robert Hafner <tedivm@tedivm.com>"

# Add version to container scope.
ARG version

# Copy all of the python files built in the Builder container into this smaller container.
COPY --from=Builder /usr/local/lib/python$version /usr/local/lib/python$version

# Startup Script
COPY ./assets/start.sh /start.sh
RUN chmod +x /start.sh

# Example application so container "works" when run directly.
COPY ./assets/main.py /app/main.py
WORKDIR /app/

ENV PYTHONPATH=/app

CMD ["/start.sh"]

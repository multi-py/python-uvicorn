ARG python_version=3.9
ARG build_target=$python_version
ARG publish_target=$python_version

FROM python:$build_target as Builder

# Add arguments to container scope
ARG build_target
ARG package
ARG package_version

# Only add build tools for alpine image. The ubuntu based images have build tools already.
# Only runs if `apk` is on the system.
RUN if which apk ; then apk add python3-dev libffi-dev libevent-dev build-base bash; fi

# Install rust on alpine if not using linux/arm/v7
RUN bash -c 'if which apk && [[ "$TARGETPLATFORM" != "linux/arm/v7" ]] ; then apk add cargo rust gcc musl-dev; fi'


# Install packaer and build all dependencies.
RUN pip install $package==$package_version


# Install limited packages on linux/arm/v7- exclude anything relying on Rust.
RUN bash -c 'if [[ "$TARGETPLATFORM" == "linux/arm/v7" ]] ; then pip install uvicorn==$package_version websockets>=10.0 httptools>=0.4.0 uvloop>=0.14.0,!=0.15.0,!=0.15.1 python-dotenv>=0.13 PyYAML>=5.1 ; fi'
RUN bash -c 'if [[ "$TARGETPLATFORM" != "linux/arm/v7" ]] ; then pip install uvicorn[standard]==$package_version ; fi'




# Build our actual container now.
FROM python:$publish_target

# Add args to container scope.
ARG publish_target
ARG python_version
ARG package
ARG maintainer=""
ARG TARGETPLATFORM=""
LABEL python=$python_version
LABEL package=$package
LABEL maintainer=$maintainer
LABEL org.opencontainers.image.description="python:$publish_target $package:$package_version $TARGETPLATFORM"


# Copy all of the python files built in the Builder container into this smaller container.
COPY --from=Builder /usr/local/lib/python$python_version /usr/local/lib/python$python_version

# Startup Script
COPY ./assets/start.sh /start.sh
RUN chmod +x /start.sh

# Example application so container "works" when run directly.
COPY ./assets/main.py /app/main.py
WORKDIR /app/

ENV PYTHONPATH=/app

CMD ["/start.sh"]

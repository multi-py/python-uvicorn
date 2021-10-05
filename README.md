# Python Uvicorn Docker Containers

A multiarchitecture container image for running Python with Uvicorn.

Looking for the containers? [Head over to the Github Container Registry](https://github.com/tedivm/python-uvicorn/pkgs/container/python-uvicorn)!

## Tags

* `latest`
* `3.9`
* `3.9-slim`
* `3.9-alpine`
* `3.8`
* `3.8-slim`
* `3.8-alpine`
* `3.7`
* `3.7-slim`
* `3.7-alpine`
* `3.6`
* `3.6-slim`
* `3.6-alpine`

Images are rebuilt weekly so patch/bugfix releases come quickly and all containers use the latest version of uvicorn.

There are also dated tags (ie, `3.9-21.10.05`) that can be used when automatic updates aren't desired.

Head over to the registry for a [full listing of tags](https://github.com/tedivm/python-uvicorn/pkgs/container/python-uvicorn).

## Features

### Mutli Architecture Builds

Every tag in this repository supports these architectures:

* linux/amd64
* linux/arm64
* linux/arm/v7


### Small Images

Despite having to custom compile uvloop for different architectures this project manages to keep images small. It does so by using a multistaged build to compile the requirements in one image and then move them into the final image that gets published, ensuring that the build tools and artifacts get saved into the container.


### No Rate Limits

This project uses the Github Container Registry to store images, which have no rate limiting on pulls (unlike Docker Hub).


## How To

### Add Your App

By default the startup script checks for the following packages and uses the first one it can find-

* `/app/app/main.py`
* `/app/main.py`

If you are using pip to install dependencies your dockerfile could look like this-

```dockerfile
FROM ghcr.io/tedivm/python-uvicorn:3.9

COPY requirements /requirements
RUN pip install --no-cache-dir -r /requirements
COPY ./app app
```


### Multistage Example

In this example we use a multistage build to compile our libraries in one container and then move them into the container we plan on using. This creates small containers while avoiding the frustration of installing build tools in a piecemeal way.

```dockerfile
FROM ghcr.io/tedivm/python-uvicorn:3.9

# Build any packages in the bigger container with all the build tools
COPY requirements /requirements
RUN pip install --no-cache-dir -r /requirements


FROM ghcr.io/tedivm/python-uvicorn:3.9-slim

# Copy the compiled python libraries from the first stage
COPY --from=0 /usr/local/lib/python3.9 /usr/local/lib/python3.9

COPY ./app app
```


### PreStart Script

When the container is launched it will run the script at `/app/prestart.sh` before starting the uvicorn service. This is an ideal place to put things like database migrations.


## Environmental Variables

### `PORT`

The port that the application inside of the container will listen on. This is different from the host port that gets mapped to the container.


### `LOG_LEVEL`

The uvicorn log level. Must be one of the following:

* `critical`
* `error`
* `warning`
* `info`
* `debug`
* `trace`


### `MODULE_NAME`

The python module that uvicorn will import. This value is used to generate the APP_MODULE value.


### `VARIABLE_NAME`

The python variable containing the ASGI application inside of the module that uvicorn imports. This value is used to generate the APP_MODULE value.


### `APP_MODULE`

The python module and variable that is passed to uvicorn. When used the `VARIABLE_NAME` and `MODULE_NAME` environmental variables are ignored.


### `PRE_START_PATH`

Where to find the prestart script.


### `RELOAD`

When this is set to the string `true` uvicorn is launched in reload mode. If any files change uvicorn will reload the modules again, allowing for quick debugging. This comes at a performance cost, however, and should not be enabled on production machines.

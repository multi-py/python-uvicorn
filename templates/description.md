
A multiarchitecture container image for running Python with Uvicorn.

Looking for the containers? [Head over to the Github Container Registry](https://github.com/multi-py/python-uvicorn/pkgs/container/python-uvicorn)!

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




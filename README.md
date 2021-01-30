# Customized Nuxeo Docker container

[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/djanta/docker-nuxeo-server)](https://github.com/djanta/docker-nuxeo-server)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/djanta/docker-nuxeo-server?color=brightgreen&include_prereleases)](https://github.com/djanta/docker-nuxeo-server)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/djanta/docker-server)](https://github.com/djanta/docker-nuxeo-server)
[![stars badge](https://img.shields.io/docker/stars/djanta/nuxeo-server.svg)](https://github.com/djanta/docker-nuxeo-server)
[![pull badge](https://img.shields.io/docker/pulls/djanta/nuxeo-server.svg)](https://github.com/djanta/docker-nuxeo-server)
[![Docker image](https://images.microbadger.com/badges/image/djanta/nuxeo-server.svg)](https://microbadger.com/images/djanta/nuxeo-server)

> 8.8.211, 9.8.211, 10.8.211

## Getting Started

These instructions will cover usage information and for the docker container

## Introduction

The main purposes of this project are to provide a high-level container that comes up with the minimum and essentials tools required by `Nuxeo`
the framework to be functioning. Please do keep in mind that, this container will not bring up the `Nuxeo` server instance.

## Main tools

First of all, base on many feedback inquiries we've got, I can stress enough that, this `SDK` image comes up with different `*nix` based distribution.
As for today, we've not published any `windows` based distribution. In our team and for most of our clients, we mostly use this `OpenJDK` version, but you are free to
choose your favorite distribution (as long as you're able to manage distribution specific problems without help from
US).

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

_*After, you need to set up following tools. Just go on official websites to see setup instructions.*_

### Build from

All our customized nuxeo container listed here are built from [parent SDK container](https://hub.docker.com/repository/docker/djanta/docker-server/tags?page=1&ordering=last_updated)

## Supported Distribution

| Platform                     | Versions            | 
| ----------------------------: | ------------------- |
| Debian                       | nuxeo-sdk{{denian}}  |
| Ubuntu                       | nuxeo-sdk{{ubuntu}}  |
| CentOS                       | -                    |
| Oracle Linux7                | -                    | 

In addition, runtime support is provided for the following platform:

|  |  linux/386 | linux/amd64   | linux/arm64   |
| -------- | :--------: | :--------: | :--------: |
| Debian | √ | √ |√ |
| Ubuntu | √ | √ |√ |

### Versioning format

This package versioning format is based on a combinaison of first two digit of `Nuxeo` LTS, the `JDK` version id and follow by a conbinaison of
the first two digit of the day and first tow digit of the current build month. Thereby, a build version if LTS 2019, with `JDK 8` on January 21st, 2021 will be
formatted as follow: `10.8.211`.

As part of the basic built version, the `nuxeo-server` container is also tagged with a scpecific distribution such as but not limited: `debian`, `ubuntu`. For our full
provisioned distribtion architecture, please visit [docker hub](https://hub.docker.com/r/djanta/nuxeo-server/tags?page=1&ordering=last_updated) or refer the matrix above
[table](#Supported Distribution)

#### Usage

As requested with the request this bundle can be run within the command bellow:

```sh
docker pull djanta/docker-server:{{version}}-{{distribution}}

# Example for the heaviest version 
docker pull djanta/docker-server:10.8.211-debian
```

## Where from?
As we're making all our containers to be largely available and easier to use, we'll be distributing this images through the following registries:

|                           |                           |      |
| -------------------------:|:------------------------- |:----:|
| **Docker Registry**       | [docker hub](https://hub.docker.com/r/djanta/nuxeo-server/tags?page=1&ordering=last_updated)             | √    |
| **Github Registry**       | [Github]()     | X    |
| **Openshift Registry**    |                           | X    |
| **Amazon Registry**       |                           | X    |

## Usage

### Quick Start (for localhost development) on the fly

```shell
docker run it --rm --name nuxeo-server{{version}} -p 8080:8080 djanta/nuxeo-server:{{version}}
```

When you create and start a new container `djanta/nuxeo-server:{{version}}`, on the fly, Keep in mind that, the default configuration is bare-bones and has no content.
Therefore, the container will be expposed through the port `8080` and support an embedded database (H2) only.

> TIP: By default, the server will start in dev mode. Please consider using `NUXEO_DEV_MODE` as part of your container environment and set it to `false`

If you are new to Nuxeo and want to see the demo content and template samples data and documents that are used in the [Documentation](https://doc.nuxeo.com) and tutorials on [Nuxeo University](https://university.nuxeo.com), 
concider using the following environment variable`NUXEO_PACKAGES` to pass all desired package you witch to install. You might also consider using deploying those package through the [config.d](#config.d) volume or your [package.d](#package.d)

> TIP: Once the container started, open your browser to http://localhost:8080/ and log in with Administrator/Administrator if you have not deploy any specific user configuration contribution. 
Considere also set the environment `SKIP_WIZARD` to `true` or `false` whether you want to bypass the configuration wizard.

### Getting Started (dev or production)

For the purpose of this documentation, we'll be using the server `djanta/nuxeo-server:10.8.211-debian`

> Note: As for now, this image is available for `Nuxeo` LTS (2019, 2017, 2015).

```shell
docker run --rm -ti --name nuxeo-server-10 \
  -p 8080:8080 \
  djanta/nuxeo-server:10.8.211-debian
```

#### Start a nuxeo with additional packages

This image has been built with the ability to start a new container with your own external packages. To do so, just pass the list of those through the environment varialbe: `NUXEO_PACKAGES`

```shell
docker run --rm -it --name nuxeo-server-10 \
  -p 8080:8080 \
  -e NUXEO_PACKAGES="nuxeo-template-rendering-samples ..." \
  djanta/nuxeo-server:10.8.211-debian
```
> Note: Eache image has been built with the following embedded packages: `nuxeo-web-ui, nuxeo-jsf-ui,nuxeo-dam,nuxeo-template-rendering,nuxeo-liveconnect`

To facilitated the usage and the configuration of this custom `Nuxeo` container, you can also have a look at out preset `docker compose` and `k8s` [configuration](https://github.com/djanta/docker-nuxeo-bundle) or use it as follow:

```
  # Check out the entire project to get default configuration files
  git clone https://github.com/djanta/docker-nuxeo-bundle.git
  cd docker-nuxeo-bundle
```

The default configuration is bare-bones and has no content.
```
  # To start nuxeo with external container for postgres, elasticsearch
  ./run --profile=nuxeo --bundle="postgres,elasticsearch" --shortcut="nuxeo.local"
```

## Custom Configuration

This image provide an entry with the ability to let you extend or customized the default `Nuxeo` config file. This customization can be done whether through:

### Custom configuration template (nuxeo.conf)

Your own defaut `nuxeo.conf` template can be contributed through a mount volume to `/var/lib/nuxeo/nuxeo.conf`

#### Usage 

```shell
docker run --rm -it --name nuxeo-server-10 \
  -p 8080:8080 \
  -v $PWD/nuxeo.conf:/var/lib/nuxeo/nuxeo.conf:ro \
  djanta/nuxeo-server:10.8.211-debian
```

### Configuration through custom script (bash)

To run your custom configuration shell scripts, when starting a new container from any of our [Nuxeo image](https://hub.docker.com/r/djanta/nuxeo-server), 
you can then map any of you script `*.sh` files from an external volume mounted at `/var/lib/nuxeo/config.d`.

> Note: In some cases, for testing or sandbox purpose, you'd like to have a shared configuration script and some specific script for a specific environment. If so, we've got you covered by provisioning the following variable: `DEPLOY_ENV`

#### Config.d (Folder Structure)

```shell
ls -ls $PWD/config.d
total 200
 8 -rwxr-xr-x  1 stanislas  001-default.sh
 8 -rwxr-xr-x  1 stanislas  cache.sh
 8 -rwxr-xr-x  1 stanislas  certificate.sh
 8 -rwxr-xr-x  1 stanislas  database.sh
 0 drwxr-xr-x  24 stanislas dev                 # Placeholder for extended script for development environment
 0 drwxr-xr-x  24 stanislas sandbox             # Placeholder for extended script for sandbox environment
 0 drwxr-xr-x  24 stanislas staging             # Placeholder for extended script for staging environment
 ...
```

#### Usage

> Tip: Make sure to mount the volume `/var/lib/nuxeo/config.d` with read only as e.g: `:ro`

```shell
docker run --rm -it --name nuxeo-server-10 \
  -p 8080:8080 \
  -v ${NX_CONFIGD_PATH:-./data}/config.d:/var/lib/nuxeo/config.d:ro \
  djanta/nuxeo-server:10.8.211-debian
```
or as follow to use an extended environmental script. e.g: `sandbox`

```shell
docker run --rm -it --name nuxeo-server-10 \
  -p 8080:8080 \
  - e DEPLOY_ENV="sandbox"
  -v ${NX_CONFIGD_PATH:-./data}/config.d:/var/lib/nuxeo/config.d:ro \
  djanta/nuxeo-server:10.8.211-debian
```

### External package deployment

This image has a builtin feature that aim to provide a through for the end user to install any extra `bundle`, `hotfix` or `markertplace` dependency.


## Runtime SDK Variable

### Imagemagick

To customized the container provided imagemagick configuration, any of the environment bellow can be customized and definied through the environment for container enviroment.

|                           |                           |
| -------------------------:|:------------------------- |
| MAGICK_AREA_LIMIT|	Set the maximum width * height of an image that can reside in the pixel cache memory. Images that exceed the area limit are cached to disk (see MAGICK_DISK_LIMIT) and optionally memory-mapped.|
| MAGICK_CODER_FILTER_PATH|	Set search path to use when searching for filter process modules (invoked via -process). This path permits the user to extend ImageMagick's image processing functionality by adding loadable modules to a preferred location rather than copying them into the ImageMagick installation directory. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.|
| MAGICK_CODER_MODULE_PATH|	Set path where ImageMagick can locate its coder modules. This path permits the user to arbitrarily extend the image formats supported by ImageMagick by adding loadable coder modules from an preferred location rather than copying them into the ImageMagick installation directory. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.|
| MAGICK_CONFIGURE_PATH|	Set path where ImageMagick can locate its configuration files. Use this search path to search for configuration (.xml) files. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.|
| MAGICK_DEBUG|	Set debug options. See -debug for a description of debugging options.|
| MAGICK_DISK_LIMIT|	Set maximum amount of disk space in bytes permitted for use by the pixel cache. When this limit is exceeded, the pixel cache is not be created and an error message is returned.|
| MAGICK_ERRORMODE|	Set the process error mode (Windows only). A typical use might be a value of 1 to prevent error mode dialogs from displaying a message box and hanging the application.|
| MAGICK_FILE_LIMIT|	Set maximum number of open pixel cache files. When this limit is exceeded, any subsequent pixels cached to disk are closed and reopened on demand. This behavior permits a large number of images to be accessed simultaneously on disk, but with a speed penalty due to repeated open/close calls.|
| MAGICK_FONT_PATH|	Set path ImageMagick searches for TrueType and Postscript Type1 font files. This path is only consulted if a particular font file is not found in the current directory.|
| MAGICK_HEIGHT_LIMIT|	Set the maximum height of an image.|
| MAGICK_HOME|	Set the path at the top of ImageMagick installation directory. This path is consulted by uninstalled builds of ImageMagick which do not have their location hard-coded or set by an installer.|
| MAGICK_LIST_LENGTH_LIMIT|	Set the maximum length of an image sequence.|
| MAGICK_MAP_LIMIT|	Set maximum amount of memory map in bytes to allocate for the pixel cache. When this limit is exceeded, the image pixels are cached to disk (see MAGICK_DISK_LIMIT).|
| MAGICK_MEMORY_LIMIT|	Set maximum amount of memory in bytes to allocate for the pixel cache from the heap. When this limit is exceeded, the image pixels are cached to memory-mapped disk (see MAGICK_MAP_LIMIT).|
| MAGICK_OCL_DEVICE|	Set to off to disable hardware acceleration of certain accelerated algorithms (e.g. blur, convolve, etc.).|
| MAGICK_PRECISION|	Set the maximum number of significant digits to be printed.|
| MAGICK_SHRED_PASSES|	If you want to keep the temporary files ImageMagick creates private, overwrite them with zeros or random data before they are removed. On the first pass, the file is zeroed. For subsequent passes, random data is written.|
| MAGICK_SYNCHRONIZE|	Set to "true" to ensure all image data is fully flushed and synchronized to disk. There is a performance penalty, however, the benefits include ensuring a valid image file in the event of a system crash and early reporting if there is not enough disk space for the image pixel cache.|
| MAGICK_TEMPORARY_PATH|	Set path to store temporary files.|
| MAGICK_THREAD_LIMIT|	Set maximum parallel threads. Many ImageMagick algorithms run in parallel on multi-processor systems. Use this environment variable to set the maximum number of threads that are permitted to run in parallel.|
| MAGICK_THROTTLE_LIMIT|	Periodically yield the CPU for at least the time specified in milliseconds.|
| MAGICK_TIME_LIMIT|	Set maximum time in seconds. When this limit is exceeded, an exception is thrown and processing stops.|
| MAGICK_WIDTH_LIMIT|	Set the maximum width of an image.|
| SOURCE_DATE_EPOCH|	A UNIX timestamp, defined as the number of seconds, excluding leap seconds, since 01 Jan 1970 00:00:00 UTC.|

## Contributing

Please read [CONTRIBUTING.md](https://github.com/djanta/docker-nuxeo-server/blob/master/CONTRIBUTING.md) for details on
our code of conduct, and the process for submitting pull requests to us.

## License

|                |                                                                  |
| -------------- | ---------------------------------------------------------------- |
| **Author:**    | [Koffi Stanislas ASSOUTOVI](https://github.com/stanislaska)      |
| **License:**   | [The MIT License (MIT)](https://github.com/djanta/docker-nuxeo-server/blob/master/LICENSE)                                            |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://github.com/djanta/docker-nuxeo-server/blob/master/LICENSE

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

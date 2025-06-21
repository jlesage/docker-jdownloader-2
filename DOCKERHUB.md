# Docker container for JDownloader 2
[![Release](https://img.shields.io/github/release/jlesage/docker-jdownloader-2.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-jdownloader-2/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/jdownloader-2/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/jdownloader-2?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/jdownloader-2?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-jdownloader-2/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-jdownloader-2/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-jdownloader-2)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [JDownloader 2](http://jdownloader.org).

The graphical user interface (GUI) of the application can be accessed through a
modern web browser, requiring no installation or configuration on the client

---

[![JDownloader 2 logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png&w=110)](http://jdownloader.org)[![JDownloader 2](https://images.placeholders.dev/?width=416&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=JDownloader%202&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](http://jdownloader.org)

JDownloader 2 is a free, open-source download management tool with a huge
community of developers that makes downloading as easy and fast as it should be.
Users can start, stop or pause downloads, set bandwith limitations, auto-extract
archives and much more. It's an easy-to-extend framework that can save hours of
your valuable time every day!

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is an example, and parameters
    should be adjusted to suit your needs.

Launch the JDownloader 2 docker container with the following command:
```shell
docker run -d \
    --name=jdownloader-2 \
    -p 5800:5800 \
    -v /docker/appdata/jdownloader-2:/config:rw \
    -v /home/user/Downloads:/output:rw \
    jlesage/jdownloader-2
```

Where:

  - `/docker/appdata/jdownloader-2`: Stores the application's configuration, state, logs, and any files requiring persistency.
  - `/home/user/Downloads`: This is where downloaded files are stored.

Access the JDownloader 2 GUI by browsing to `http://your-host-ip:5800`.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-jdownloader-2.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-jdownloader-2/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.

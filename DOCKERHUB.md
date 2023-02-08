# Docker container for JDownloader 2
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/jdownloader-2/latest)](https://hub.docker.com/r/jlesage/jdownloader-2/tags) [![Build Status](https://github.com/jlesage/docker-jdownloader-2/actions/workflows/build-image.yml/badge.svg?branch=master)](https://github.com/jlesage/docker-jdownloader-2/actions/workflows/build-image.yml) [![GitHub Release](https://img.shields.io/github/release/jlesage/docker-jdownloader-2.svg)](https://github.com/jlesage/docker-jdownloader-2/releases/latest) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/JocelynLeSage)

This is a Docker container for [JDownloader 2](http://jdownloader.org).

The GUI of the application is accessed through a modern web browser (no
installation or configuration needed on the client side) or via any VNC client.

---

[![JDownloader 2 logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png&w=110)](http://jdownloader.org)[![JDownloader 2](https://images.placeholders.dev/?width=416&height=110&fontFamily=Georgia,sans-serif&fontWeight=400&fontSize=52&text=JDownloader%202&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](http://jdownloader.org)

JDownloader 2 is a free, open-source download management tool with a huge
community of developers that makes downloading as easy and fast as it should be.
Users can start, stop or pause downloads, set bandwith limitations, auto-extract
archives and much more. It's an easy-to-extend framework that can save hours of
your valuable time every day!

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

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
  - `/docker/appdata/jdownloader-2`: This is where the application stores its configuration, states, log and any files needing persistency.
  - `/home/user/Downloads`: This is where downloaded files are stored.

Browse to `http://your-host-ip:5800` to access the JDownloader 2 GUI.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-jdownloader-2.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-jdownloader-2/issues

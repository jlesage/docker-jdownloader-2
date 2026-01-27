# Docker container for JDownloader 2
[![Release](https://img.shields.io/github/release/jlesage/docker-jdownloader-2.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-jdownloader-2/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/jdownloader-2/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/jdownloader-2?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/jdownloader-2?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/jdownloader-2)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-jdownloader-2/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-jdownloader-2/actions/workflows/build-image.yml)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This project provides a Docker container for [JDownloader 2](https://jdownloader.org).

The graphical user interface (GUI) of the application can be accessed through a
modern web browser, requiring no installation or configuration on the client
side, or via any VNC client.

> [!NOTE]
> This Docker container is entirely unofficial and not made by the creators of
> JDownloader 2.

---

[![JDownloader 2 logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png&w=110)](https://jdownloader.org)[![JDownloader 2](https://images.placeholders.dev/?width=416&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=JDownloader%202&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://jdownloader.org)

JDownloader 2 is a free, open-source download management tool with a huge
community of developers that makes downloading as easy and fast as it should be.
Users can start, stop or pause downloads, set bandwith limitations, auto-extract
archives and much more. It's an easy-to-extend framework that can save hours of
your valuable time every day!

---

## Table of Contents

   * [Quick Start](#quick-start)
   * [Usage](#usage)
      * [Environment Variables](#environment-variables)
         * [Deployment Considerations](#deployment-considerations)
      * [Data Volumes](#data-volumes)
      * [Ports](#ports)
      * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
      * [Docker Compose File](#docker-compose-file)
   * [Docker Image Versioning and Tags](#docker-image-versioning-and-tags)
   * [Docker Image Update](#docker-image-update)
      * [Synology](#synology)
      * [unRAID](#unraid)
   * [User/Group IDs](#usergroup-ids)
   * [Accessing the GUI](#accessing-the-gui)
   * [Security](#security)
      * [SSVNC](#ssvnc)
      * [Certificates](#certificates)
      * [VNC Password](#vnc-password)
      * [Web Authentication](#web-authentication)
         * [Configuring Users Credentials](#configuring-users-credentials)
   * [Reverse Proxy](#reverse-proxy)
      * [Routing Based on Hostname](#routing-based-on-hostname)
      * [Routing Based on URL Path](#routing-based-on-url-path)
   * [Web Control Panel](#web-control-panel)
   * [Automatic Clipboard Sync](#automatic-clipboard-sync)
   * [Web Audio](#web-audio)
   * [Web File Manager](#web-file-manager)
   * [Web Notifications](#web-notifications)
   * [GPU Acceleration Support](#gpu-acceleration-support)
   * [Shell Access](#shell-access)
   * [MyJDownloader](#myjdownloader)
      * [Direct Connection](#direct-connection)
   * [Click'n'Load](#clicknload)
   * [Troubleshooting](#troubleshooting)
      * [JDownloader Fails to Start](#jdownloader-fails-to-start)
   * [Support or Contact](#support-or-contact)

## Quick Start

> [!IMPORTANT]
> The Docker command provided in this quick start is an example, and parameters
> should be adjusted to suit your needs.

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

## Usage

```shell
docker run [-d] \
    --name=jdownloader-2 \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    jlesage/jdownloader-2
```

| Parameter | Description |
|-----------|-------------|
| -d        | Runs the container in the background. If not set, the container runs in the foreground. |
| -e        | Passes an environment variable to the container. See [Environment Variables](#environment-variables) for details. |
| -v        | Sets a volume mapping to share a folder or file between the host and the container. See [Data Volumes](#data-volumes) for details. |
| -p        | Sets a network port mapping to expose an internal container port to the host). See [Ports](#ports) for details. |

### Environment Variables

To customize the container's behavior, you can pass environment variables using
the `-e` parameter in the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as. See [User/Group IDs](#usergroup-ids) for details. | `1000` |
|`GROUP_ID`| ID of the group the application runs as. See [User/Group IDs](#usergroup-ids) for details. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs for the application. | (no value) |
|`UMASK`| Mask controlling permissions for newly created files and folders, specified in octal notation. By default, `0022` ensures files and folders are readable by all but writable only by the owner. See the umask calculator at http://wintelguy.com/umask-calc.pl. | `0022` |
|`LANG`| Sets the [locale](https://en.wikipedia.org/wiki/Locale_(computer_software)), defining the application's language, if supported. Format is `language[_territory][.codeset]`, where language is an [ISO 639 language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), territory is an [ISO 3166 country code](https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes), and codeset is a character set, like `UTF-8`. For example, Australian English using UTF-8 is `en_AU.UTF-8`. | `en_US.UTF-8` |
|`TZ`| [TimeZone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones) used by the container. The timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application is automatically restarted if it crashes or terminates. | `0` |
|`APP_NICENESS`| Priority at which the application runs. A niceness value of `-20` is the highest, `19` is the lowest and `0` the default. **NOTE**: A negative niceness (priority increase) requires additional permissions. The container must be run with the Docker option `--cap-add=SYS_NICE`. | `0` |
|`INSTALL_PACKAGES`| Space-separated list of packages to install during container startup. List of available packages can be found at https://pkgs.alpinelinux.org. | (no value) |
|`PACKAGES_MIRROR`| Mirror of the repository to use when installing packages. List of mirrors is available at https://mirrors.alpinelinux.org. | (no value) |
|`CONTAINER_DEBUG`| When set to `1`, enables debug logging. | `0` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1920` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `1080` |
|`DARK_MODE`| When set to `1`, enables dark mode for the application. See Dark Mode](#dark-mode) for details. | `0` |
|`WEB_AUDIO`| When set to `1`, enables audio support, allowing audio produced by the application to play through the browser. See [Web Audio](#web-audio) for details. | `0` |
|`WEB_FILE_MANAGER`| When set to `1`, enables the web file manager, allowing interaction with files inside the container through the web browser, supporting operations like renaming, deleting, uploading, and downloading. See [Web File Manager](#web-file-manager) for details. | `0` |
|`WEB_FILE_MANAGER_ALLOWED_PATHS`| Comma-separated list of paths within the container that the file manager can access. By default, the container's entire filesystem is not accessible, and this variable specifies allowed paths. If set to `AUTO`, commonly used folders and those mapped to the container are automatically allowed. The value `ALL` allows access to all paths (no restrictions). See [Web File Manager](#web-file-manager) for details. | `AUTO` |
|`WEB_FILE_MANAGER_DENIED_PATHS`| Comma-separated list of paths within the container that the file manager cannot access. A denied path takes precedence over an allowed path. See [Web File Manager](#web-file-manager) for details. | (no value) |
|`WEB_NOTIFICATION`| When set to `1`, enables the web notification service, allowing the browser to display desktop notifications from the application. Requires the container to be configured with secure web access (HTTPS). See [Web Notifications](#web-notifications) for details. | `0` |
|`WEB_AUTHENTICATION`| When set to `1`, protects the application's GUI with a login page when accessed via a web browser. Access is granted only with valid credentials. Requires the container to be configured with secure web access (HTTPS). See [Web Authentication](#web-authentication) for details. | `0` |
|`WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME`| Lifetime of a token, in hours. A token is assigned to the user after successful login. As long as the token is valid, the user can access the application's GUI without logging in again. Once the token expires, the login page is displayed again. | `24` |
|`WEB_AUTHENTICATION_USERNAME`| Optional username for web authentication. Provides a quick and easy way to configure credentials for a single user. For more secure configuration or multiple users, see the [Web Authentication](#web-authentication) section. | (no value) |
|`WEB_AUTHENTICATION_PASSWORD`| Optional password for web authentication. Provides a quick and easy way to configure credentials for a single user. For more secure configuration or multiple users, see the [Web Authentication](#web-authentication) section. | (no value) |
|`SECURE_CONNECTION`| When set to `1`, uses an encrypted connection to access the application's GUI (via web browser or VNC client). See [Security](#security) for details. | `0` |
|`SECURE_CONNECTION_VNC_METHOD`| Method used for encrypted VNC connections. Possible values are `SSL` or `TLS`. See [Security](#security) for details. | `SSL` |
|`SECURE_CONNECTION_CERTS_CHECK_INTERVAL`| Interval, in seconds, at which the system checks if web or VNC certificates have changed. When a change is detected, affected services are automatically restarted. A value of `0` disables the check. | `60` |
|`WEB_LOCALHOST_ONLY`| When set to `1`, allows web connections only from localhost (127.0.0.1 and ::1). | `0` |
|`VNC_LOCALHOST_ONLY`| When set to `1`, allows VNC connections only from localhost (127.0.0.1 and ::1). | `0` |
|`WEB_LISTENING_PORT`| Port used by the web server to serve the application's GUI. This port is internal to the container and typically does not need to be changed. By default, a container uses the default bridge network, requiring each internal port to be mapped to an external port (using the `-p` or `--publish` argument). If another network type is used, changing this port may prevent conflicts with other services/containers. **NOTE**: A value of `-1` disables HTTP/HTTPS access to the application's GUI. | `5800` |
|`VNC_LISTENING_PORT`| Port used by the VNC server to serve the application's GUI. This port is internal to the container and typically does not need to be changed. By default, a container uses the default bridge network, requiring each internal port to be mapped to an external port (using the `-p` or `--publish` argument). If another network type is used, changing this port may prevent conflicts with other services/containers. **NOTE**: A value of `-1` disables VNC access to the application's GUI. | `5900` |
|`VNC_PASSWORD`| Password required to connect to the application's GUI. See the [VNC Password](#vnc-password) section for details. | (no value) |
|`ENABLE_CJK_FONT`| When set to `1`, installs the open-source font `WenQuanYi Zen Hei`, supporting a wide range of Chinese/Japanese/Korean characters. | `0` |
|`MYJDOWNLOADER_EMAIL`| Email address of the MyJDownloader account to use. Note that this can also be configured via the JDownloader GUI. | (no value) |
|`MYJDOWNLOADER_PASSWORD`| Password of the MyJDownloader account to use. Note that this can also be configured via the JDownloader GUI. | (no value) |
|`MYJDOWNLOADER_DEVICE_NAME`| The name of this JDownloader instance. Note that this can also be configured via the JDownloader GUI. | (no value) |
|`JDOWNLOADER_HEADLESS`| When set to `1`, JDownloader is running in headless mode, meaning that no GUI is available. In this mode, MyJDownloader should be used to remote control JDownloader. | `0` |
|`JDOWNLOADER_MAX_MEM`| Maximum amount of memory JDownloader is allowed to use. One of the following memory unit (case insensitive) should be added as a suffix to the size: `G`, `M` or `K`. When this variable is not set, the limit is automatically calculated based on the amount of RAM of the system. | (no value) |

#### Deployment Considerations

Many tools used to manage Docker containers extract environment variables
defined by the Docker image to create or deploy the container.

For example, this behavior is seen in:
  - The Docker application on Synology NAS
  - The Container Station on QNAP NAS
  - Portainer
  - etc.

While this is useful for users to adjust environment variable values to suit
their needs, keeping all of them can be confusing and even risky.

A good practice is to set or retain only the variables necessary for the
container to function as desired in your setup. If a variable is left at its
default value, it can be removed. Keep in mind that all environment variables
are optional; none are required for the container to start.

Removing unneeded environment variables offers several benefits:

  - Prevents retaining variables no longer used by the container. Over time,
    with image updates, some variables may become obsolete.
  - Allows the Docker image to update or fix default values. With image updates,
    default values may change to address issues or support new features.
  - Avoids changes to variables that could disrupt the container's
    functionality. Some undocumented variables, like `PATH` or `ENV`, are
    required but not meant to be modified by users, yet container management
    tools may expose them.
  - Addresses a bug in Container Station on QNAP and the Docker application on
    Synology, where variables without values may not be allowed. This behavior
    is incorrect, as variables without values are valid. Removing unneeded
    variables prevents deployment issues on these devices.

### Data Volumes

The following table describes the data volumes used by the container. Volume
mappings are set using the `-v` parameter with a value in the format
`<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/config`| rw | Stores the application's configuration, state, logs, and any files requiring persistency. |
|`/output`| rw | This is where downloaded files are stored. |

### Ports

The following table lists the ports used by the container.

When using the default bridge network, ports can be mapped to the host using the
`-p` parameter with value in the format `<HOST_PORT>:<CONTAINER_PORT>`. The
internal container port may not be changeable, but you can use any port on the
host side.

See the Docker [Docker Container Networking](https://docs.docker.com/config/containers/container-networking)
documentation for details.

| Port | Protocol | Mapping to Host | Description |
|------|----------|-----------------|-------------|
| 5800 | TCP | Optional | Port to access the application's GUI via the web interface. Mapping to the host is optional if web access is not needed. For non-default bridge networks, the port can be changed with the `WEB_LISTENING_PORT` environment variable. |
| 5900 | TCP | Optional | Port to access the application's GUI via the VNC protocol. Mapping to the host is optional if VNC access is not needed. For non-default bridge networks, the port can be changed with the `VNC_LISTENING_PORT` environment variable. |
| 3129 | TCP | Optional | Port used by *MyJDownloader* mobile applications and browser extensions to establish a direct connect to the JDownloader Docker container instance. Port needs to be exposed only if *MyJDownloader* is enabled and configured in *Direct Connection* mode. **NOTE**: Since this port is being reported to the *MyJDownloader* online service, the port mapped on the host side **must** be the same (i.e. 3129). |

### Changing Parameters of a Running Container

Environment variables, volume mappings, and port mappings are specified when
creating the container. To modify these parameters for an existing container,
follow these steps:

  1. Stop the container (if it is running):
```shell
docker stop jdownloader-2
```

  2. Remove the container:
```shell
docker rm jdownloader-2
```

  3. Recreate and start the container using the `docker run` command, adjusting
     parameters as needed.

> [!NOTE]
> Since all application data is saved under the `/config` container folder,
> destroying and recreating the container does not result in data loss, and the
> application resumes with the same state, provided the `/config` folder
> mapping remains unchanged.

### Docker Compose File

Below is an example `docker-compose.yml` file for use with
[Docker Compose](https://docs.docker.com/compose/overview/).

Adjust the configuration to suit your needs. Only mandatory settings are
included in this example.

```yaml
version: '3'
services:
  jdownloader-2:
    image: jlesage/jdownloader-2
    ports:
      - "5800:5800"
    volumes:
      - "/docker/appdata/jdownloader-2:/config:rw"
      - "/home/user/Downloads:/output:rw"
```

## Docker Image Versioning and Tags

Each release of a Docker image is versioned, and each version as its own image
tag. Before October 2022, the versioning scheme followed
[semantic versioning](https://semver.org).

Since then, the versioning scheme has shifted to
[calendar versioning](https://calver.org) with the format `YY.MM.SEQUENCE`,
where:
  - `YY` is the zero-padded year (relative to year 2000).
  - `MM` is the zero-padded month.
  - `SEQUENCE` is the incremental release number within the month (first release
    is 1, second is 2, etc).

View all available tags on [Docker Hub] or check the [Releases] page for version
details.

[Releases]: https://github.com/jlesage/docker-jdownloader-2/releases
[Docker Hub]: https://hub.docker.com/r/jlesage/jdownloader-2/tags

## Docker Image Update

The Docker image is regularly updated to incorporate new features, fix issues,
or integrate newer versions of the containerized application. Several methods
can be used to update the Docker image.

If your system provides a built-in method for updating containers, this should
be your primary approach.

Alternatively, you can use [Watchtower], a container-based solution for
automating Docker image updates. Watchtower seamlessly handles updates when a
new image is available.

To manually update the Docker image, follow these steps:

  1. Fetch the latest image:
```shell
docker pull jlesage/jdownloader-2
```

  2. Stop the container:
```shell
docker stop jdownloader-2
```

  3. Remove the container:
```shell
docker rm jdownloader-2
```

  4. Recreate and start the container using the `docker run` command, with the
     same parameters used during initial deployment.

[Watchtower]: https://github.com/containrrr/watchtower

### Synology

For Synology NAS users, follow these steps to update a container image:

  1.  Open the *Docker* application.
  2.  Click *Registry* in the left pane.
  3.  In the search bar, type the name of the container (`jlesage/jdownloader-2`).
  4.  Select the image, click *Download*, and choose the `latest` tag.
  5.  Wait for the download to complete. A notification will appear once done.
  6.  Click *Container* in the left pane.
  7.  Select your JDownloader 2 container.
  8.  Stop it by clicking *Action* -> *Stop*.
  9.  Clear the container by clicking *Action* -> *Reset* (or *Action* ->
      *Clear* if you don't have the latest *Docker* application). This removes
      the container while keeping its configuration.
  10. Start the container again by clicking *Action* -> *Start*. **NOTE**:  The
      container may temporarily disappear from the list while it is recreated.

### unRAID

For unRAID users, update a container image with these steps:

  1. Select the *Docker* tab.
  2. Click the *Check for Updates* button at the bottom of the page.
  3. Click the *apply update* link of the container to be updated.

## User/Group IDs

When mapping data volumes (using the `-v` flag of the `docker run` command),
permission issues may arise between the host and the container. Files and
folders in a data volume are owned by a user, which may differ from the user
running the application. Depending on permissions, this could prevent the
container from accessing the shared volume.

To avoid this, specify the user the application should run as using the
`USER_ID` and `GROUP_ID` environment variables.

To find the appropriate IDs, run the following command on the host for the user
owning the data volume:

```shell
id <username>
```

This produces output like:

```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

Use the `uid` (user ID) and `gid` (group ID) values to configure the container.

## Accessing the GUI

Assuming the container's ports are mapped to the same host's ports, access the
application's GUI as follows:

  - Via a web browser:

```text
http://<HOST_IP_ADDR>:5800
```

  - Via any VNC client:

```text
<HOST_IP_ADDR>:5900
```

## Security

By default, access to the application's GUI uses an unencrypted connection (HTTP
or VNC).

A secure connection can be enabled via the `SECURE_CONNECTION` environment
variable. See the [Environment Variables](#environment-variables) section for
details on configuring environment variables.

When enabled, the GUI is accessed over HTTPS when using a browser, with all HTTP
accesses redirected to HTTPS.

For VNC clients, the connection can be secured using on of two methods,
configured via the `SECURE_CONNECTION_VNC_METHOD` environment variable:

  - `SSL`: An SSL tunnel is used to transport the VNC connection. Few VNC
    clients supports this method; [SSVNC] is one that does.
  - `TLS`: A VNC security type negotiated during the VNC handshake. It uses TLS
    to establish a secure connection. Clients may optionally validate the
    server’s certificate. Valid certificates must be provided for this
    validation to succeed. See [Certificates](#certificates) for details.
    [TigerVNC] is a client that supports TLS encryption.

[TigerVNC]: https://tigervnc.org

### SSVNC

[SSVNC] is a VNC viewer that adds encryption to VNC connections by using an
SSL tunnel to transport the VNC traffic.

While the Linux version of [SSVNC] works well, the Windows version has issues.
At the time of writing, the latest version `1.0.30` fails with the error:

```text
ReadExact: Socket error while reading
```

For convenience, an unofficial, working version is provided here:

https://github.com/jlesage/docker-baseimage-gui/raw/master/tools/ssvnc_windows_only-1.0.30-r1.zip

This version upgrades the bundled `stunnel` to version `5.49`, resolving the
connection issues.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### Certificates

The following certificate files are required by the container. If missing,
self-signed certificates are generated and used. All files are PEM-encoded x509
certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPS connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPS connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

> [!TIP]
> To avoid certificate validity warnings or errors in browsers or VNC clients,
> provide your own valid certificates.

> [!NOTE]
> Certificate files are monitored, and relevant services are restarted when
> changes are detected.

### VNC Password

To restrict access to your application, set a password using one of two methods:
  - Via the `VNC_PASSWORD` environment variable.
  - Via a `.vncpass_clear` file at the root of the `/config` volume, containing
    the password in clear text. During container startup, the content is
    obfuscated and moved to `.vncpass`.

The security of the VNC password depends on:
  - The communication channel (encrypted or unencrypted).
  - The security of host access.

When using a VNC password, configure the container with secure web access
(HTTPS) to prevent sending the password in clear text over an unencrypted
channel.

Unauthorized users with sufficient host privileges can retrieve the password by:

  - Viewing the `VNC_PASSWORD` environment variable via `docker inspect`. By
    default, the `docker` command requires root access, but it can be configured
    to allow users in a specific group.
  - Decrypting the `/config/.vncpass` file, which requires root or `USER_ID`
    permissions.

> [!CAUTION]
> VNC password is limited to 8 characters. This limitation comes from the Remote
> Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see section
> [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)).

### Web Authentication

Access to the application's GUI via a web browser can be protected with a login
page. When enabled, users must provide valid credentials to gain access.

Enable web authentication by setting the `WEB_AUTHENTICATION` environment
variable to `1`. See the [Environment Variables](#environment-variables) section
for details on configuring environment variables.

> [!IMPORTANT]
> Web authentication requires the container to be configured with secure web
> access (HTTPS). See [Security](#security) for details.

#### Configuring Users Credentials

User credentials can be configured in two ways:

  1. Via container environment variables.
  2. Via a password database.

Container environment variables provide a quick way to configure a single user.
Set the username and password using:
  - `WEB_AUTHENTICATION_USERNAME`
  - `WEB_AUTHENTICATION_PASSWORD`

See the [Environment Variables](#environment-variables) section for details on
configuring environment variables.

For a more secure method or to configure multiple users, use a password database
at `/config/webauth-htpasswd` within the container. This file uses the Apache
HTTP server's htpasswd format, storing bcrypt-hashed passwords.

Manage users with the `webauth-user` tool:
  - Add a user: `docker exec -ti <container name> webauth-user add <username>`
  - Update a user: `docker exec -ti <container name> webauth-user update <username>`
  - Remove a user: `docker exec <container name> webauth-user del <username>`
  - List users: `docker exec <container name> webauth-user list`

## Reverse Proxy

The following sections provide NGINX configurations for setting up a reverse
proxy to this container.

A reverse proxy server can route HTTP requests based on the hostname or URL
path.

### Routing Based on Hostname

In this scenario, each hostname is routed to a different application or
container.

For example, if the reverse proxy server runs on the same machine as this
container, it would proxy all HTTP requests for `jdownloader-2.domain.tld` to
the container at `127.0.0.1:5800`.

Here are the relevant configuration elements to add to the NGINX configuration:

```nginx
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream docker-jdownloader-2 {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	server_name jdownloader-2.domain.tld;

	location / {
		proxy_pass http://docker-jdownloader-2;
	}

	location /websockify {
		proxy_pass http://docker-jdownloader-2;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_read_timeout 86400;
	}
}

```

### Routing Based on URL Path

In this scenario, the same hostname is used, but different URL paths route to
different applications or containers. For example, if the reverse proxy server
runs on the same machine as this container, it would proxy all HTTP requests for
`server.domain.tld/filebot` to the container at `127.0.0.1:5800`.

Here are the relevant configuration elements to add to the NGINX configuration:

```nginx
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream docker-jdownloader-2 {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	location = /jdownloader-2 {return 301 $scheme://$http_host/jdownloader-2/;}
	location /jdownloader-2/ {
		proxy_pass http://docker-jdownloader-2/;
		# Uncomment the following line if your Nginx server runs on a port that
		# differs from the one seen by external clients.
		#port_in_redirect off;
		location ~ ^/jdownloader-2/(websockify(-.*)?) {
                        proxy_pass http://docker-jdownloader-2/$1;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $connection_upgrade;
			proxy_read_timeout 86400;
		}
	}
}

```

## Web Control Panel

The control panel is available whenever the application GUI is accessed through
a web browser. Click the small three-dots tab on the left edge of the browser
window to open it.

![Web Control Panel](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/control-panel.png&w=500)

| Control | Action / Purpose |
|---------|------------------|
| **X** icon | Closes the control panel. |
| **Logout** icon | Logs out from the web interface. Visible only when [web authentication](#web-authentication) is enabled. |
| **Keyboard** icon | Toggle the on-screen keyboard. Visible only on touch devices. |
| **Fullscreen** icon | Toggle fullscreen mode for the browser window. |
| **Hand** icon| Allows dragging/moving the application window. Visible only when **Scaling Mode** is *None* and **Clip to Window** is enabled.
| **Folder** icon | Opens the intgegrated file browser. Visible only when the [file manager](#web-file-manager) is enabled. |
| **Clipboard** text box| Mirrors the application’s clipboard. Any text typed or pasted here is sent to the application, and text copied inside the application automatically appears here. Hidden when [automatic clipboard synchronization](#automatic-clipboard-sync) is active. |
| **Clear** button | Clears the clipboard. Hidden when [automatic clipboard synchronization](#automatic-clipboard-sync) is active. |
| **Audio** icon | Mutes or unmutes audio streaming from the container. Visible only when [audio support](#web-audio) is enabled. |
| **Volume** slider| Controls the playback volume of the audio streaming from the container. Visible only when [audio support](#web-audio) is enabled. |
| **Clip to Window** toggle | Only applies when **Scaling Mode** is *None*. When disabled, scrollbars appear if the application window is larger than the browser window. When enabled, no scrollbars are shown and the hand icon is used to pan. |
| **Scaling Mode** dropdown | Controls how the application window is scaled to fit the browser. **None** – no scaling, the application window keeps its original size. **Local Scaling** – the image is scaled in the browser (application window size unchanged). **Remote Scaling** – the application window inside the container is automatically resized to match the browser window size. |
| **Quality** slider | Adjusts image quality. Moving the slider left reduces bandwidth at the cost of visual quality. |
| **Compression** slider | Adjusts compression level applied to screen updates. Moving the slider right increases compression, which lowers bandwidth but raises CPU usage. |
| **Logging** dropdown | Sets the verbosity level of the web interface logs shown in the browser console. |
| **Application version** label | Displays the version of JDownloader 2 integrated into Docker image. |
| **Docker image** version label | Displays the version of the Docker image currently running. |

## Automatic Clipboard Sync

When the container is accessed through a web browser, automatic clipboard
synchronization enables seamless sharing of clipboard contents between the host
system and the application running inside the container. This makes it possible
to copy and paste text or data directly between the two environments without
manual transfer steps.

This functionality is not available when using VNC clients and is supported only
in browsers based on the Chromium engine, such as Google Chrome and Microsoft
Edge.

Clipboard synchronization operates transparently once permission has been
granted by the browser. Depending on browser implementation, a prompt may appear
the first time clipboard access is requested.

> [!IMPORTANT]
> Web browsers only allow access to the clipboard in secure contexts (HTTPS).
> This means the container must be configured with secure web access. See
> [Security](#security) for details.

> [!TIP]
> If automatic clipboard synchronization is not available, text can still be
> copied and pasted using the clipboard of the
> [control panel](#web-control-panel), which provides manual clipboard access
> between the host and the container.

## Web Audio

The container supports streaming audio from the application, played through the
user's web browser. Audio is not supported for VNC clients.

Audio is streamed with the following specification:

  * Raw PCM format
  * 2 channels
  * 16-bit sample depth
  * 44.1kHz sample rate

Enable web audio by setting `WEB_AUDIO` to `1`. See the
[Environment Variables](#environment-variables) section for details on
configuring environment variables.

Control of the audio stream (mute, unmute and volume) is done via the
[control panel](#web-control-panel).

## Web File Manager

The container includes a simple file manager for interacting with container
files through a web browser, supporting operations like renaming, deleting,
uploading, and downloading.

Enable the file manager by setting `WEB_FILE_MANAGER` to `1`. See the
[Environment Variables](#environment-variables) section for details on
configuring environment variables.

Open the file manager by clicking the folder icon of the
[control panel](#web-control-panel)

By default, the container's entire filesystem is not accessible. The
`WEB_FILE_MANAGER_ALLOWED_PATHS` environment variable is a comma-separated list
that specifies which paths within the container are allowed to be accessed. When
set to `AUTO` (the default), it automatically includes commonly used folders and
any folders mapped to the container.

The `WEB_FILE_MANAGER_DENIED_PATHS` environment variable defines which paths are
explicitly denied access by the file manager. A denied path takes precedence
over an allowed one.

## Web Notifications

The container includes support for notifications sent through the web browser.
Any desktop notification generated by JDownloader 2 is forwarded to the
browser, which then displays it as a native notification on the user's system.

Enable the web notification service by setting `WEB_NOTIFICATION` to `1`. See
the [Environment Variables](#environment-variables) section for details on
configuring environment variables.

> [!IMPORTANT]
> Web browsers only allow notifications in secure contexts (HTTPS). This means
> the container must be configured with secure web access. See
> [Security](#security) for details.

## GPU Acceleration Support

This container supports hardware-accelerated rendering of the application's
graphical user interface. When enabled, the X server running inside the
container can use the host GPU, providing improved rendering performance and
full hardware acceleration for OpenGL via the GLX extension.

This feature requires open-source kernel drivers on the host system, such as
`amdgpu` for AMD GPUs, `i915` for Intel GPUs, or `nouveau` for NVIDIA GPUs, to
support the Direct Rendering Infrastructure (DRI3) and Generic Buffer Management
(GBM). Proprietary drivers, such as NVIDIA's, are not supported.

To enable GPU acceleration, the host must have compatible open-source kernel
drivers installed, and the GPU device `/dev/dri` must be exposed to the
container. For example, this is done by adding the `--device /dev/dri`
argument to the `docker run` command.

## Shell Access

To access the shell of a running container, execute the following command:

```shell
docker exec -ti CONTAINER sh
```

Where `CONTAINER` is the ID or the name of the container used during its
creation.

## MyJDownloader

[MyJDownloader](https://my.jdownloader.org) is an online service providing
remote access to your JDownloader with Web Interface, Android App, iPhone App,
Windows Phone App and Browser Extensions. It allows to check download status,
add links and solve captchas from everywhere.

To activate, open the JDownloader UI and click the *My.JDownloader* tab.

### Direct Connection

When using MyJDownloader from a device on the same local network as the
JDownloader Docker container instance, *Direct Connection* mode can be enabled
to reduce the latency and increase the bandwidth. With this mode, instead of
going through the cloud, the communication is done through a direct connection
between the device and JDownloader.

The default container's network being in *bridge* mode, the *Direct Connection*
mode is not automatically detected/activated and the following steps are required:

  * Make sure the container's port `3129` is mapped to the host port `3129`.
    This is done by adding the parameter `-p 3129:3129` to the `docker run`
    command.
  * Open the JDownloader UI.
  * Go to *Settings*->*Advanced Settings*.
  * Search for `MyJDownloaderSettings`.
  * Set `Custom Device IPs` to the IP address of the host running the container,
    using double quotes and brackets like this example: `["192.168.1.1"]`.
  * Change the `Direct Connection Mode` to `Allow lan/wan connections with
    manual port forwarding`.
  * Restart JDownloader (*File*->*Restart*).

## Click'n'Load

The easiest way to use the [Click'n'Load] feature is by installing the
[MyJDownloader browser extension]. With this method, the browser extension
handles POST requests to `http://127.0.0.1:9666` and forward the links to
JDownloader via the *MyJDownloader* service.

[Click'n'Load]: http://jdownloader.org/knowledge/wiki/glossary/cnl2
[MyJDownloader browser extension]: https://my.jdownloader.org/apps/

## Troubleshooting

### JDownloader Fails to Start

If JDownloader displays an error indicating that it is unable to start,
following these instruction might help fixing the problem.

1. Create the file `.fix_jd_install`, under the directory that has been mapped
   to `/config`. The content of the file is not important. However, if the
   latest JDownloader installer is required, setting the content to `download`
   causes the installer to be downloaded.
2. Restart the container.

The presence of the file causes the container to attempt fixing the installation
during its startup. The repair process follows the instructions provided at:

https://support.jdownloader.org/en/knowledgebase/article/fix-jdownloader-installation

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-jdownloader-2/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.

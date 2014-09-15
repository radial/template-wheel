# Wheel Template

This is a template of a Wheel repository. A Wheel repository is the gathering
point for your stacks deployment code.

Some mandatory design features of a Wheel repository:

## File structure

```
.
├── axle
├── fig.yml
├── hub
│   ├── Dockerfile
│   ├── build-env
│   ├── config
│   │   ├── echos.conf
│   │   └── supervisor
│   │       └── conf.d
│   │           └── echos.ini
│   ├── data
│   │   ├── media
│   │   │   └── dataset
│   │   └── src
│   │       └── code
│   └── log
│       └── logfile
└── spoke
    ├── Dockerfile
    └── entrypoint.sh
```

While the structure of the 'axle' and 'spoke' folders is technically not
mandatory, it is suggested to keep it like this for compatibility with future
planned features. 

The folder structure of the 'hub' folder however IS mandatory. Deviating will
break the 'hub-base' and 'spoke-base' images. Application configuration sits in
`hub/config` and the accompanying Supervisor '.ini' file goes in
`hub/config/supervisor/conf.d`.

## Configuration Branch

Your application has a repository for it's code. Your deployment code and
configuration however, as it pertains to using Radial, is stored here in the
Wheel repository. The 'hub-base' image has the ability to `ADD` your
configuration (whatever files you put in your `hub/config` and
`hub/config/supervisor/conf.d` folders) as well as pull it from a repository. If
pulling from a repository is your method of choice, it is suggested that your
make a separate branch in this repository with just the contents of your
`hub/config` folder and all it's subfolders and files. The 'hub-base' image
contains logic to pull the 'config' branch of your Wheel repository and merge it
with the [skeleton configuration][config-supervisor] used by Supervisor.

The folder structure of your 'config' branch would be as follows:

```
.
├── echos.conf
└── supervisor
    └── conf.d
        └── echos.ini
```
The two files 'echos.conf' and 'echos.ini' demonstrate the needs of a typical
application, but this folder structure can easily support more complicated
situations.

[config-supervisor]: https://github.com/radial/config-supervisor

## Fig

Since Radial makes liberal use of containers and "separates concerns" to an
extreme degree, a basic orchestration tool is needed to help manage the
building, linking, and deploying of all the containers. Other tools can surely
be used for this, but for the sake of simplicity, Radial uses [Fig][fig] for now
for demonstration and testing.

[fig]: http://www.fig.sh

## Tutorial

This repository demonstrates how a simple program could work. Skim through the
wheel source and the fig.yml file to get a sense of how it all peices together.

Some things to note about Spoke containers:

1. Within the Dockerfile for the Spoke container, the `$SPOKE_NAME` variable
   must be set with a unique and descriptive word to identify this particular
   Spoke against what could potentially be many Spokes all sharing the same Hub
   container. This word must coincide with the programs .ini configuration
   located in `/config/supervisor/conf.d`.
2. Supervisor .ini files should start a single `entrypoint.sh` script to handle
   all startup/restart logic. Supervisor is pretty horrendous at serializing tasks, so
   it's easier to just cut to the chase and put it all in a single script.
3. The contents of a well-formed `entrypoint.sh` script should do the following:
    - use `set -e` so that if any part of the script fails, the entire script
      returns an error and you can see it immediately and fix it.
    - All environment variables should have sane defaults.
    - Scripts should be designed to handle clean first starts and graceful
      container restarts.
    - use `exec` as your final step to launch the program binary so that signals
      can be passed gracefully from the docker daemon all the way to your
      program.
4. Keep in mind that what you see in the fig output is only Supervisor output
   and program errors. That is all that is really important for the initial
   testing phases of a program. Once it's up and running, a more industrial
   solution for reviewing normal 'stdout' log output should be in place.

Some things to note about Hub containers:

1. The "radial/hub-base" image copies the entire context by default. Make sure
   to use a '.dockerignore' file to blacklist items you wish to not upload.
2. Be advised that the '/config', '/data', '/log', and '/run' directories have
   been exposed as docker volumes. You cannot add files or do anything to
   existing files they contain in the hub Dockerfile itself. So that Dockerfile
   really should remain empty other then the `FROM` and `MAINTAINER` lines.
3. Should you need to add files such as source code or a data set, you should
   either include those instructions as part of the entrypoint script of the
   Spoke container that requires them, or if this data is significant enough by
   itself, then it should occupy it's own Axle container. Either way, it should
   not originate in the Hub container (even though it will be made availble
   there through being exposed as a volume).
4. '/data' is a type of hybrid between '/var', '/home', and '/opt'. It stores
   temporary and/or permanent items or anything else that pertains to your
   Spoke's needs.

### Static Mode

Static mode means we are building from Dockerfiles ourselves. This is to allow
for all configuration data to manifest itself as an actual file somewhere in our
Wheel repository. It will be uploaded and run accordingly.

Run `fig -f fig.yml up`. 

Using [this](fig.yml) fig file produces:

```
Creating templatewheel_logs_1...
Creating templatewheel_hub_1...
Building hub...
# Executing 8 build triggers
Step onbuild-0 : COPY    / /
 ---> 9a306ffe84a0
Step onbuild-1 : RUN     mkdir -p /data /log
 ---> Running in 96b93c0956e8
 ---> 8ba1660ff0f7
Step onbuild-2 : WORKDIR /config
 ---> Running in aa58311b384b
 ---> 4886bdf12baf
Step onbuild-3 : RUN     git init && git add . && git commit -m "Configuration from COPY files"
 ---> Running in 14d2a15d4c3d
Initialized empty Git repository in /config/.git/
[master (root-commit) a114a25] Configuration from COPY files
 2 files changed, 32 insertions(+)
 create mode 100644 echos.conf
 create mode 100644 supervisor/conf.d/echos.ini
 ---> 5ff0751c2a4d
Step onbuild-4 : ENV     ENV /build-env
 ---> Running in 67fb75dfe6a5
 ---> be2ecc852d81
Step onbuild-5 : RUN     test -f /build-env && source /build-env;                /hub-entrypoint.sh static
 ---> Running in be76c0b71734
warning: no common commits
From https://github.com/radial/config-supervisor
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> supervisor/master
Merge made by the 'recursive' strategy.
 supervisor/conf.d/sshd.ini  | 28 ++++++++++++++
 supervisor/supervisord.conf | 93 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+)
 create mode 100644 supervisor/conf.d/sshd.ini
 create mode 100644 supervisor/supervisord.conf
...successfully pulled Supervisor skeleton config.
warning: no common commits
From https://github.com/radial/wheel-log.io
 * branch            config     -> FETCH_HEAD
 * [new branch]      config     -> 2d4bbcf59b/config
Merge made by the 'recursive' strategy.
 supervisor/conf.d/logio.ini | 59 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 supervisor/conf.d/logio.ini
...file permissions successfully applied to /config.
...file permissions successfully applied to /data.
...file permissions successfully applied to /log.
 ---> c039852be328
Step onbuild-6 : VOLUME  ["/config", "/data", "/log", "/run"]
 ---> Running in 9edee3fd5704
 ---> 81a11ca52d44
Step onbuild-7 : ENTRYPOINT ["/hub-entrypoint.sh", "static-update"]
 ---> Running in 116fb4d89fd6
 ---> 7422995ea09e
 ---> 7422995ea09e
Removing intermediate container 96b93c0956e8
Removing intermediate container aa58311b384b
Removing intermediate container 14d2a15d4c3d
Removing intermediate container 67fb75dfe6a5
Removing intermediate container be76c0b71734
Removing intermediate container 9edee3fd5704
Removing intermediate container 116fb4d89fd6
Removing intermediate container d75be1f6da1b
Step 1 : MAINTAINER      radial@brianclements.net
 ---> Running in f133c21b8937
 ---> 9c36fc5d093f
Removing intermediate container f133c21b8937
Successfully built 9c36fc5d093f
Creating templatewheel_echos_1...
Attaching to templatewheel_hub_1, templatewheel_echos_1
hub_1   | ...file permissions successfully applied to /config.
hub_1   | ...file permissions successfully applied to /data.
hub_1   | ...file permissions successfully applied to /log.
hub_1   | Wheel repositories updated.
hub_1   | Container will now idle.
echos_1 | 2014-09-14 19:30:37,354 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
echos_1 | 2014-09-14 19:30:37,360 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
echos_1 | 2014-09-14 19:30:37,361 INFO [2] SSH keys [Authorized]
echos_1 | 2014-09-14 19:30:37,504 CRIT Set uid to user 0
echos_1 | 2014-09-14 19:30:37,504 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
echos_1 | 2014-09-14 19:30:37,504 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
echos_1 | 2014-09-14 19:30:37,504 WARN Included extra file "/config/supervisor/conf.d/logio.ini" during parsing
echos_1 | 2014-09-14 19:30:37,544 INFO RPC interface 'supervisor' initialized
echos_1 | 2014-09-14 19:30:37,545 CRIT Server 'unix_http_server' running without any HTTP authentication checking
echos_1 | 2014-09-14 19:30:37,545 INFO supervisord started with pid 1
echos_1 | 2014-09-14 19:30:38,528 INFO spawned: 'echos' with pid 35
echos_1 | 2014-09-14 19:30:38,532 INFO spawned: 'sshd' with pid 36
echos_1 | 2014-09-14 19:31:38,550 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | 2014-09-14 19:31:38,550 INFO success: echos entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | echos: started
echos_1 | sshd: started
echos_1 | 2014-09-14 19:31:38,581 CRIT reaped unknown pid 23)
echos_1 | 2014-09-14 19:31:38,582 CRIT reaped unknown pid 24)
```

One thing you might notice from the output of the above command, is the
inclusion of an additional configuration file for the [Log.io][logio] Spoke.
This is an added feature to let one include additional configuration for various
other Wheels to produce hybrid Wheels consisting of many Spokes. This
information is specified in the `hub/build-env` [file](hub/build-env).

So you'll notice that our Wheel as been run, but it appears that nothing is
happening. The main Spoke for this program, [echos-test][echostest], has been
activated, but we aren't seeing it's output. This is because the output of any
fig commands only display Supervisor output and error messages from the Spoke
containers for debugging purposes. If everything is going well, then the regular
log output of our Spoke, as defined in it's Supervisor .ini file in
`/config/supervisor/conf.d/`, silently accrues in the background in the `/log`
directory (which itself is a volume container) so that it can be properly
viewed/managed by some other logging process.

To see normal output, as well as all the changes in the logs as it happens, you
could `docker run -it --volumes-from templatewheel_hub_1 radial/distro:us-west-1
bash` and navigate to `/log` to check them out in a shell, or you could do it
with a dedicated log viewing program in a user friendly way.

Run `fig -f fig-hybrid-wheel.yml up` and navigate to:
[http://localhost:28778/](http://localhost:28778/) to check out the stream.

The output of [this](fig-hybrid-wheel.yml) fig file produces:

```
Creating templatewheel_logs_1...
Creating templatewheel_hub_1...
Building hub...
 ---> 44cd3fce76c3
Step onbuild-1 : RUN     mkdir -p /data /log
 ---> Running in 611b667bce41
 ---> 8126421fc8c2
Step onbuild-2 : WORKDIR /config
 ---> Running in 4acc974d63f1
 ---> 7ffa0d343c67
Step onbuild-3 : RUN     git init && git add . && git commit -m "Configuration from COPY files"
 ---> Running in 500bd98895fa
Initialized empty Git repository in /config/.git/
[master (root-commit) 232829a] Configuration from COPY files
 2 files changed, 32 insertions(+)
 create mode 100644 echos.conf
 create mode 100644 supervisor/conf.d/echos.ini
 ---> 6a7229a00dd4
Step onbuild-4 : ENV     ENV /build-env
 ---> Running in de0d2add1cbb
 ---> 6d569795db85
Step onbuild-5 : RUN     test -f /build-env && source /build-env;                /hub-entrypoint.sh static
 ---> Running in c1016a7ea514
warning: no common commits
From https://github.com/radial/config-supervisor
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> supervisor/master
Merge made by the 'recursive' strategy.
 supervisor/conf.d/sshd.ini  | 28 ++++++++++++++
 supervisor/supervisord.conf | 93 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+)
 create mode 100644 supervisor/conf.d/sshd.ini
 create mode 100644 supervisor/supervisord.conf
...successfully pulled Supervisor skeleton config.
warning: no common commits
From https://github.com/radial/wheel-log.io
 * branch            config     -> FETCH_HEAD
 * [new branch]      config     -> 313e7de2e9/config
Merge made by the 'recursive' strategy.
 supervisor/conf.d/logio.ini | 59 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 supervisor/conf.d/logio.ini
...file permissions successfully applied to /config.
...file permissions successfully applied to /data.
...file permissions successfully applied to /log.
 ---> 8e9d6a63a48e
Step onbuild-6 : VOLUME  ["/config", "/data", "/log", "/run"]
 ---> Running in 95117c22a612
 ---> 675eff46d62a
Step onbuild-7 : ENTRYPOINT ["/hub-entrypoint.sh", "static-update"]
 ---> Running in 485ffea2ec90
 ---> aebd9c52a91c
 ---> aebd9c52a91c
Removing intermediate container 500bd98895fa
Removing intermediate container de0d2add1cbb
Removing intermediate container c1016a7ea514
Removing intermediate container 95117c22a612
Removing intermediate container 485ffea2ec90
Removing intermediate container d8c2661c7d38
Removing intermediate container 611b667bce41
Removing intermediate container 4acc974d63f1
Step 1 : MAINTAINER      radial@brianclements.net
 ---> Running in 2eb7c7768390
 ---> c4504c703d3d
Removing intermediate container 2eb7c7768390
Successfully built c4504c703d3d
Creating templatewheel_logio_1...
Creating templatewheel_echos_1...
Attaching to templatewheel_hub_1, templatewheel_logio_1, templatewheel_echos_1
echos_1 | 2014-09-14 19:35:04,397 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
echos_1 | 2014-09-14 19:35:04,403 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
echos_1 | 2014-09-14 19:35:04,404 INFO [2] SSH keys [Authorized]
echos_1 | 2014-09-14 19:35:04,572 CRIT Set uid to user 0
echos_1 | 2014-09-14 19:35:04,572 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
echos_1 | 2014-09-14 19:35:04,572 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
echos_1 | 2014-09-14 19:35:04,572 WARN Included extra file "/config/supervisor/conf.d/logio.ini" during parsing
echos_1 | 2014-09-14 19:35:04,614 INFO RPC interface 'supervisor' initialized
echos_1 | 2014-09-14 19:35:04,615 CRIT Server 'unix_http_server' running without any HTTP authentication checking
echos_1 | 2014-09-14 19:35:04,616 INFO supervisord started with pid 1
logio_1 | 2014-09-14 19:35:05,050 INFO spawned: 'logio-server' with pid 23
logio_1 | 2014-09-14 19:35:05,053 INFO spawned: 'logio-harvester' with pid 24
echos_1 | 2014-09-14 19:35:05,578 INFO spawned: 'sshd' with pid 29
echos_1 | 2014-09-14 19:35:05,634 INFO spawned: 'echos' with pid 30
logio_1 | ==> /log/cf7078f8fd53/logio-harvester_stderr.log <==
logio_1 |
logio_1 | ==> /log/cf7078f8fd53/logio-server_stderr.log <==
logio_1 |
logio_1 | ==> /log/cf7078f8fd53/logio_stderr.log <==
logio_1 |
logio_1 | Container restart on Sun Sep 14 19:35:05 PDT 2014.
logio_1 | info: socket.io started
logio_1 | 2014-09-14 19:36:05,242 INFO success: logio-harvester entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
logio_1 | 2014-09-14 19:36:05,243 INFO success: logio-server entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | 2014-09-14 19:36:05,713 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | 2014-09-14 19:36:05,713 INFO success: echos entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | sshd: started
echos_1 | echos: started
echos_1 | 2014-09-14 19:36:05,746 CRIT reaped unknown pid 18)
echos_1 | 2014-09-14 19:36:05,750 CRIT reaped unknown pid 17)
logio_1 | logio-server: started
logio_1 | logio-harvester: started
logio_1 | 2014-09-14 19:36:06,260 CRIT reaped unknown pid 16)
```

On top of our original wheel that had one Spoke container, the "echos-test"
Spoke, now we added another spoke for viewing our logs. Because all Spokes obey
strict rules regarding their configuration and entrypoints, they are all modular
and it is easy to make hybrid Wheels that contain all the Spokes needed to make
up your full stack.

Note: the image for the [log.io][logio] Spoke was acquired dynamically via
pulling from the Docker hub, we did not build it from a Dockerfile in our Wheel.
Because configuration is not a part of the Spoke container, we should never need
to rebuild a Spoke container for any reason other then to update or change the
app itself. This saves a lot of computation time during deployment of images.

### Dynamic Mode

Dynamic mode means that we are using nothing other then our fig file for putting
our wheel together. We aren't building any images nor are we uploading any files
to containers. This is a leaner method of building Wheels that requires all your
configuration to be accessible via config branches of git repositories as
explained above, and all your applications to be already installed in their own
Spoke containers via pullable images from a docker registry somewhere.

We use now a different log viewing program called [Clarity][clarity] to view the
logs of the same Wheel. But this time it is done all dynamically. 

Run `fig -f fig-dynamic.yml` and navigate to:
[http://localhost:8989/](http://localhost:8989/) to check out the stream.

The output of [this](fig-dynamic.yml) fig file produces:

```
Creating templatewheel_logs_1...
Creating templatewheel_hub_1...
Creating templatewheel_clarity_1...
Creating templatewheel_echos_1...
Attaching to templatewheel_hub_1, templatewheel_clarity_1, templatewheel_echos_1
hub_1     | warning: no common commits
hub_1     | From https://github.com/radial/wheel-clarity
hub_1     |  * branch            config     -> FETCH_HEAD
hub_1     |  * [new branch]      config     -> d12ad08a5e/config
hub_1     | Merge made by the 'recursive' strategy.
hub_1     |  supervisor/conf.d/clarity.ini | 31 +++++++++++++++++++++++++++++++
hub_1     |  1 file changed, 31 insertions(+)
hub_1     |  create mode 100644 supervisor/conf.d/clarity.ini
hub_1     | warning: no common commits
hub_1     | From https://github.com/radial/template-wheel
hub_1     |  * branch            config     -> FETCH_HEAD
hub_1     |  * [new branch]      config     -> 4fa88c50aa/config
hub_1     | Merge made by the 'recursive' strategy.
hub_1     |  echos.conf                  |  1 +
hub_1     |  supervisor/conf.d/echos.ini | 31 +++++++++++++++++++++++++++++++
hub_1     |  2 files changed, 32 insertions(+)
hub_1     |  create mode 100644 echos.conf
hub_1     |  create mode 100644 supervisor/conf.d/echos.ini
hub_1     | ...file permissions successfully applied to /config.
hub_1     | ...file permissions successfully applied to /data.
hub_1     | ...file permissions successfully applied to /log.
hub_1     | Wheel repositories updated.
hub_1     | Container will now idle.
echos_1   | Hub container loaded. Continuing to load Spoke "echos".
clarity_1 | Hub container loaded. Continuing to load Spoke "clarity".
echos_1   | 2014-09-14 19:40:20,924 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
echos_1   | 2014-09-14 19:40:20,933 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
echos_1   | 2014-09-14 19:40:20,934 INFO [2] SSH keys [Authorized]
echos_1   | 2014-09-14 19:40:21,105 CRIT Set uid to user 0
echos_1   | 2014-09-14 19:40:21,106 WARN Included extra file "/config/supervisor/conf.d/clarity.ini" during parsing
echos_1   | 2014-09-14 19:40:21,106 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
echos_1   | 2014-09-14 19:40:21,106 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
echos_1   | 2014-09-14 19:40:21,163 INFO RPC interface 'supervisor' initialized
echos_1   | 2014-09-14 19:40:21,164 CRIT Server 'unix_http_server' running without any HTTP authentication checking
echos_1   | 2014-09-14 19:40:21,164 INFO supervisord started with pid 1
clarity_1 | 2014-09-14 19:40:21,206 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
clarity_1 | 2014-09-14 19:40:21,212 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
clarity_1 | 2014-09-14 19:40:21,213 INFO [2] SSH keys [Authorized]
clarity_1 | 2014-09-14 19:40:21,361 CRIT Set uid to user 0
clarity_1 | 2014-09-14 19:40:21,361 WARN Included extra file "/config/supervisor/conf.d/clarity.ini" during parsing
clarity_1 | 2014-09-14 19:40:21,361 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
clarity_1 | 2014-09-14 19:40:21,361 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
clarity_1 | 2014-09-14 19:40:21,404 INFO RPC interface 'supervisor' initialized
clarity_1 | 2014-09-14 19:40:21,405 CRIT Server 'unix_http_server' running without any HTTP authentication checking
clarity_1 | 2014-09-14 19:40:21,405 INFO supervisord started with pid 1
echos_1   | 2014-09-14 19:40:22,109 INFO spawned: 'sshd' with pid 32
echos_1   | 2014-09-14 19:40:22,147 INFO spawned: 'echos' with pid 33
clarity_1 | 2014-09-14 19:40:22,426 INFO spawned: 'sshd' with pid 32
clarity_1 | 2014-09-14 19:40:22,433 INFO spawned: 'clarity' with pid 33
clarity_1 | HTTP Info:
clarity_1 |   Username: anonymous
clarity_1 |   Password: 29624af8de
clarity_1 | Clarity 0.9.8 starting up.
clarity_1 |  * listening on 0.0.0.0:80
clarity_1 |  * Running as user daemon
clarity_1 |  * Log mask(s): **/*.log*
clarity_1 |
clarity_1 | 2014-09-14 19:41:06,204 CRIT reaped unknown pid 73)
clarity_1 | 2014-09-14 19:41:06,206 CRIT reaped unknown pid 61)
clarity_1 | 2014-09-14 19:41:06,206 CRIT reaped unknown pid 67)
echos_1   | 2014-09-14 19:41:22,217 INFO success: echos entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1   | 2014-09-14 19:41:22,218 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1   | sshd: started
echos_1   | echos: started
echos_1   | 2014-09-14 19:41:22,235 CRIT reaped unknown pid 22)
echos_1   | 2014-09-14 19:41:22,245 CRIT reaped unknown pid 21)
clarity_1 | 2014-09-14 19:41:23,227 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
clarity_1 | 2014-09-14 19:41:23,227 INFO success: clarity entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
clarity_1 | clarity: started
clarity_1 | sshd: started
clarity_1 | 2014-09-14 19:41:23,245 CRIT reaped unknown pid 22)
clarity_1 | 2014-09-14 19:41:23,252 CRIT reaped unknown pid 21)
```

Notice where we specified the location of the configuration in the
fig-dynamic.yml file. It is in the Hub section, not the Spoke section. And we
also need to include now the repository for the "echos-test" image so that we can
download the default configuration for our original Spoke since it's no longer
being added via the Dockerfile.

[echostest]: https://registry.hub.docker.com/u/brianclements/echos-test/
[logio]: https://github.com/radial/wheel-log.io 
[clarity]: https://github.com/radial/wheel-clarity

## Conclusion

This has been a crash course of how the components of a Wheel all work together.
Modularity and DRY principals are the ultimate goal of Radial, and many more
details will be worked out as more Spoke containers and hybrid Wheels are built
and tested.

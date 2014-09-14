# Wheel Template

This is a template of a Wheel repository. A Wheel repository is the gathering
point for your stacks deployment code.

Some mandatory design features of a Wheel repository:

## File structure

```
.
├── axle
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
    └── Dockerfile
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

Using [this](hub/fig.yml) fig file produces:

```
Successfully built 182f9cbb5b00
Attaching to templatewheel_hub_1, templatewheel_echos_1
hub_1  | ...file permissions successfully applied to /config.
hub_1  | ...file permissions successfully applied to /data.
hub_1  | ...file permissions successfully applied to /log.
hub_1  | Wheel repositories updated.
hub_1  | Container will now idle.
echos_1 | 2014-09-13 22:21:02,123 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
echos_1 | 2014-09-13 22:21:02,132 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
echos_1 | 2014-09-13 22:21:02,133 INFO [2] SSH keys [Authorized]
echos_1 | 2014-09-13 22:21:02,617 CRIT Set uid to user 0
echos_1 | 2014-09-13 22:21:02,617 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
echos_1 | 2014-09-13 22:21:02,617 WARN Included extra file "/config/supervisor/conf.d/logio.ini" during parsing
echos_1 | 2014-09-13 22:21:02,617 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
echos_1 | 2014-09-13 22:21:02,704 INFO RPC interface 'supervisor' initialized
echos_1 | 2014-09-13 22:21:02,705 CRIT Server 'unix_http_server' running without any HTTP authentication checking
echos_1 | 2014-09-13 22:21:02,705 INFO supervisord started with pid 1
echos_1 | 2014-09-13 22:21:04,422 INFO spawned: 'sshd' with pid 27
echos_1 | 2014-09-13 22:21:04,453 INFO spawned: 'echos' with pid 28
echos_1 | 2014-09-13 22:22:04,475 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | 2014-09-13 22:22:04,475 INFO success: echos entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1 | sshd: started
echos_1 | echos: started
echos_1 | 2014-09-13 22:22:04,506 CRIT reaped unknown pid 17)
echos_1 | 2014-09-13 22:22:04,512 CRIT reaped unknown pid 18)
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
directory (which itself is a volume container).

To see normal output, as well as all the changes in the logs as it happens, you
could `docker run -it --volumes-from templatewheel_hub_1 radial/distro:us-west-1
bash` and navigate to `/log` to check them out in a shell, or you could do it
with a dedicated log viewing program in a user friendly way.

Run `fig -f fig-hybrid-wheel.yml up` and navigate to:
[http://localhost:28778/](http://localhost:28778/) to check out the stream.

The output of [this](hub/fig-hybrid-wheel.yml) fig file produces:

```
Successfully built 0c382831f805
Attaching to templatewheel_hub_1, templatewheel_logio_1, templatewheel_echos_1
hub_1   | ...file permissions successfully applied to /config.
hub_1   | ...file permissions successfully applied to /data.
hub_1   | ...file permissions successfully applied to /log.
hub_1   | Wheel repositories updated.
hub_1   | Container will now idle.
logio_1 | 2014-09-13 23:15:48,125 INFO RPC interface 'supervisor' initialized
logio_1 | 2014-09-13 23:15:48,125 CRIT Server 'unix_http_server' running without any HTTP authentication checking
logio_1 | 2014-09-13 23:15:48,125 INFO supervisord started with pid 1
logio_1 | 2014-09-13 23:15:48,581 INFO spawned: 'logio-server' with pid 16
logio_1 | 2014-09-13 23:15:48,585 INFO spawned: 'logio-harvester' with pid 17
echos_1  | 2014-09-13 23:15:50,059 INFO Authorized key ['4096', '7b:e7:12:02:66:0f:d4:00:69:1c:fa:1c:e2:fc:83:50', 'brianclements@github/6317321', '(RSA)']
echos_1  | 2014-09-13 23:15:50,065 INFO Authorized key ['4096', '7f:e3:88:4b:14:45:17:dc:e9:83:1e:e1:b8:92:22:bb', 'brianclements@github/7594005', '(RSA)']
echos_1  | 2014-09-13 23:15:50,065 INFO [2] SSH keys [Authorized]
echos_1  | 2014-09-13 23:15:50,395 CRIT Set uid to user 0
echos_1  | 2014-09-13 23:15:50,396 WARN Included extra file "/config/supervisor/conf.d/sshd.ini" during parsing
echos_1  | 2014-09-13 23:15:50,396 WARN Included extra file "/config/supervisor/conf.d/logio.ini" during parsing
echos_1  | 2014-09-13 23:15:50,396 WARN Included extra file "/config/supervisor/conf.d/echos.ini" during parsing
echos_1  | 2014-09-13 23:15:50,455 INFO RPC interface 'supervisor' initialized
echos_1  | 2014-09-13 23:15:50,455 CRIT Server 'unix_http_server' running without any HTTP authentication checking
echos_1  | 2014-09-13 23:15:50,456 INFO supervisord started with pid 1
echos_1  | 2014-09-13 23:15:52,245 INFO spawned: 'sshd' with pid 31
echos_1  | 2014-09-13 23:15:52,255 INFO spawned: 'echos' with pid 32
logio_1 | ==> /log/738452b44fb6/logio-harvester_stderr.log <==
logio_1 |
logio_1 | ==> /log/738452b44fb6/logio-server_stderr.log <==
logio_1 |
logio_1 | ==> /log/738452b44fb6/logio_stderr.log <==
logio_1 | info: socket.io started
logio_1 | 2014-09-13 23:16:48,843 INFO success: logio-harvester entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
logio_1 | 2014-09-13 23:16:48,844 INFO success: logio-server entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
logio_1 | logio-harvester: started
logio_1 | logio-server: started
logio_1 | 2014-09-13 23:16:49,867 CRIT reaped unknown pid 9)
echos_1  | 2014-09-13 23:16:52,296 INFO success: sshd entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1  | 2014-09-13 23:16:52,296 INFO success: echos entered RUNNING state, process has stayed up for > than 60 seconds (startsecs)
echos_1  | sshd: started
echos_1  | echos: started
echos_1  | 2014-09-13 23:16:52,312 CRIT reaped unknown pid 21)
echos_1  | 2014-09-13 23:16:52,317 CRIT reaped unknown pid 22)
```

On top of our original wheel that had one Spoke container, the "echos-test"
Spoke, now we added another spoke for viewing our logs. Because all Spokes obey
strict rules regarding their configuration and entrypoints, they are all
modular and it is easy to make hybrid Wheels that contain all the apps needed to
make up your full stack.

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
explained above, or via pullable images from a docker registry somewhere.

We use now a different log viewing program called [Clarity][clarity] to view the
logs of the same Wheel. But this time it is done all dynamically. 

Run `fig -f fig-dynamic.yml` and navigate to:
[http://localhost:8989/](http://localhost:8989/) to check out the stream.

The output of [this](hub/fig-dynamic.yml) fig file produces:

```

```

Notice where we specified the location of the configuration in the
fig-dynamic.yml file. It is in the Hub section, not the Spoke section. And we
also need to include now the repository for the "echos-test" image so that we can
download the default configuration for our original Spoke.

[echostest]: https://registry.hub.docker.com/u/brianclements/echos-test/
[logio]: https://github.com/radial/wheel-log.io 
[clarity]: https://github.com/radial/wheel-clarity

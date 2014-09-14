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
Some things to note:

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

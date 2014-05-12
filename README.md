# Wheel Template

This is a template of a Wheel repository. A Wheel repository is the gathering
point for your stacks deployment code.

Some mandatory design features of a Wheel repository:

## File structure

```
.
├── README.md
├── axle
├── hub
│   ├── Dockerfile
│   ├── build-env
│   ├── config
│   │   ├── cat.conf
│   │   └── supervisor
│   │       └── conf.d
│   │           └── cat.ini
│   ├── data
│   │   └── dataset
│   └── log
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
├── cat.conf
└── supervisor
    └── conf.d
            └── cat.ini
```
The two files 'cat.conf' and 'cat.ini' demonstrate the needs of a typical
application, but this folder structure can easily support more complicated
situations.

[config-supervisor]: https://github.com/radial/config-supervisor

## Next

Some ideas for the future regarding Wheels:

* CLI tools:
    * To help streamline all building/running/reconfiguring/management of the
      various containers
    * Since Axle containers, by definition, are depended on by multiple wheels,
      we need a way for check if they already are built at run time, and if not,
      make it so.

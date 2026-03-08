# Standardised Kubernetes Release Process

By default you should not change anything in the `deploy` folder. The following things
should be changed:

- `charts/service/values.yaml` - this configures your service. Have a look at 
  `charts/base/values.yaml` for examples and comments of things you can set.
  - If you choose to add any config files to your deployment, put the files in the
    `charts/service/files` folder.
- `docker/extra-build-commands.sh` - You can run any extra commands as part of the
  build process here
- `docker/extra-commands.sh` - You can run any extra commands against the container
  here eg. install extra packages

You should not change any files other than these, and your service should deploy to
Kubernetes without issues.
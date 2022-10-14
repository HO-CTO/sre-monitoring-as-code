# example-apps

This directory is here to provide example apps to showcase how custom metrics can be shown within the MaC framework.

There are currently three apps.

1. Frontend VueJS app
1. Backend NodeJS app
1. Backend Java app

## Building the apps

First you must build apps before you can run them using the docker-compose file in the root of the directory.

```sh
docker-compose --profile nodejs --profile java build 
```

You may omit `--profile` if you are targeting a specific app to build.

## Running the apps

Once you have built the apps you may run them using the commands below

For the node backend
```sh
docker-compose --profile nodejs up
```

For the java backend
```sh
docker-compose --profile java up
```

## Viewing the apps

The apps will be hosted on localhost:

VueJS Frontend will be on http://localhost:4000 where you may interact with the custom metrics

Both backends wll be on http://localhost:4001. However the metrics endpoint are different.
Node app will be on `/metrics`
Java app will be on `/actuator/prometheus`



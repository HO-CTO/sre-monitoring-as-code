# sre-demo-node-app

This project is for use testing custom metrics from a Node application against the [Monitoring-as-code framework](https://github.com/ho-cto/sre-monitoring-as-code).

## How to build

The demo node application can be run using Docker.

There is a Dockerfile in the root of this repository, which can be built simply by running:

```
docker build -t sre-demo-node-app .
```

## How to run

Once built, the application can be run using the following command:

```
docker run -ti -p 8081:8081 sre-demo-node-app
```

Navigate to http://localhost:8081 and the application should serve a simple HTML page for testing purposes.

## How to integrate with MaC

1. Add a new target file definition into `prometheus/file_sd_configs/<your-app-name>_target.json`. See [here](https://github.com/HO-CTO/sre-monitoring-as-code/tree/main/local#before-running-the-monitoring-local-environment) for more information.

    The file should contain a target definition of the format: 

    ```
    [
    {
        "labels": {
        "job": "custom-node-app",
        "__metrics_path__": "/metrics",
        "namespace": "localhost"
        },
        "targets": [
            "host.docker.internal:8081"
        ]
    }
    ]
    ```

1. Ensure that the custom node application is reachable from the prometheus container.

    If running a local environment using Docker compose, both containers should be on the same network and have the ability to communicate.

1. Interact with the exposed HTML page to generate some custom metrics.

1. Define the custom metric types configuration based on the metrics exported from this demo application and configure appropriate SLI config in the mixin files.

1. Modify the `deploy.sh` file within the MaC framework, or run the MaC docker image to generate the recording and alerting rules for the custom metric type.

1. The metrics should then be visible from within the Prometheus web client and available to see within Grafana dashboards.
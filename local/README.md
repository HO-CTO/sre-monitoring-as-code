# Localdev for Monitoring

L2 Transformer local implementation of Prometheus, Thanos, Grafana, Alertmanager and Yet-Another-Cloudwatch-Exporter using a `docker-compose.yaml` file. The purpose of this project is for proof of concept activity and demos.

## Running the example

```
# clone the project
git clone ssh://git@gitlab.digital.homeoffice.gov.uk:2222/shared-tooling/monitoring/monitoring-local.git
# jump to cloned root directory
cd monitoring-local
# build, start and attach containers for monitoring-local service in detached mode
docker-compose up -d
# once local dev complete stop and shut down containers 
docker-compose down
# remove any remaining volumes
docker volume prune
```

The following services will be installed (and some are accessible via browser):

| Component                     | Description                                                               | URL                           |
| -----------------------       | ------------------------------------------------------                    | ----------------------------- |
| grafana                       | Grafana                                                                   | <http://localhost:3000/>      |
| alertmanager                  | Alertmanager                                                              | <http://localhost:9093/>      |
| prometheus-1                  | Prometheus Server 1                                                       | <http://localhost:9081/>      |
| prometheus-2                  | Prometheus Server 2                                                       | <http://localhost:9082/>      |
| thanos-sidecar-1              | Thanos Sidecar for Prometheus Server 1                                    | not accessible via browser    |
| thanos-sidecar-2              | Thanos Sidecar for Prometheus Server 2                                    | not accessible via browser    |
| thanos-querier                | Thanos Query Gateway                                                      | <http://localhost:10902/>     |
| thanos-ruler                  | Thanos Ruler                                                              | <http://localhost:10903/>     |
| thanos-bucket-web             | Thanos Bucket Web                                                         | <http://localhost:10904/>     |
| thanos-store-gateway          | Thanos Store Gateway                                                      | not accessible via browser    |
| thanos-compactor              | Thanos Compactor                                                          | not accessible via browser    |
| yace                          | Yet Another Cloudwatch Exporter                                           | not accessible via browser    |
| minio                         | Minio - Amazon S3 Compatible Object Storage                               | <http://localhost:9001/>      |

## Credentials

Grafana:

```
username - admin
password - l2password
```

Minio:

```
Access Key - l2accesskey
Secret Key - l2secretkey (Keys are stored in the `docker-compose.yaml` file)
```

## Add Thanos Data Source in Grafana
Is already preconfigured via grafana/provisioning/datasources/datasource.yml but check using:

* Open <http://localhost:3000/datasources>
* Choose `Thanos`
* Click the green button `Save & Test`
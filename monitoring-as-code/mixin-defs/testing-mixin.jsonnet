local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

local config = {
  product: 'testing',
  applicationServiceName: 'Test Service Name',
  servicenowAssignmentGroup: 'test_servicenow_group',
  maxAlertSeverity: 2,
  configurationItem: 'test configuaration item',
  channelRoom: 'test slack channel',
  grafanaUrl: 'testGrafanaUrl',
  alertmanagerUrl: 'testAlertManagerUrl',
  awsAccount: 'test account',
};

local sliSpecList = {
  journey1: {
    SLI01: {
      title: 'sqs messages',
      sliDescription: 'aws sqs description',
      period: '30d',
      metricType: 'aws_sqs',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        freshness: {
          counterSecondsTarget: 100,
          intervalTarget: 90,
        },
        correctness: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'java promclient',
      sliDescription: 'http server request seconds description',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 15,
          percentile: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI03: {
      title: 'grafana http',
      sliDescription: 'grafana_http_request_duration_seconds',
      period: '30d',
      metricType: 'grafana_http_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
        latency: {
          histogramSecondsTarget: 15,
          percentile: 90,
        },
      },
    },
    SLI04: {
      title: 'thanos http',
      sliDescription: 'http_requests_total description',
      period: '30d',
      metricType: 'http_requests_total',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI05: {
      title: 'thanos qry dur',
      sliDescription: 'http_request_duration_seconds histogram/percentile',
      period: '30d',
      metricType: 'http_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 0.1,
          percentile: 90,
        },
      },
    },
    SLI06: {
      title: 'nginx ingress',
      sliDescription: 'nginx_ingress_controller_requests',
      period: '30d',
      metricType: 'nginx_ingress_controller_requests',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI07: {
      title: 'nginx ingress dur',
      sliDescription: 'nginx_ingress_controller_request_duration_seconds',
      period: '30d',
      metricType: 'nginx_ingress_controller_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 0.1,
          percentile: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI08: {
      title: 'alb',
      sliDescription: 'aws alb histrogram',
      period: '30d',
      metricType: 'aws_alb',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 0.1,
          percentile: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI09: {
      title: 'thanos compaction',
      sliDescription: 'Thanos-compact operations and failures',
      period: '30d',
      metricType: 'thanos_compact_group_compactions',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI10: {
      title: 'prom scrape',
      sliDescription: 'prometheus scrape',
      period: '30d',
      metricType: 'up',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI11: {
      title: 'prom scrape dur',
      sliDescription: 'Average duration of Prometheus scrape of Yace',
      period: '30d',
      metricType: 'scrape_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI12: {
      title: 'rds read',
      sliDescription: 'aws rds read',
      period: '30d',
      metricType: 'aws_rds_read',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
        iops: {
          intervalTarget: 90,
        },
        throughput: {
          intervalTarget: 90,
        },
      },
    },
    SLI13: {
      title: 'rds write',
      sliDescription: 'aws rds write',
      period: '30d',
      metricType: 'aws_rds_write',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
        iops: {
          intervalTarget: 90,
        },
        throughput: {
          intervalTarget: 90,
        },
      },
    },
    SLI14: {
      title: 'opensearch',
      sliDescription: 'opensearch',
      period: '30d',
      metricType: 'aws_es',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI15: {
      title: 'nodejs',
      sliDescription: 'nodejs',
      period: '30d',
      metricType: 'nodejs_http_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 15,
          percentile: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI16: {
      title: 's3',
      sliDescription: 's3',
      period: '30d',
      metricType: 'aws_s3',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI17: {
      title: 'gitlab test',
      sliDescription: 'gitlab test',
      period: '30d',
      metricType: 'gitlab_test',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI18: {
      title: 'wks available',
      sliDescription: 'wks available',
      period: '30d',
      metricType: 'aws_workspaces_availability',
      evalInterval: '5m',
      selectors: {
        product: '.*',
        resource: 'd.*',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI19: {
      title: 'wks connections',
      sliDescription: 'wks connections',
      period: '30d',
      metricType: 'aws_workspaces_connection_attempts',
      evalInterval: '5m',
      selectors: {
        product: '.*',
        resource: 'd.*',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI20: {
      title: 'cwa saturation',
      sliDescription: 'cwagent',
      period: '30d',
      metricType: 'aws_cwagent',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        saturation: {
          counterPercentTarget: 90,
          intervalTarget: 90,
        },
      },
    },
    SLI21: {
      title: 'ec2 status check',
      sliDescription: 'ec2 status check',
      period: '30d',
      metricType: 'aws_ec2_status_check',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          counterIntegerTarget: 1,
          intervalTarget: 90,
        },
      },
    },
    SLI22: {
      title: 'asg inservice',
      sliDescription: 'asg inservice instances',
      period: '30d',
      metricType: 'aws_autoscaling_group_in_service_instance',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI23: {
      title: 'cw synth success',
      sliDescription: 'cw synth success',
      period: '30d',
      metricType: 'aws_cwsynthetics_success_check',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          counterIntegerTarget: 100,
        },
      },
    },
  },
};

mixinFunctions.buildMixin(config, sliSpecList)

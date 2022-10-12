local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

local config = {
  product: 'testing',
  applicationServiceName: 'Test Service Name',
  servicenowAssignmentGroup: 'test_servicenow_group',
  maxAlertSeverity: 'P3',
  configurationItem: 'test configuaration item',
  alertingSlackChannel: 'test slack channel',
  grafanaUrl: 'testGrafanaUrl',
  alertmanagerUrl: 'testAlertManagerUrl',
};

local sliSpecList = {
  journey1: {
    SLI01: {
      title: 'AWS SQS',
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
      title: 'Http Srv Request',
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
      title: 'Grafana Requests',
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
      },
    },
    SLI04: {
      title: 'Http Requests',
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
      title: 'Request Duration',
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
      title: 'nginxIngressReq',
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
      title: 'nginxIngressSec',
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
      title: 'AWS ALB',
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
      title: 'Thanos Compact',
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
      title: 'Avaiability',
      sliDescription: 'Avaiability',
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
      title: 'Avg Scrape Secs',
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
      title: 'AWS RDS Read',
      sliDescription: 'test',
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
      title: 'AWS RDS Write',
      sliDescription: 'test',
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
      title: 'OpenSearch',
      sliDescription: 'test',
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
  },
};

mixinFunctions.buildMixin(config, sliSpecList)

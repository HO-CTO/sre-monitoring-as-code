local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

local config = {
  product: 'testing',
  applicationServiceName: 'test',
  servicenowAssignmentGroup: 'test',
  maxAlertSeverity: 'test',
  configurationItem: 'test',
  alertingSlackChannel: 'test',
  grafanaUrl: 'test',
  alertmanagerUrl: 'test',
};

local sliSpecList = {
  journey1: {
    SLI01: {
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test',
      sliDescription: 'test',
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
      title: 'test - aws_rds_read',
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
      title: 'test - aws_rds_write',
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
      title: 'test - OpenSearch',
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

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
      period: '7d',
      metricType: 'aws_sqs',
      evalInterval: '5m',
      latencyTarget: 100,
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        correctness: 0.1,
        freshness: 0.1,
      },
    },
    SLI02: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      latencyPercentile: 0.1,
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 0.1,
      },
    },
    SLI03: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'grafana_http_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI04: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'http_requests_total',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI05: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'http_request_duration_seconds',
      evalInterval: '5m',
      latencyPercentile: 0.1,
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: 0.1,
      },
    },
    SLI06: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'nginx_ingress_controller_requests',
      evalInterval: '5m',
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI07: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'nginx_ingress_controller_request_duration_seconds',
      evalInterval: '5m',
      latencyPercentile: 0.1,
      selectors: {
        product: 'test',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 0.1,
      },
    },
    SLI08: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'aws_alb',
      latencyPercentile: 0.9,
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 0.1,
      },
    },
    SLI09: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'thanos_compact_group_compactions',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI10: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'up',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI11: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'scrape_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI12: {
      title: 'test - aws_rds_read',
      sliDescription: 'test',
      period: '7d',
      metricType: 'aws_rds_read',
      evalInterval: '5m',
      latencyTarget: 0.001,
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: 0.1,
        iops: 0.1,
        throughput: 0.1,
      },
    },
    SLI13: {
      title: 'test - aws_rds_write',
      sliDescription: 'test',
      period: '7d',
      metricType: 'aws_rds_write',
      evalInterval: '5m',
      latencyTarget: 0.001,
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        latency: 0.1,
        iops: 0.1,
        throughput: 0.1,
      },
    },
    SLI14: {
      title: 'test',
      sliDescription: 'test',
      period: '7d',
      metricType: 'aws_es',
      evalInterval: '5m',
      latencyTarget: 0.001,
      selectors: {
        product: 'test',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 0.1,
      },
    },
  },
};

mixinFunctions.buildMixin(config, sliSpecList)

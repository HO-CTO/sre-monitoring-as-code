// MaC imports
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'generic',
  owner: 'enablement team',
  applicationServiceName: '',
  servicenowAssignmentGroup: '',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: '',
  alertingSlackChannel: '',
  grafanaUrl: 'http://localhost:3000',
  alertmanagerUrl: 'http://localhost:9093',
  generic: true,
};

local sliSpecList = {
  a_requests_response: {
    SLI01: {
      title: 'nginx ingress',
      sliDescription: 'Requests through NGINX',
      period: '30d',
      metricType: 'nginx_ingress_controller_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
    SLI02: {
      title: 'java promclient',
      sliDescription: 'Requests through PromClient',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
      title: 'nodejs',
      sliDescription: 'Requests through nodejs',
      period: '7d',
      metricType: 'nodejs_http_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
    SLI05: {
      title: 's3',
      sliDescription: 's3',
      period: '7d',
      metricType: 'aws_s3',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
  b_pub_sub: {
    SLI01: {
      title: 'sqs messages',
      sliDescription: 'All queues for the service',
      period: '30d',
      metricType: 'aws_sqs',
      evalInterval: '5m',
      selectors: {
        product: '.*',
      },
      sloTarget: 90,
      sliTypes: {
        freshness: {
          counterSecondsTarget: 300,
          intervalTarget: 90,
        },
        correctness: {
          intervalTarget: 90,
        },
      },
    },
  },
  c_storage: {
    SLI01: {
      title: 'rds read',
      sliDescription: 'aws rds read',
      period: '30d',
      metricType: 'aws_rds_read',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
    SLI02: {
      title: 'rds write',
      sliDescription: 'aws rds write',
      period: '30d',
      metricType: 'aws_rds_write',
      evalInterval: '5m',
      selectors: {
        product: '.*',
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
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

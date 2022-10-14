// MaC imports
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'generic',
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
  requests: {
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
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

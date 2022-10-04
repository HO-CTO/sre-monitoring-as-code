// MaC imports
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'generic',
  applicationServiceName: '',
  servicenowAssignmentGroup: '',
  // Alerts set to test only - remove/adjust onsce ready for alerts for production
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
      title: 'NGINX requests',
      sliDescription: 'Requests through NGINX',
      period: '30d',
      metricType: 'nginx_ingress_controller_request_duration_seconds',
      evalInterval: '5m',
      latencyPercentile: 0.9,
      selectors: {
        product: '.*',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 15,
      },
    },
    SLI02: {
      title: 'PromClient requests',
      sliDescription: 'Requests through PromClient',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      latencyPercentile: 0.9,
      selectors: {
        product: '.*',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
        latency: 15,
      },
    },
    SLI03: {
      title: 'SQS messages have failed to be processed',
      sliDescription: 'All dead letter queues for the service',
      period: '30d',
      metricType: 'aws_sqs',
      evalInterval: '5m',
      selectors: {
        product: '.*',
      },
      sloTarget: 90,
      sliTypes: {
        correctness: 0.1,
      },
    },
    SLI04: {
      title: 'SQS messages have been queued for too long',
      sliDescription: 'All standard queues for the service',
      period: '30d',
      metricType: 'aws_sqs',
      evalInterval: '5m',
      latencyTarget: 300,
      selectors: {
        product: '.*',
      },
      sloTarget: 90,
      sliTypes: {
        freshness: 0.1,
      },
    },
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

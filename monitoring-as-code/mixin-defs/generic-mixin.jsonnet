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
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

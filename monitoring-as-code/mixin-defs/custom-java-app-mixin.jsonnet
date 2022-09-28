// MaC imports
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'custom-java-app',
  applicationServiceName: '',
  servicenowAssignmentGroup: '',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: '',
  alertingSlackChannel: '',
  grafanaUrl: 'http://localhost:3000',
  alertmanagerUrl: 'http://localhost:9093',
};

local sliSpecList = {
  counter: {
    SLI01: {
      title: 'simple_counter_total',
      sliDescription: 'Custom Java App',
      period: '30d',
      metricType: 'simple_counter_total',
      evalInterval: '5m',
      latencyPercentile: 0.9,
      selectors: {
        product: '.*',
        errorStatus: 'EXCEPTION',
      },
      sloTarget: 90,
      sliTypes: {
        success_transactions: 0.1,
      },
    },
  },
};


// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

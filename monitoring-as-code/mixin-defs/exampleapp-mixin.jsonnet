// Jsonnet file to define SLIs and associated SLOs to allow automtic generation of monitoring configuration
// Configured using mixin format, so exports a grafanaDashboards: object to be consumed by eg Grizzly

// Import Health Config generator framework
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'exampleapp',
  applicationServiceName: 'Example App',
  servicenowAssignmentGroup: 'Example App',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: '',
  alertingSlackChannel: 'sas-monitoring-test',
  runbookUrl: 'https://grafana-leds.np.ebsa.homeoffice.gov.uk',
  grafanaUrl: 'https://grafana-leds.np.ebsa.homeoffice.gov.uk',
  alertmanagerUrl: 'https://alertmanager-monitoring-i-docker-leds1.np.ebsa.homeoffice.gov.uk',
};

local sliSpecList = {
  requests: {
    SLI01: {
      title: 'java promclient',
      sliDescription: 'Requests through PromClient',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.*custom-java-app.*',
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
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

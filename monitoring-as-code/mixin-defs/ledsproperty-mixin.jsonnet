// Jsonnet file to define SLIs and associated SLOs to allow automtic generation of monitoring configuration
// Configured using mixin format, so exports a grafanaDashboards: object to be consumed by eg Grizzly

// Import Health Config generator framework
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'leds-property',
  applicationServiceName: 'LEDS Property',
  servicenowAssignmentGroup: 'LEDS Property DevOps',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: '',
  alertingSlackChannel: 'sas-monitoring-test',
  runbookUrl: 'https://grafana-leds.np.ebsa.homeoffice.gov.uk',
  grafanaUrl: 'https://grafana-leds.np.ebsa.homeoffice.gov.uk',
  alertmanagerUrl: 'https://alertmanager-monitoring-i-docker-leds1.np.ebsa.homeoffice.gov.uk',
};

local sliSpecList = {
  enquiry: {
    SLI01: {
      title: 'all nginx requests',
      sliDescription: 'requests through nginx',
      period: '30d',
      metricType: 'nginx_ingress_controller_request_duration_seconds',
      evalInterval: '5m',
      selectors: {
        product: 'prop.+',
        errorStatus: '4..|5..',
      },
      sloTarget: 90.0,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 0.250,
          percentile: 0.9,
        },
        availability: {
          intervalTarget: 90.0,
        },
      },
    },
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

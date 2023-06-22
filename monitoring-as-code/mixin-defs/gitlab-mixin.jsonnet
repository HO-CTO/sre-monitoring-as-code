// Jsonnet file to define SLIs and associated SLOs to allow automtic generation of monitoring configuration
// Configured using mixin format, so exports a grafanaDashboards: object to be consumed by eg Grizzly

// Import Health Config generator framework
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'gitlab',
  applicationServiceName: 'LECP (Law Enforcement Cloud Platform',
  servicenowAssignmentGroup: 'LECP Platform DevOps INC',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: 'LECP GitLab (App Svc)',
  alertingSlackChannel: 'ops-alerting',
  grafanaUrl: 'https://g-374a9eae49.grafana-workspace.eu-west-2.amazonaws.com/',
  alertmanagerUrl: 'https://g-374a9eae49.grafana-workspace.eu-west-2.amazonaws.com/alerting/list',
};

local sliSpecList = {
  gitlabserver: {
    SLI01: {
      title: 'SCM',
      sliDescription: 'Source Code Mgmt in Gitlab',
      period: '30d',
      metricType: 'gitlab_http_request_total',
      evalInterval: '5m',
      selectors: {
        product: 'glb-collector',
        resource: 'source_code_management',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'CI',
      sliDescription: 'Continuous Integration in Gitlab',
      period: '30d',
      metricType: 'gitlab_http_request_total',
      evalInterval: '5m',
      selectors: {
        product: 'glb-collector',
        resource: 'continuous_integration',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI03: {
      title: 'Unknown',
      sliDescription: 'Unknown in Gitlab',
      period: '30d',
      metricType: 'gitlab_http_request_total',
      evalInterval: '5m',
      selectors: {
        product: 'glb-collector',
        resource: 'unknown',
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
      title: 'All Features',
      sliDescription: 'All feature in Gitlab',
      period: '30d',
      metricType: 'gitlab_http_request_total',
      evalInterval: '5m',
      selectors: {
        product: 'glb-collector',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 0.5,
          percentile: 90,
        },
      },
    },
  },
};


// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

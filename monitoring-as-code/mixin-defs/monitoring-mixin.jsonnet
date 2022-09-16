// Jsonnet file to define SLIs and associated SLOs to allow automtic generation of monitoring configuration
// Configured using mixin format, so exports a grafanaDashboards: object to be consumed by eg Grizzly

// Import Health Config generator framework
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'monitoring',
  applicationServiceName: 'EBSA Monitoring and Logging Components',
  servicenowAssignmentGroup: 'HO_EBSA_PLATFORM',
  // Alerts set to test only - remove/adjust once ready for alerts for production
  maxAlertSeverity: 'P1',
  configurationItem: 'EBSA Prometheus, Grafana and Thanos',
  alertingSlackChannel: 'sas-monitoring-test',
  grafanaUrl: 'http://localhost:3000',
  alertmanagerUrl: 'http://localhost:9093',
};

local sliSpecList = {
  grafana: {
    SLI01: {
      title: 'requests to the Grafana landing page are successful',
      sliDescription: 'Grafana landing page requests',
      period: '7d',
      metricType: 'grafana_http_request_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'grafana',
        resource: '/api/dashboards/home',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI02: {
      title: 'requests to the Grafana login are successful',
      sliDescription: 'Grafana login page requests',
      period: '7d',
      metricType: 'grafana_http_request_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'grafana',
        resource: '/login',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI03: {
      title: 'requests to the Grafana datasources are successful',
      sliDescription: 'Grafana  datasource API requests',
      period: '7d',
      metricType: 'grafana_http_request_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'grafana',
        resource: '/api/datasources/proxy/:id/.*',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.5,
      },
    },
  },
  prometheus: {
    SLI01: {
      title: 'all prometheus scrape targets are available',
      sliDescription: 'Average of prometheus scrape target status',
      period: '7d',
      metricType: 'up',
      comparison: '==',
      evalInterval: '1m',
      selectors: {},
      sloTarget: 90,
      sliTypes: {
        availability: 1,
      },
    },
    SLI02: {
      title: 'prometheus scraping of Yace is fast enough',
      sliDescription: 'Average duration of Prometheus scrape of Yace',
      period: '7d',
      metricType: 'scrape_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'yace',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 15,
      },
    },
  },
  thanos: {
    SLI01: {
      title: 'instant query requests to Thanos',
      sliDescription: 'Instant query requests to thanos-query',
      period: '7d',
      metricType: 'http_requests_total',
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI02: {
      title: 'instant query requests to Thanos are fast enough',
      sliDescription: 'Instant query requests to thanos-query',
      period: '7d',
      metricType: 'http_request_duration_seconds',
      latencyPercentile: 0.8,
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query',
      },
      sliTypes: {
        latency: 15,
      },
      sloTarget: 90,
    },
    SLI03: {
      title: 'range query requests to Thanos',
      sliDescription: 'Range query requests to thanos-query',
      period: '7d',
      metricType: 'http_requests_total',
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query_range',
        errorStatus: '4..|5..',
      },
      sloTarget: 90,
      sliTypes: {
        availability: 0.1,
      },
    },
    SLI04: {
      title: 'range query requests to Thanos are fast enough',
      sliDescription: 'Range query requests to thanos-query',
      period: '7d',
      metricType: 'http_request_duration_seconds',
      latencyPercentile: 0.8,
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query_range',
      },
      sliTypes: {
        latency: 10,
      },
      sloTarget: 90,
    },
    SLI05: {
      title: 'compactions by thanos-compact',
      sliDescription: 'Thanos-compact operations and failures',
      period: '7d',
      metricType: 'thanos_compact_group_compactions',
      evalInterval: '1m',
      selectors: {
        product: 'monitoring-thanos-compact.*',
      },
      sloTarget: 99,
      sliTypes: {
        availability: 0.01,
      },
    },
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

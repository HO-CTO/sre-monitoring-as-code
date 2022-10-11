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
      title: 'Landing page requests ',
      sliDescription: 'Number of requests to the Grafana landing page are successful',
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
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'Grafana login page requests',
      sliDescription: 'requests to the Grafana login are successful',
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
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI03: {
      title: 'Grafana datasource API requests',
      sliDescription: 'requests to the Grafana datasources are successful',
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
        availability: {
          intervalTarget: 90,
        },
      },
    },
  },
  prometheus: {
    SLI01: {
      title: 'prometheus scrape target status',
      sliDescription: 'all prometheus scrape targets are available',
      period: '7d',
      metricType: 'up',
      comparison: '==',
      evalInterval: '1m',
      selectors: {},
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'Average duration of Prometheus scrape of Yace',
      sliDescription: 'prometheus scraping of Yace is fast enough',
      period: '7d',
      metricType: 'scrape_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'yace',
      },
      sloTarget: 90,
      sliTypes: {
        availability: {
          intervalTarget: 90,
        },
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
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'Instant query requests to thanos-query',
      sliDescription: 'instant query requests to Thanos are fast enough',
      period: '7d',
      metricType: 'http_request_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query',
      },
      sliTypes: {
        latency: {
          histogramSecondsTarget: 15,
          percentile: 80,
        },
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
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI04: {
      title: 'Range query requests to thanos-query',
      sliDescription: 'range query requests to Thanos are fast enough',
      period: '7d',
      metricType: 'http_request_duration_seconds',
      evalInterval: '1m',
      selectors: {
        product: 'thanos-query',
        resource: 'query_range',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          histogramSecondsTarget: 10,
          percentile: 80,
        },
      },
    },
    SLI05: {
      title: 'Thanos-compact operations and failures',
      sliDescription: 'compactions by thanos-compact',
      period: '7d',
      metricType: 'thanos_compact_group_compactions',
      evalInterval: '1m',
      selectors: {
        product: 'monitoring-thanos-compact.*',
      },
      sloTarget: 99,
      sliTypes: {
        availability: {
          intervalTarget: 99,
        },
      },
    },
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

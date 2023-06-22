// Jsonnet file to define SLIs and associated SLOs to allow automtic generation of monitoring configuration
// Configured using mixin format, so exports a grafanaDashboards: object to be consumed by eg Grizzly

// Import Health Config generator framework
local mixinFunctions = import '../src/lib/mixin-functions.libsonnet';

// Define product name and technow details
local config = {
  product: 'ledsproperty',
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
      title: 'nginx',
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
          histogramSecondsTarget: 0.1,
          percentile: 90,
        },
        availability: {
          intervalTarget: 90,
        },
      },
    },
    SLI02: {
      title: 'search prop',
      sliDescription: 'search property requests as measured from prom client',
      configurationItem: 'LEDS Property API Core (App Svc)',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.+/prop-core-api-helm',
        resource: '/reference-data-sets/.+',
        errorStatus: '4..|5..',
      },
      sloTarget: 90.0,
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
      title: 'search results',
      sliDescription: 'property search results requests',
      configurationItem: 'LEDS Property API Search (App Svc)',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.+/prop-search-api-helm',
        resource: '/search',
        errorStatus: '4..|5..',
      },
      sloTarget: 90.0,
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
    SLI04: {
      title: 'view items',
      sliDescription: 'property view item requests',
      configurationItem: 'LEDS Property API Core (App Svc)',
      period: '30d',
      metricType: 'http_server_requests_seconds',
      evalInterval: '5m',
      selectors: {
        product: '.+/prop-core-api-helm',
        resource: '/property/items/{guid}',
        errorStatus: '4..|5..',
      },
      sloTarget: 90.0,
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
      title: 'audit events',
      sliDescription: 'All dead letter queues for the service',
      metricType: 'aws_sqs',
      period: '30d',
      evalInterval: '5m',
      selectors: {
        product: 'cloudwatch-exporter',
      },
      sloTarget: 90.0,
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
    SLI06: {
      title: 'opensearch rqsts',
      sliDescription: 'aws_es',
      period: '30d',
      metricType: 'aws_es',
      evalInterval: '5m',
      selectors: {
        product: 'cloudwatch-exporter',
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
    SLI07: {
      title: 'rds reads',
      sliDescription: 'test',
      period: '30d',
      metricType: 'aws_rds_read',
      evalInterval: '5m',
      selectors: {
        product: 'cloudwatch-exporter',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
      },
    },
    SLI08: {
      title: 'rds writes',
      sliDescription: 'test',
      period: '30d',
      metricType: 'aws_rds_write',
      evalInterval: '5m',
      selectors: {
        product: 'cloudwatch-exporter',
      },
      sloTarget: 90,
      sliTypes: {
        latency: {
          counterSecondsTarget: 0.25,
          intervalTarget: 90,
        },
      },
    },
  },
};

// Run generator to create dashboards, prometheus rules
mixinFunctions.buildMixin(config, sliSpecList)

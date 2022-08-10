// This file is for storing the config of the MaC framework

// MaC imports
local sliMetricConfig = import 'sli-metric-config.libsonnet';

// Config items
// Collection of imports for detail dashboard elements
local detailDashboardElements = {
  httpRequestsAvailability: (import 'dashboards/detail-dashboard-elements/http-requests-availability.libsonnet'),
  httpRequestsLatency: (import 'dashboards/detail-dashboard-elements/http-requests-latency.libsonnet'),
  cloudwatchSqs: (import 'dashboards/detail-dashboard-elements/cloudwatch-sqs.libsonnet'),
};

// The list of error budget burn rate windows used for alerts
local burnRateWindowList = [
  { severity: '1', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
  { severity: '2', 'for': '2m', long: '6h', short: '30m', factor: 6 },
  { severity: '4', 'for': '3h', long: '3d', short: '6h', factor: 1 },
];

// The template for error budget burn rule names
local burnRateRuleNameTemplate = 'slo_burnrate:%s';

// The localhost urls for alerts
local localhostUrls = {
  grafana: 'localhost:3000',
  alertmanager: 'localhost:9093',
};

// File exports
{
  sliTypesConfig: sliMetricConfig.sliTypesConfig,
  detailDashboardElements: detailDashboardElements,
  burnRateWindowList: burnRateWindowList,
  burnRateRuleNameTemplate: burnRateRuleNameTemplate,
  localhostUrls: localhostUrls,
}

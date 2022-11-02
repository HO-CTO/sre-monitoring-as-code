local defaultMetricTypes = import 'metric-types.libsonnet';

local customMetricTypes = if std.extVar('CUSTOM_METRIC_TYPES') == 'true' then import '../mixin-defs/custom-metric-types.libsonnet' else {};

// This file is for storing the config of the MaC framework

// MaC prefix
local macPrefix = 'SRE MaC';

// MaC dashboard title and uid prefix
local macDashboardPrefix = {
  title: macPrefix,
  uid: std.strReplace(std.asciiLower(macPrefix), ' ', '-'),
};

// Dashboard documentation to be added to text panel. Content to be written as markdown.
local dashboardDocs = {
  overView: '#### Overview\n\n**Purpose:** Observability of all products and tenants running on a platform.\n\n**Directions for use:** An aggregated SLO Status is presented in table panels by Product. The first table displays the aggregated SLO Status with supplementary data regarding traffic and alerts. The second table displays the SLO Status grouped by SLI type. The dashboard can be filtered by Environment.',
  productView: '#### Product View\n\n**Purpose:** Observability of all the user journeys running on an individual product.\n\n**Directions for use:** Distinct user journeys are presented as row panels. SLIs are presented as stat panels with colour thresholds indicating the SLO Status. SLI Types (such as Availability and Latency) are aggregated into a single SLI Stat Panel. The dashboard can be filtered by Environment.',
  journeyView: '#### User Journey View\n\n**Purpose:** Observability of all the SLIs in a single user journey.\n\n**Directions for use:** SLIs are presented in a series of 3 core panels: (1) a stat panel showing SLO Status, (2) an error budget burn graph and (3) a request/error graph. SLIs types relating to the same source metric are grouped under a single SLI Row Panel. Colour thresholds indicate the SLO Status. The dashboard can be filtered by Error Budget Period and Environment.',
  detailView: '#### Detail View\n\n**Purpose:** Observability of all whitebox and blackbox metrics which contribute to SLIs and Service Health. For troubleshooting.\n\n**Directions for use:** TBC.',
};

// Config items
// Collection of imports for detail dashboard elements
local detailDashboardElements = {
  httpRequestsAvailability: (import 'dashboards/detail-dashboard-elements/http-requests-availability.libsonnet'),
  httpRequestsLatency: (import 'dashboards/detail-dashboard-elements/http-requests-latency.libsonnet'),
  cloudwatchSqs: (import 'dashboards/detail-dashboard-elements/cloudwatch-sqs.libsonnet'),
  customMetric: (import 'dashboards/detail-dashboard-elements/custom-metric.libsonnet'),
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
  grafana: 'http://localhost:3000',
  alertmanager: 'http://localhost:9093',
};

// The keys are the labels in the alert payload, the values are either the static value as a string,
// a string reference to the variable name or a mix of both
local alertPayloadTemplate = {
  source_instance: 'Prometheus',
  node_id: '%(config.applicationServiceName)s',
  resource_id: '%(config.applicationServiceName)s',
  event_short_desc: '%(sliSpec.title)s',
  event_description: '%(sliKey)s (%(journeyKey)s journey) is likely to exhaust error budget in less than %(exhaustionDays).2f days',
  metric_name: '%(sliSpec.sliType)s',
  event_type: '%(sliSpec.sliType)s',
  message_key: 'Prometheus_%(config.applicationServiceName)s_%(sliSpec.sliType)s_%(config.applicationServiceName)s',
  event_severity: '%(severity)s',
  raw_event_payload: '"journey":"%(journeyKey)s","sli":"%(sliKey)s","mac_version":"%(config.macVersion)s","monitoring_slackchannel":"%(config.alertingSlackChannel)s","configuration_item":"%(configurationItem)s"',
  assignment_group: '%(config.servicenowAssignmentGroup)s',
  runbook_id: '%(runbookUrl)s',
};

// File exports
{
  macPrefix: macPrefix,
  macDashboardPrefix: macDashboardPrefix,
  dashboardDocs: dashboardDocs,
  metricTypes: defaultMetricTypes + customMetricTypes,
  detailDashboardElements: detailDashboardElements,
  burnRateWindowList: burnRateWindowList,
  burnRateRuleNameTemplate: burnRateRuleNameTemplate,
  localhostUrls: localhostUrls,
  alertPayloadTemplate: alertPayloadTemplate,
}

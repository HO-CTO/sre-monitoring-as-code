// Library to generate Grafana and Prometheus config for AWS Cloudwatch LoadBalancer latency metrics

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;

// Gets valid formatted Cloudwatch percentile
// @param sliSpec The spec for the SLI being processed
// @returns Formatted Cloudwatch percentile
local getCloudwatchPercentile(sliSpec) =
  if sliSpec.latencyPercentile == 0.9 then 'p90'
  else if sliSpec.latencyPercentile == 0.95 then 'p95'
  else if sliSpec.latencyPercentile == 0.99 then 'p99'
  else error 'Invalid latency percentile for Cloudwatch ALB latency';

// Creates Grafana dashboard graph panel for an SLI type
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliMetricLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);

  graphPanel.new(
    title = 'Latency - %s' % sliSpec.sliDescription,
    description = |||
      * Sample interval is %(evalInterval)s 
      * Resource selectors are %(selectors)s
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
    },
    datasource = 'prometheus',
    min = 0,
    format = 's',
    thresholds = [
      {
        value: sliSpec.metricTarget,
        colorMode: 'critical',
        op: 'gt',
        line: true,
        fill: false,
      },
    ],
  ).addTarget(
    prometheus.target(
      'avg (%(responseTimeMetric)s_average{%(selectors)s})' % {
        responseTimeMetric: metricConfig.metrics.responseTime,
        selectors: std.join(',', dashboardSelectors)
      },
      legendFormat = 'Average Latency',
    ),
  ).addTarget(
    prometheus.target(
      'max (%(responseTimeMetric)s_p90{%(selectors)s})' % {
        responseTimeMetric: metricConfig.metrics.responseTime,
        selectors: std.join(',', dashboardSelectors)
      },
      legendFormat = 'Max p90 Latency',
    ),
  ).addTarget(
    prometheus.target(
      'max (%(responseTimeMetric)s_p95{%(selectors)s})' % {
        responseTimeMetric: metricConfig.metrics.responseTime,
        selectors: std.join(',', dashboardSelectors)
      },
      legendFormat = 'Max p95 Latency',
    ),
  ).addTarget(
    prometheus.target(
      'max (%(responseTimeMetric)s_p99{%(selectors)s})' % {
        responseTimeMetric: metricConfig.metrics.responseTime,
        selectors: std.join(',', dashboardSelectors)
      },
      legendFormat = 'Max p99 Latency',
    ),
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);
  local cloudwatchPercentile = getCloudwatchPercentile(sliSpec);

  [
    {
      record: 'sli_value',
      expr: |||
        max(%(responseTimeMetric)s_%(cloudwatchPercentile)s{%(selectors)s})
      ||| % {
        responseTimeMetric: metricConfig.metrics.responseTime,
        selectors: std.join(',', ruleSelectors),
        cloudwatchPercentile: cloudwatchPercentile,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction) =
  [

  ];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction) =
  std.flattenArrays([
    
  ]);

// File exports
{
  description: 'Target latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
  category: 'Latency',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction): createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction),
}

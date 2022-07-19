// Library to generate Grafana and Prometheus config for Cloudwatch ALB availability

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;

// Creates Grafana dashboard graph panel for an SLI type
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliMetricLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);

  graphPanel.new(
    title = 'Requests, errors, and error rate - %s' % sliSpec.sliDescription,
    description = |||
      * Sample interval is %(evalInterval)s 
      * Resource selectors are %(selectors)s
      * Errors are 4_xx and 5_xx count
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
    },
    datasource = 'prometheus',
    min = 0,
    fill = 0,
    formatY2 = 'percentunit',
    thresholds = [
      {
        value: sliSpec.metricTarget,
        colorMode: 'critical',
        op: 'gt',
        line: true,
        fill: false,
        yaxis: 'right',
      },
    ],
  ).addTarget(
    prometheus.target(
      'sum(rate(%(requestCountMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
        requestCountMetric: metricConfig.metrics.requestCount,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Requests per second',
    ),
  ).addTarget(
    prometheus.target(
      '(sum(rate(%(count4xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)) + 
        sum(rate(%(count5xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)))' % {
          count4xxMetric: metricConfig.metrics.count4xx,
          count5xxMetric: metricConfig.metrics.count5xx,
          selectors: std.join(',', dashboardSelectors),
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'Errors per second',
    )
  ).addTarget(
    prometheus.target(
      '(sum(rate(%(count4xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)) + 
        sum(rate(%(count5xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))) / 
        sum(rate(%(requestCountMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
          count4xxMetric: metricConfig.metrics.count4xx,
          count5xxMetric: metricConfig.metrics.count5xx,
          requestCountMetric: metricConfig.metrics.requestCount,
          selectors: std.join(',', dashboardSelectors),
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'Error rate',
    )
  ).addSeriesOverride(
    {
      alias: '/Error rate/',
      yaxis: 2,
      color: 'red',
    },
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);

  [
    {
      record: 'sli_value',
      expr: |||
        (sum(rate(%(count4xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)) + 
        sum(rate(%(count5xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))) /
        sum(rate(%(requestCountMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        count4xxMetric: metricConfig.metrics.count4xx,
        count5xxMetric: metricConfig.metrics.count5xx,
        requestCountMetric: metricConfig.metrics.requestCount,
        selectors: std.join(',', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
    {
      record: 'aggregated_alb_request_count_sum',
      expr: |||
        (sum(sum_over_time(%(requestCountMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)))
        >= 0
      ||| % {
        requestCountMetric: metricConfig.metrics.requestCount,
        selectors: std.join(',', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(direction) =
  [

  ];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction) =
  std.flattenArrays([
    
  ]);

// File exports
{
  description: 'the error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
  category: 'Availability',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

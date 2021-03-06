// Library to generate Grafana and Prometheus config for service error rate metrics

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;

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
      * Request selectors are %(selectors)s
      * Error selectors are %(errorSelector)s
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
      errorSelector: sliMetricLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
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
      'sum(rate(%(countMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
        countMetric: metricConfig.metrics.count,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Requests per second',
    ),
  ).addTarget(
    prometheus.target(
      'sum(rate(%(countMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' %
      {
        countMetric: metricConfig.metrics.count,
        selectors: std.join(',', dashboardSelectors + [sliMetricLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec)]),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Errors per second',
    )
  ).addTarget(
    prometheus.target(
      'sum(rate(%(countMetric)s{%(errorSelectors)s}[%(evalInterval)s]) or vector(0)) / 
        sum(rate(%(countMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
          countMetric: metricConfig.metrics.count,
          selectors: std.join(',', dashboardSelectors),
          errorSelectors: std.join(',', dashboardSelectors + [sliMetricLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec)]),
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'Error rate',
    )
  ).addSeriesOverride(
    {
      alias: '/Error rate/',
      yaxis: 2,
      color: 'red',
    }
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
        sum(rate(%(countMetric)s{%(errorSelectors)s}[%(evalInterval)s]) or vector(0)) / 
        sum(rate(%(countMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        countMetric: metricConfig.metrics.count,
        selectors: std.join(',', ruleSelectors),
        errorSelectors: std.join(',', ruleSelectors + [sliMetricLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec)]),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(direction) =
  [];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction) =
  std.flattenArrays([
    [row.new(
      title = stringFormattingFunctions.capitaliseFirstLetters('%s HTTP Requests Availability' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [graphPanel.new(
      title = 'Availability - requests per second by response code',
      datasource = 'prometheus',
      min = 0,
      fill = 10,
      stack = true,
      lines = false,
      bars = true,
      legend_hideZero = true,
    ).addTarget(
      prometheus.target(|||
          sum by (%(errorSelectorLabels)s) (rate({__name__=~"%(countMetrics)s", %(selectors)s}[$__rate_interval]))
        ||| % {
          errorSelectorLabels: std.join(', ', selectorLabels[direction]['errorStatus']),
          countMetrics: std.join('|', metrics[direction][sliType].count),
          selectors: std.join(', ', std.objectValues(selectors[direction])),
        },
        legendFormat = '{{%s}}' % std.join(', ', selectorLabels[direction]['errorStatus']))
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      title = 'Availability - requests per second by path',
      datasource = 'prometheus',
      min = 0,
      fill = 10,
      stack = true,
      lines = false,
      bars = true,
      legend_hideZero = true,
    ).addTarget(
      prometheus.target(|||
          sum by (%(resourceSelectorLabels)s) (rate({__name__=~"%(countMetrics)s", %(selectors)s}[$__rate_interval]))
        ||| % {
          resourceSelectorLabels: std.join(', ', selectorLabels[direction]['resource']),
          countMetrics: std.join('|', metrics[direction][sliType].count),
          selectors: std.join(', ', std.objectValues(selectors[direction])),
        },
        legendFormat = '{{%s}}' % std.join(', ', selectorLabels[direction]['resource']))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

// File exports
{
  description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
  category: 'Availability',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

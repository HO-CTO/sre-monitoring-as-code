// Library for average value metrics

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
  local targetMetric = sliMetricLibraryFunctions.getTargetMetric(sliSpec);

  graphPanel.new(
    title = 'Latency - %s' % sliSpec.sliDescription,
    description = |||
      * Sample interval is %(evalInterval)s 
      * Request selectors are %(selectors)s
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
    },
    datasource = 'prometheus',
    fill = 0,
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
      'avg_over_time(%(metric)s{%(selectors)s}[%(evalInterval)s])' % {
        metric: metricConfig.metrics[targetMetric],
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Average %s' % sliSpec.sliDescription,
    )
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @param config The config for the service defined in the mixin file
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);
  local targetMetric = sliMetricLibraryFunctions.getTargetMetric(sliSpec);

  [
    {
      record: 'sli_value',
      expr: |||
        avg_over_time(%(metric)s{%(selectors)s}[%(evalInterval)s])
      ||| % {
        metric: metricConfig.metrics[targetMetric],
        selectors: std.join(',', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// File exports
{
  description: '',
  category: '',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
}

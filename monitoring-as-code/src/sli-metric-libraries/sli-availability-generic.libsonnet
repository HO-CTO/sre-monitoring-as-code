// Library to generate Grafana and Prometheus config for generic availability

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
    title = '%s' % sliSpec.sliDescription,
    description = |||
      * Sample interval is %(evalInterval)s 
    ||| % {
      evalInterval: sliSpec.evalInterval,
    },
    datasource = 'prometheus',
    min = 0,
    fill = 0,
    formatY2 = 'percentunit',
  ).addTarget(
    prometheus.target(
      'sum(rate(%(totalMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
        totalMetric: metricConfig.metrics.total,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Total per second',
    ),
  ).addTarget(
    prometheus.target(
      'sum(rate(%(totalFailuresMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
        totalFailuresMetric: metricConfig.metrics.totalFailures,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'Errors per second',
    )
  ).addTarget(
    prometheus.target(
      'sum(rate(%(totalFailuresMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)) / 
        sum(rate(%(totalMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
          totalFailuresMetric: metricConfig.metrics.totalFailures,
          totalMetric: metricConfig.metrics.total,
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
    }
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @param config The config for the service defined in the mixin file
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);

  [
    {
      record: 'sli_value',
      expr: |||
        sum(rate(%(totalFailuresMetric)s{%(selectors)s}[%(evalInterval)s])) / 
        sum(rate(%(totalMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        selectors: std.join(',', ruleSelectors),
        totalFailuresMetric: metricConfig.metrics.totalFailures,
        totalMetric: metricConfig.metrics.total,
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// File exports
{
  description: 'the rate of %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
  category: 'Availability',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
}

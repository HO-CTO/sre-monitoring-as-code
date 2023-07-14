// Divides the sum of sum over time of target metric samples by the sum of count over time of
// target metric samples

// Target metrics:
// failure1 - Metric representing the first selected failure metric
// failure2 - Metric representing the second selected failure metric
// success - Metric representing the success metric

// MaC imports
local sliValueLibraryFunctions = import '../util/sli-value-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;

// Creates the custom SLI value rule
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @param config The config for the service defined in the mixin file
// @returns JSON defining the recording rule
local createSliValueRule(sliSpec, sliMetadata, config) =
  local metricConfig = sliValueLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliValueLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);
  local targetMetrics = sliValueLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);
  local selectorLabels = sliValueLibraryFunctions.getSelectorLabels(metricConfig);

  [
    {
      record: 'sli_value',
      expr: |||
        sum without (%(selectorLabels)s) (label_replace(label_replace(
          (
            (
            sum by(%(selectorLabels)s) (avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]))
            +
            sum by(%(selectorLabels)s) (avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]))
            )
            /
            (
            sum by(%(selectorLabels)s) (avg_over_time(%(successMetric)s{%(selectors)s}[%(evalInterval)s]))
            +
            sum by(%(selectorLabels)s) (avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]))
            +
            sum by(%(selectorLabels)s) (avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]))
            )
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        failureMetric1: targetMetrics.failure1,
        failureMetric2: targetMetrics.failure2,
        successMetric: targetMetrics.success,
        selectorLabels: std.join(', ', std.objectValues(selectorLabels)),
        environmentSelectorLabel: selectorLabels.environment,
        productSelectorLabel: selectorLabels.product,
        selectors: std.join(', ', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates Grafana dashboard graph panel
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliValueLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliValueLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);
  local targetMetrics = sliValueLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);

  graphPanel.new(
    title='%s' % sliSpec.sliDescription,
    datasource='prometheus',
    description=|||
      * Sample interval is %(evalInterval)s
      * Selectors are %(selectors)s
    ||| % {
      selectors: std.strReplace(std.join(', ', sliValueLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
      evalInterval: sliSpec.evalInterval,
    },
    min=0,
    fill=0,
    formatY2='percentunit',
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(successMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        failureMetric1: targetMetrics.failure1,
        failureMetric2: targetMetrics.failure2,
        successMetric: targetMetrics.success,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='total',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        failureMetric1: targetMetrics.failure1,
        failureMetric2: targetMetrics.failure2,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='failures',
    ),
  ).addTarget(
    prometheus.target(
      |||
        (
        sum(avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        )
        /
        (
        sum(avg_over_time(%(successMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(failureMetric1)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        +
        sum(avg_over_time(%(failureMetric2)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        )
      ||| % {
        failureMetric1: targetMetrics.failure1,
        failureMetric2: targetMetrics.failure2,
        successMetric: targetMetrics.success,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='failure average',
    ),
  ).addSeriesOverride(
    {
      alias: '/error rate/',
      yaxis: 2,
      color: 'red',
    }
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

// Divides the sum of rate of change of failure metric samples by the sum of rate of change of
// success and failure metric samples

// Target metrics:
// failure - Metric representing the total number of failures
// successAndFailure - Metric representing the total number of successes and failures

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
            sum by(%(selectorLabels)s) (rate(%(failureMetric)s{%(selectors)s}[%(evalInterval)s]))
            /
            sum by(%(selectorLabels)s) (rate(%(successAndFailureMetric)s{%(selectors)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        failureMetric: targetMetrics.failure,
        successAndFailureMetric: targetMetrics.successAndFailure,
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
        sum(rate(%(successAndFailureMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        successAndFailureMetric: targetMetrics.successAndFailure,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='total per second',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(rate(%(failureMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        failureMetric: targetMetrics.failure,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='errors per second',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(rate(%(failureMetric)s{%(selectors)s}[%(evalInterval)s]))
        /
        sum(rate(%(successAndFailureMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        failureMetric: targetMetrics.failure,
        successAndFailureMetric: targetMetrics.successAndFailure,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='errors rate',
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

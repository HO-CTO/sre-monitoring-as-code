// Divides the count of target metric samples above availability target by the overall count of samples
// target metric samples taken from average-using-single-metric

// Target metrics:
// target - Metric to get the average value of over evaluation interval

// Additional config:
// counterIntegerTarget in SLI spec

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
            sum by(%(selectorLabels)s) (avg_over_time((%(targetMetric)s{%(selectors)s} >= bool %(counterIntegerTarget)s)[%(evalInterval)s:%(evalInterval)s]))
            /
            count by(%(selectorLabels)s) (count_over_time(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        targetMetric: targetMetrics.target,
        counterIntegerTarget: sliSpec.counterIntegerTarget,
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
    fill=4,
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]) >= 0 or vector(0)) == bool 0
      ||| % {
        targetMetric: targetMetrics.target,
        counterIntegerTarget: sliSpec.counterIntegerTarget,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg success',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time((%(targetMetric)s{%(selectors)s} >= bool %(counterIntegerTarget)s)[%(evalInterval)s:%(evalInterval)s]) or vector(0))
        /
        count(count_over_time(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        targetMetric: targetMetrics.target,
        counterIntegerTarget: sliSpec.counterIntegerTarget,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg period where status failures > %s' % sliSpec.counterIntegerTarget,
    )
  ).addSeriesOverride(
    {
      alias: '/avg period where status failures > %s/' % sliSpec.counterIntegerTarget,
      color: 'red',
    },
  ).addSeriesOverride(
    {
      alias: '/avg success/',
      color: 'green',
    },
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

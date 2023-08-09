// Divides the Count where inservice instances do not match desired instances by the overall count of samples
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
            (
            sum by(%(selectorLabels)s) (avg_over_time(%(desiredMetric)s{%(selectors)s}[%(evalInterval)s]))
            -
            sum by(%(selectorLabels)s) (avg_over_time(%(inserviceMetric)s{%(selectors)s}[%(evalInterval)s]))
            ) >= 1
            /
            count by(%(selectorLabels)s) (count_over_time(%(desiredMetric)s{%(selectors)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        desiredMetric: targetMetrics.desired,
        inserviceMetric: targetMetrics.inservice,
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
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(inserviceMetric)s{%(selectors)s}[%(evalInterval)s]) >= 0 or vector(0))
      ||| % {
        desiredMetric: targetMetrics.desired,
        inserviceMetric: targetMetrics.inservice,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg inservice instances',
    ),
  ).addTarget(
    prometheus.target(
      |||
        (
        sum(avg_over_time(%(inserviceMetric)s{%(selectors)s}[%(evalInterval)s]) >= 0 or vector(0))
        -
        sum(avg_over_time(%(desiredMetric)s{%(selectors)s}[%(evalInterval)s]) >= 0 or vector(0))
        ) >= 1
        /
        count(count_over_time(%(desiredMetric)s{%(selectors)s}[%(evalInterval)s]) >= 0 or vector(0))
      ||| % {
        desiredMetric: targetMetrics.desired,
        inserviceMetric: targetMetrics.inservice,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg period where inservice instances < desired instances'
    )
  ).addSeriesOverride(
    {
      alias: '/avg period where inservice instances < desired instances/',
      color: 'red',
    },
  ).addSeriesOverride(
    {
      alias: '/avg inservice instances/',
      color: 'green',
    },
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

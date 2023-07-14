// Calculates the maximum value of CloudWatch percentile metric samples

// Target metrics:
// p90 - Metric with p90 CloudWatch percentile suffix
// p95 - Metric with p95 CloudWatch percentile suffix
// p99 - Metric with p99 CloudWatch percentile suffix
// average - Metric with average Cloudwatch percentile suffix

// Additional config:
// latencyPercentile in SLI spec

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

  local cloudwatchPercentile = if sliSpec.latencyPercentile == 0.9 then 'p90'
  else if sliSpec.latencyPercentile == 0.95 then 'p95'
  else if sliSpec.latencyPercentile == 0.99 then 'p99'
  else error 'Invalid latency percentile for Cloudwatch conversion';

  [
    {
      record: 'sli_value',
      expr: |||
        sum without (%(selectorLabels)s) (label_replace(label_replace(
          (
            max by(%(selectorLabels)s) (%(cloudwatchPercentileMetric)s{%(selectors)s})
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        cloudwatchPercentileMetric: targetMetrics[cloudwatchPercentile],
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
    format='s',
    thresholds=[
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
      |||
        avg(%(averageMetric)s{%(selectors)s})
      ||| % {
        averageMetric: targetMetrics.average,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='average latency',
    ),
  ).addTarget(
    prometheus.target(
      |||
        max(%(p90Metric)s{%(selectors)s})
      ||| % {
        p90Metric: targetMetrics.p90,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='max p90 latency',
    ),
  ).addTarget(
    prometheus.target(
      'max(%(p95Metric)s{%(selectors)s})' % {
        p95Metric: targetMetrics.p95,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='max p95 latency',
    ),
  ).addTarget(
    prometheus.target(
      'max(%(p99Metric)s{%(selectors)s})' % {
        p99Metric: targetMetrics.p99,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='max p99 latency',
    ),
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

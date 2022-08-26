// Divides the sum of rate of change of metric samples with bad error selectors by the sum of rate of change
// of metric samples with all error selectors

// Target metrics:
// target - Metric with a selector label that can be used to differentiate between good and bad

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

  [
    {
      record: 'sli_value',
      expr: |||
        sum by (%(selectorLabels)s) (
          rate(%(targetMetric)s{%(selectors)s, %(errorStatusSelector)s}[%(evalInterval)s])
          or
          0 * %(targetMetric)s{%(selectors)s}
        )
        /
        sum by (%(selectorLabels)s) (rate(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        targetMetric: targetMetrics.target,
        errorStatusSelector: sliValueLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
        selectorLabels: std.join(', ', [metricConfig.selectorLabels.environment, metricConfig.selectorLabels.product]),
        selectors: std.join(',', ruleSelectors),
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
    title = '%s' % sliSpec.sliDescription,
    datasource = 'prometheus',
    description = |||
      * Sample interval is %(evalInterval)s
      * Selectors are %(selectors)s
    ||| % {
      selectors: std.strReplace(std.join(', ', sliValueLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
      evalInterval: sliSpec.evalInterval,
    },
  ).addTarget(
    prometheus.target(
      |||
        placeholder
      ||| % {
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = '',
    ),
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

// Divides the sum of rate of change of metric samples with bad error selectors by the sum of rate of change
// of metric samples with all error selectors

// Target metrics:
// target - Metric with a selector label that can be used to differentiate between good and bad

// Additional config:
// errorStatus selector in SLI spec
// errorStatus selector label in metric type config

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
      // 0 * %(targetMetric)s{%(selectors)s} will replace the numerator with a 0 when there is no
      // data for numerator metric with selectors
      expr: |||
        sum without (%(selectorLabels)s) (label_replace(label_replace(
          (
            sum by(%(selectorLabels)s) (
              rate(%(targetMetric)s{%(selectors)s, %(errorStatusSelector)s}[%(evalInterval)s])
              or
              0 * %(targetMetric)s{%(selectors)s}
            )
            /
            sum by(%(selectorLabels)s) (rate(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        targetMetric: targetMetrics.target,
        errorStatusSelector: sliValueLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
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
      * Error selectors are %(errorStatusSelector)s
    ||| % {
      errorStatusSelector: sliValueLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
      selectors: std.strReplace(std.join(', ', sliValueLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
      evalInterval: sliSpec.evalInterval,
    },
    min=0,
    fill=0,
    formatY2='percentunit',
    thresholds=[
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
      |||
        sum(rate(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        targetMetric: targetMetrics.target,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='requests per second',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(rate(%(targetMetric)s{%(selectors)s, %(errorStatusSelector)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        targetMetric: targetMetrics.target,
        errorStatusSelector: sliValueLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='errors per second',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(rate(%(targetMetric)s{%(selectors)s, %(errorStatusSelector)s}[%(evalInterval)s]) or vector(0))
        /
        sum(rate(%(targetMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        targetMetric: targetMetrics.target,
        errorStatusSelector: sliValueLibraryFunctions.getSelector('errorStatus', metricConfig, sliSpec),
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='error rate',
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

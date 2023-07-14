// Divides the sum of rate of change of 4xx and 5xx status code metric samples by the sum of
// rate of change of all status code metric samples

// Target metrics:
// code4xx - Metric representing requests with 4xx status codes
// code5xx - Metric representing requests with 5xx status codes
// codeAll - Metric representing requests with all status codes

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
              sum by(%(selectorLabels)s) (
                rate(%(code4xxMetric)s{%(selectors)s}[%(evalInterval)s])
                or
                0 * %(codeAllMetric)s{%(selectors)s}
              )
              + 
              sum by(%(selectorLabels)s) (
                rate(%(code5xxMetric)s{%(selectors)s}[%(evalInterval)s])
                or
                0 * %(codeAllMetric)s{%(selectors)s}
              )
            )
            /
            sum by(%(selectorLabels)s) (rate(%(codeAllMetric)s{%(selectors)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        code4xxMetric: targetMetrics.code4xx,
        code5xxMetric: targetMetrics.code5xx,
        codeAllMetric: targetMetrics.codeAll,
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
      * Errors are 4xx and 5xx requests
    ||| % {
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
        sum(rate(%(codeAllMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        codeAllMetric: targetMetrics.codeAll,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='requests per second',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(rate(%(code4xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        + 
        sum(rate(%(code5xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        code4xxMetric: targetMetrics.code4xx,
        code5xxMetric: targetMetrics.code5xx,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='errors per second',
    )
  ).addTarget(
    prometheus.target(
      |||
        (
          sum(rate(%(code4xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
          + 
          sum(rate(%(code5xxMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))
        )
        /
        sum(rate(%(codeAllMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        code4xxMetric: targetMetrics.code4xx,
        code5xxMetric: targetMetrics.code5xx,
        codeAllMetric: targetMetrics.codeAll,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='error rate',
    )
  ).addSeriesOverride(
    {
      alias: '/error rate/',
      yaxis: 2,
      color: 'red',
    },
  );

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

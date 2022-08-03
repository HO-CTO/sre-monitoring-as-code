// Library to generate Grafana and Prometheus config for service latency metrics

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;

// Creates Grafana dashboard graph panel for an SLI type
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliMetricLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);

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
      'sum(rate(%(sumMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0)) / 
        sum(rate(%(countMetric)s{%(selectors)s}[%(evalInterval)s]) or vector(0))' % {
          sumMetric: metricConfig.metrics.sum,
          countMetric: metricConfig.metrics.count,
          selectors: std.join(',', dashboardSelectors),
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'Average Latency',
    )
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);

  [
    {
      record: 'sli_value',
      expr: |||
        histogram_quantile(%(latencyPercentile)0.2f, (sum by (le) (rate(%(bucketMetric)s{%(selectors)s}[%(evalInterval)s]))))
      ||| % {
        bucketMetric: metricConfig.metrics.bucket,
        latencyPercentile: sliSpec.latencyPercentile,
        selectors: std.join(',', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// File exports
{
  description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
  category: 'Latency',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
}

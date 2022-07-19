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

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(direction) =
  [
    template.custom(
      name = '%s_latency_percentile' % direction,
      query = '50,80,90,95,99',
      current = '95',
      label = stringFormattingFunctions.capitaliseFirstLetters('%s Latency Percentile' % direction),
    ),
  ];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction) =
  std.flattenArrays([
    [row.new(
      title = stringFormattingFunctions.capitaliseFirstLetters('%s HTTP Requests Latency' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [grafana.heatmapPanel.new(
      title = 'Latency - heatmap for request latency',
      datasource = 'prometheus',
      color_colorScheme = 'interpolatePlasma',
      dataFormat = 'tsbuckets',
      hideZeroBuckets = true,
      yAxis_format = 's',
      legend_show = true,
    ).addTarget(
      prometheus.target(|||
          sum by (le) (increase({__name__=~"%(bucketMetrics)s", %(selectors)s}[$__rate_interval]))
        ||| % {
          bucketMetrics: std.join('|', metrics[direction][sliType].bucket),
          selectors: std.join(', ', std.objectValues(selectors[direction])),
        },
        legendFormat = '{{le}}', format = 'heatmap')
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      title = 'Latency - requests per selected latency percentile',
      datasource = 'prometheus',
      min = 0,
      format = 's',
    ).addTarget(
      prometheus.target(|||
          histogram_quantile($%(direction)s_latency_percentile/100, (sum by (le) (rate({__name__=~"%(bucketMetrics)s",
          %(selectors)s}[$__rate_interval]))))
        ||| % {
          direction: direction,
          bucketMetrics: std.join('|', metrics[direction][sliType].bucket),
          selectors: std.join(', ', std.objectValues(selectors[direction])),
        },
        legendFormat = 'Selected Percentile Latency')
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

// File exports
{
  description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
  category: 'Latency',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

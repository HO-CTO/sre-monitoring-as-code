// Target metrics:
// requestBucket - Metric representing the buckets histogram request latency values fall into

// MaC imports
local stringFormattingFunctions = import '../../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;

// Creates custom templates
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @returns List of custom templates
local createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors) =
  [
    template.custom(
      name='%s_latency_percentile' % direction,
      query='50,80,90,95,99',
      current='95',
      label=stringFormattingFunctions.capitaliseFirstLetters('%s Latency Percentile' % direction),
    ),
  ];

// Creates custom selectors
// @param direction The type of dashboard elements being created, inbound or outbound
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @returns List of custom selectors
local createCustomSelectors(direction, customSelectorLabels, customSelectorValues) =
  {};

// Creates panels
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @returns List of panels
local createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors) =
  std.flattenArrays([
    [row.new(
      title=stringFormattingFunctions.capitaliseFirstLetters('%s HTTP Requests Latency' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [grafana.heatmapPanel.new(
      title='Latency - heatmap for request latency',
      datasource='prometheus',
      color_colorScheme='interpolatePlasma',
      dataFormat='tsbuckets',
      hideZeroBuckets=true,
      yAxis_format='s',
      legend_show=true,
    ).addTarget(
      prometheus.target(|||
                          sum by (le) (increase({__name__=~"%(requestBucketMetrics)s", %(selectors)s}[$__rate_interval]))
                        ||| % {
                          requestBucketMetrics: std.join('|', metrics.requestBucket),
                          selectors: std.join(', ', std.objectValues(selectors)),
                        },
                        legendFormat='{{le}}',
                        format='heatmap')
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      title='Latency - requests per selected latency percentile',
      datasource='prometheus',
      min=0,
      format='s',
    ).addTarget(
      prometheus.target(|||
                          histogram_quantile($%(direction)s_latency_percentile/100, (sum by (le) (rate({__name__=~"%(requestBucketMetrics)s",
                          %(selectors)s}[$__rate_interval]))))
                        ||| % {
                          direction: direction,
                          requestBucketMetrics: std.join('|', metrics.requestBucket),
                          selectors: std.join(', ', std.objectValues(selectors)),
                        },
                        legendFormat='Selected Percentile Latency')
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

// File exports
{
  createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors):
    createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors),
  createCustomSelectors(direction, customSelectorLabels, customSelectorValues):
    createCustomSelectors(direction, customSelectorLabels, customSelectorValues),
  createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors):
    createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors),
}

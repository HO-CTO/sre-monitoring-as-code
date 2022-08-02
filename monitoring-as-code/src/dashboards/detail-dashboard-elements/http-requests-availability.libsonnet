//

// MaC imports
local stringFormattingFunctions = import '../../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;

local createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors) =
  [];

local createCustomSelectors(direction, customSelectorLabels, customSelectorValues) =
  {};

local createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors) =
  std.flattenArrays([
    [row.new(
      title = stringFormattingFunctions.capitaliseFirstLetters('%s HTTP Requests Availability' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [graphPanel.new(
      title = 'Availability - requests per second by response code',
      datasource = 'prometheus',
      min = 0,
      fill = 10,
      stack = true,
      lines = false,
      bars = true,
      legend_hideZero = true,
    ).addTarget(
      prometheus.target(|||
          sum by (%(errorSelectorLabels)s) (rate({__name__=~"%(countMetrics)s", %(selectors)s}[$__rate_interval]))
        ||| % {
          errorSelectorLabels: std.join(', ', selectorLabels['errorStatus']),
          countMetrics: std.join('|', metrics.count),
          selectors: std.join(', ', std.objectValues(selectors)),
        },
        legendFormat = '{{%s}}' % std.join(', ', selectorLabels['errorStatus']))
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      title = 'Availability - requests per second by path',
      datasource = 'prometheus',
      min = 0,
      fill = 10,
      stack = true,
      lines = false,
      bars = true,
      legend_hideZero = true,
    ).addTarget(
      prometheus.target(|||
          sum by (%(resourceSelectorLabels)s) (rate({__name__=~"%(countMetrics)s", %(selectors)s}[$__rate_interval]))
        ||| % {
          resourceSelectorLabels: std.join(', ', selectorLabels.resource),
          countMetrics: std.join('|', metrics.count),
          selectors: std.join(', ', std.objectValues(selectors)),
        },
        legendFormat = '{{%s}}' % std.join(', ', selectorLabels.resource))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

{
  createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors):
    createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors),
  createCustomSelectors(direction, customSelectorLabels, customSelectorValues):
    createCustomSelectors(direction, customSelectorLabels, customSelectorValues),
  createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors):
    createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors),
}

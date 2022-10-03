// Target metrics:
// requestCount - Metric representing the count of requests

// MaC imports
local stringFormattingFunctions = import '../../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;

// Creates custom templates
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @returns List of custom templates
local createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors) =
  [];

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
      title=stringFormattingFunctions.capitaliseFirstLetters('%s Custom Metric' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [
      graphPanel.new(
        title='Custom Metric',
        datasource='prometheus',
        min=0,
        fill=10,
        stack=true,
        lines=false,
        bars=true,
        legend_hideZero=true,
      ).addTarget(
        prometheus.target(|||
                            rate({__name__=~"%(requestCountMetrics)s", %(selectors)s}[$__rate_interval])
                          ||| % {
                            requestCountMetrics: std.join('|', metrics.target),
                            selectors: std.join(', ', std.objectValues(selectors)),
                          },
                          legendFormat='{{%s}}' % std.join(', ', []))
      ) + { gridPos: { w: if std.objectHas(selectorLabels, 'resource') then 12 else 24, h: 10 } },
    ],
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

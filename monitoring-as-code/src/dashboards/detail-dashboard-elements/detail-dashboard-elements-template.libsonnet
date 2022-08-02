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
  [
    
  ];

local createCustomSelectors(direction, customSelectorLabels, customSelectorValues) =
  {

  };

local createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors) =
  std.flattenArrays([

  ]);

{
  createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors):
    createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors),
  createCustomSelectors(direction, customSelectorLabels, customSelectorValues):
    createCustomSelectors(direction, customSelectorLabels, customSelectorValues),
  createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors):
    createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors),
}

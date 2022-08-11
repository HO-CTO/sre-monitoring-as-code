// This file is for generating the detail dashboards which show more in depth information about
// what the service is doing

// MaC imports
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';
local macConfig = import '../mac-config.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;

// Gets the unique list of SLI types used in the journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns List of SLI types used in the journey
local getSliTypes(journeyKey, sliSpecList) =
  std.set([
    sliSpec.sliType
    for sliSpec in std.objectValues(sliSpecList[journeyKey])
  ]);

// Gets the list of metric types used for each SLI type in the journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing metric types for each SLI type
local getSliMetricTypes(journeyKey, sliSpecList) =
  {
    [sliType]: std.set(std.filterMap(
      function(sliSpec) sliSpec.sliType == sliType,
      function(sliSpec) sliSpec.metricType,
      std.objectValues(sliSpecList[journeyKey])
    ))
    for sliType in getSliTypes(journeyKey, sliSpecList)
  };

// Gets the unique list of items for config field in all SLI types detail dashboard config
// @param configField The field in the detail dashboard config
// @param sliMetricTypes The object containing metric types for each SLI type
// @returns List of config items
local getConfigItems(configField, sliMetricTypes) =
  std.set([
    configItem
    for sliType in std.objectFields(sliMetricTypes)
    for metricType in sliMetricTypes[sliType]
    for configItem in macConfig.sliTypesConfig[sliType].metricTypes[metricType].detailDashboardConfig[configField]
  ]);

// Gets the combined detail dashboard config for all metric types in journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing the combined detail dashboard config
local getDetailDashboardConfig(journeyKey, sliSpecList) =
  local sliMetricTypes = getSliMetricTypes(journeyKey, sliSpecList);

  {
    [configField]: {
      [configItem]: std.set([
        macConfig.sliTypesConfig[sliType].metricTypes[metricType]
        for sliType in std.objectFields(sliMetricTypes)
        for metricType in sliMetricTypes[sliType]
        if 0 < std.length(std.find(
          configItem, macConfig.sliTypesConfig[sliType].metricTypes[metricType].detailDashboardConfig[configField]))
      ], function(metricTypeConfig) std.toString(metricTypeConfig))
      for configItem in getConfigItems(configField, sliMetricTypes)
    },
    for configField in ['standardTemplates', 'elements']
  };

// Gets the unique list of field names inside target attribute for list of SLI types
// @param target The name of the target attribute
// @param metricTypeConfigList The list of configs for the metric types
// @returns List of fields inside target attribute
local getTargetFields(target, metricTypeConfigList) =
  std.set([
    targetField
    for metricTypeConfig in metricTypeConfigList
    if std.objectHas(metricTypeConfig, target)
    for targetField in std.objectFields(metricTypeConfig[target])
  ]);

// Gets the unique list of all values of target attribute for each detail dashboard config item
// @param target The name of the target attribute
// @param direction The type of dashboard elements being created, inbound or outbound
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns Object containing list of values in target attribute for each config item
local getTargets(target, direction, detailDashboardConfig) =
  {
    [direction]: {
      [configField]: {
        [configItem]: {
          [targetField]: std.set([
            metricTypeConfig[target][targetField]
            for metricTypeConfig in detailDashboardConfig[configField][configItem]
            if std.objectHas(metricTypeConfig, target) &&
              std.objectHas(metricTypeConfig[target], targetField)
          ])
          for targetField in getTargetFields(target, detailDashboardConfig[configField][configItem])
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
      }
      for configField in std.objectFields(detailDashboardConfig)
    },
  };

// Checks if the direction for item being processed has config
// @param direction The type of dashboard elements being created, inbound or outbound
// @param configField The field in the detail dashboard config
// @param configItem The name of the item in the config field
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @returns True if config exists for both metrics and selector labels, false otherwise
local checkDirectionValid(direction, configField, configItem, metrics, selectorLabels) =
  0 < std.length(std.objectValues(metrics[direction][configField][configItem])) &&
  0 < std.length(std.objectValues(selectorLabels[direction][configField][configItem]));

// Gets the unique list of products being used by SLIs
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns List of products used by SLIs
local getProductList(journeyKey, sliSpecList) =
  std.join('|', std.set(std.filterMap(
    function(sliSpec) std.objectHas(sliSpec.selectors, 'product'),
    function(sliSpec) sliSpec.selectors.product,
    std.objectValues(sliSpecList[journeyKey])
  )));

// Creates Grafana selectors for templates and dashboards
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param detailDashboardConfig Object containing the config for detail dashboard
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing Grafana selectors
local createSelectors(metrics, selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, sliSpecList) =
  local productList = getProductList(journeyKey, sliSpecList);
  
  {
    [direction]: {
      [configField]: {
        [configItem]: {
          environment: std.join(', ', std.map( 
            function(selectorLabel) '%s=~"$environment|"' % selectorLabel,
            selectorLabels[direction][configField][configItem]['environment']
          )),
          product: std.join(', ', std.map( 
            function(selectorLabel) '%s=~"%s|"' % [selectorLabel, 
              productList],
            selectorLabels[direction][configField][configItem]['product']
          )),
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
        if checkDirectionValid(direction, configField, configItem, metrics, selectorLabels)
      }
      for configField in std.objectFields(detailDashboardConfig)
    } + {
      elements+: {
        [element]+: {
          [selectorLabelField]: std.join(', ', std.map(
            function(selectorLabel) '%s=~"$%s|"' % [selectorLabel, '%s_%s' % [direction, selectorLabel]],
            selectorLabels[direction].standardTemplates[selectorLabelField][selectorLabelField]
          ))
          for selectorLabelField in std.objectFields(detailDashboardConfig.standardTemplates)
        } + macConfig.detailDashboardElements[element].createCustomSelectors(
          direction, customSelectorLabels[direction].elements[element], customSelectorValues[direction].elements[element])
        for element in std.objectFields(detailDashboardConfig.elements)
        if checkDirectionValid(direction, 'elements', element, metrics, selectorLabels)
      },
    }
    for direction in ['inbound', 'outbound']
  };

// Creates the Grafana templates for the detail dashboard
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns List of Grafana template objects for detail dashboard
local createTemplates(metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig) =
  std.set(std.flattenArrays([
    [
      template.new(
        name = '%s_%s' % [direction, selectorLabel],
        datasource = 'prometheus',
        query = 'label_values({__name__=~"%(metrics)s", %(environmentSelectors)s, %(productSelectors)s}, %(selectorLabel)s)' % {
          metrics: std.join('|', std.set(std.flattenArrays(std.map(
            function(metricField) metrics[direction].standardTemplates[selectorLabelField][metricField],
            std.objectFields(metrics[direction].standardTemplates[selectorLabelField])
          )))),
          environmentSelectors: selectors[direction].standardTemplates[selectorLabelField].environment,
          productSelectors: selectors[direction].standardTemplates[selectorLabelField].product,
          selectorLabel: selectorLabel,
        },
        includeAll = true,
        multi = true,
        refresh = 'time',
        label = stringFormattingFunctions.capitaliseFirstLetters('%s %s' % [direction, std.strReplace(selectorLabel, '_', ' ')]),
      )
      for selectorLabelField in std.objectFields(detailDashboardConfig.standardTemplates)
      if checkDirectionValid(direction, 'standardTemplates', selectorLabelField, metrics, selectorLabels)
      for selectorLabel in selectorLabels[direction].standardTemplates[selectorLabelField][selectorLabelField]
    ] + std.flattenArrays([
      macConfig.detailDashboardElements[element].createCustomTemplates(
        direction, metrics[direction].elements[element], customSelectorLabels[direction].elements[element],
        customSelectorValues[direction].elements[element], selectors[direction].elements[element])
      for element in std.objectFields(detailDashboardConfig.elements)
      if checkDirectionValid(direction, 'elements', element, metrics, selectorLabels)
    ])
    for direction in ['inbound', 'outbound']
  ]), function(template) template.name);

// Creates the Grafana panels for the detail dashboard
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns List of Grafana panel objects for detail dashboard
local createPanels(metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig) =
  std.flattenArrays([
    macConfig.detailDashboardElements[element].createPanels(
      direction, metrics[direction].elements[element], selectorLabels[direction].elements[element],
      customSelectorLabels[direction].elements[element], customSelectorValues[direction].elements[element], selectors[direction].elements[element])
    for direction in ['inbound', 'outbound']
    for element in std.objectFields(detailDashboardConfig.elements)
    if checkDirectionValid(direction, 'elements', element, metrics, selectorLabels)
  ]);

// Creates a single detail dashboard for a journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param config The config for the service defined in the mixin file
// @param links The links to other dashboards
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns JSON for a detail dashboard
local createDetailDashboard(journeyKey, config, links, sliSpecList) =
  local detailDashboardConfig = getDetailDashboardConfig(journeyKey, sliSpecList);

  local metrics = getTargets('metrics', 'inbound', detailDashboardConfig) +
    getTargets('outboundMetrics', 'outbound', detailDashboardConfig);

  local selectorLabels = getTargets('selectorLabels', 'inbound', detailDashboardConfig) +
    getTargets('outboundSelectorLabels', 'outbound', detailDashboardConfig);

  local customSelectorLabels = getTargets('customSelectorLabels', 'inbound', detailDashboardConfig) +
    getTargets('customSelectorLabels', 'outbound', detailDashboardConfig);

  local customSelectorValues = getTargets('customSelectors', 'inbound', detailDashboardConfig) +
    getTargets('customSelectors', 'outbound', detailDashboardConfig);

  local selectors = createSelectors(
    metrics, selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, sliSpecList);

  dashboard.new(
    title = '%(product)s-%(journey)s-detail-view' % { 
      product: config.product,
      journey: journeyKey,
    },
    uid = std.join('-', [config.product, journeyKey, 'detail-view']),
    tags = [config.product, 'mac-version: %s' % config.macVersion, journeyKey, 'detail-view'],
    schemaVersion = 18,
    editable = true,
    time_from = 'now-3h',
    refresh = '5m',
  ).addLinks(
    dashboardLinks = links
  ).addTemplate(
    template.new(
      name = 'environment',
      datasource = 'prometheus',
      query = 'label_values({__name__=~"sli_value"}, environment)',
      refresh = 'time',
      label = 'Environment',
    )
  ).addTemplates(
    std.prune(createTemplates(
      metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig))
  ).addPanels(
    std.prune(createPanels(
      metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig))
  );

// Creates the list of detail dashboards for a mixin file
// @param config The config for the service defined in the mixin file
// @param links The links to other dashboards
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns JSON for the detail dashboards
local createDetailDashboards(config, links, sliSpecList) =
  {
    [std.join('-', [config.product, journeyKey, 'detail-view.json'])]:
      createDetailDashboard(journeyKey, config, links, sliSpecList)
    for journeyKey in std.objectFields(sliSpecList)
  };

// File exports
{
  createDetailDashboards(config, links, sliSpecList):
    createDetailDashboards(config, links, sliSpecList),
}

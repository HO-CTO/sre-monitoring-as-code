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
    for configItem in macConfig.sliMetricLibs[sliType].detailDashboardConfig[configField]
  ]);

// Gets the combined detail dashboard config for all SLI types in journey
// @param sliMetricTypes The object containing metric types for each SLI type
// @returns Object containing the combined detail dashboard config
local getDetailDashboardConfig(sliMetricTypes) =
  {
    [configField]: {
      [configItem]: std.set(std.filterMap(
        function(sliType) 0 < std.length(std.find(
          configItem, macConfig.sliMetricLibs[sliType].detailDashboardConfig[configField])),
        function(sliType) sliType,
        std.objectFields(sliMetricTypes)
      ))
      for configItem in getConfigItems(configField, sliMetricTypes)
    },
    for configField in ['standardTemplates', 'elements']
  };

// Gets the unique list of field names inside target attribute for list of SLI types
// @param target The name of the target attribute
// @param sliTypes The list of SLI types
// @param sliMetricTypes The object containing metric types for each SLI type
// @returns List of fields inside target attribute
local getTargetFields(target, sliTypes, sliMetricTypes) =
  std.set([
    targetField
    for sliType in sliTypes
    for metricType in sliMetricTypes[sliType]
    if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target)
    for targetField in std.objectFields(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target])
  ]);

// Gets the unique list of all values of target attribute for each detail dashboard config item
// @param target The name of the target attribute
// @param direction The type of dashboard elements being created, inbound or outbound
// @param detailDashboardConfig Object containing the config for detail dashboard
// @param sliMetricTypes The object containing metric types for each SLI type
// @returns Object containing list of values in target attribute for each config item
local getTargets(target, direction, detailDashboardConfig, sliMetricTypes) =
  {
    [direction]: {
      [configField]: {
        [configItem]: {
          [targetField]: std.set([
            macConfig.sliMetricLibs[sliType].metricTypes[metricType][target][targetField]
            for sliType in detailDashboardConfig[configField][configItem]
            for metricType in sliMetricTypes[sliType]
            if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target) &&
              std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target], targetField)
          ])
          for targetField in getTargetFields(target, detailDashboardConfig[configField][configItem], sliMetricTypes)
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
      }
      for configField in std.objectFields(detailDashboardConfig)
    },
  };

// Gets the unique list of products being used by SLIs of certain SLI types
// @param sliTypes The list of SLI types
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns List of products used by SLIs
local getProductList(sliTypes, journeyKey, sliSpecList) =
  std.join('|', std.set(std.filterMap(
    function(sliSpec) std.objectHas(sliSpec.selectors, 'product') &&
      0 < std.length(std.find(sliSpec.sliType, sliTypes)),
    function(sliSpec) sliSpec.selectors.product,
    std.objectValues(sliSpecList[journeyKey])
  )));

// Creates Grafana selectors for templates and dashboards
// @param direction The type of dashboard elements being created, inbound or outbound
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param detailDashboardConfig Object containing the config for detail dashboard
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing Grafana selectors
local createSelectors(direction, selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, sliSpecList) =
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
              getProductList(detailDashboardConfig[configField][configItem], journeyKey, sliSpecList)],
            selectorLabels[direction][configField][configItem]['product']
          )),
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
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
      },
    },
  };

// Creates the Grafana templates for the detail dashboard
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns List of Grafana template objects for detail dashboard
local createTemplates(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig) =
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
      for selectorLabel in selectorLabels[direction].standardTemplates[selectorLabelField][selectorLabelField]
    ],
    std.flattenArrays([
      macConfig.detailDashboardElements[element].createCustomTemplates(
        direction, metrics[direction].elements[element], customSelectorLabels[direction].elements[element],
        customSelectorValues[direction].elements[element], selectors[direction].elements[element])
      for element in std.objectFields(detailDashboardConfig.elements)
    ]),
  ]), function(template) template.name);

// Creates the Grafana panels for the detail dashboard
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns List of Grafana panel objects for detail dashboard
local createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig) =
  std.flattenArrays([
    macConfig.detailDashboardElements[element].createPanels(
      direction, metrics[direction].elements[element], selectorLabels[direction].elements[element],
      customSelectorLabels[direction].elements[element], customSelectorValues[direction].elements[element], selectors[direction].elements[element])
    for element in std.objectFields(detailDashboardConfig.elements)
  ]);

// Creates a single detail dashboard for a journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param config The config for the service defined in the mixin file
// @param links The links to other dashboards
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns JSON for a detail dashboard
local createDetailDashboard(journeyKey, config, links, sliSpecList) =
  local sliMetricTypes = getSliMetricTypes(journeyKey, sliSpecList);

  local detailDashboardConfig = getDetailDashboardConfig(sliMetricTypes);

  local metrics = getTargets('metrics', 'inbound', detailDashboardConfig, sliMetricTypes);

  local selectorLabels = getTargets('selectorLabels', 'inbound', detailDashboardConfig, sliMetricTypes);

  local customSelectorLabels = getTargets('customSelectorLabels', 'inbound', detailDashboardConfig, sliMetricTypes);

  local customSelectorValues = getTargets('customSelectors', 'inbound', detailDashboardConfig, sliMetricTypes);

  local selectors = createSelectors(
    'inbound', selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, sliSpecList);

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
      'inbound', metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig))
  ).addPanels(
    std.prune(createPanels(
      'inbound', metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig))
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

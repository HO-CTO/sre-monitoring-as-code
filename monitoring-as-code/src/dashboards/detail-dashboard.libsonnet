// This file is for generating the detail dashboards which show more in depth information about
// what the service is doing

// MaC imports
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';
local macConfig = import '../mac-config.libsonnet';
local dashboardFunctions = import './dashboard-standard-elements.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;

// Gets the unique list of metric types used by the SLI specs
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns The list of metric types
local getSliSpecMetricTypes(journeyKey, sliSpecList) =
  std.set(std.map(
    function(sliSpec) sliSpec.metricType,
    std.objectValues(sliSpecList[journeyKey])
  ));

// Gets the unique list of items for config field in all SLI types detail dashboard config
// @param configField The field in the detail dashboard config
// @param sliSpecMetricTypes The object containing metric types for each SLI spec
// @returns List of config items
local getConfigItems(configField, sliSpecMetricTypes) =
  std.set([
    configItem
    for metricType in sliSpecMetricTypes
    for configItem in macConfig.metricTypes[metricType].detailDashboardConfig[configField]
  ]);

// Gets the combined detail dashboard config for all metric types in journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing the combined detail dashboard config
local getDetailDashboardConfig(journeyKey, sliSpecList) =
  local sliSpecMetricTypes = getSliSpecMetricTypes(journeyKey, sliSpecList);

  {
    [configField]: {
      [configItem]: std.set([
        metricType
        for metricType in sliSpecMetricTypes
        if 0 < std.length(std.find(
          configItem, macConfig.metricTypes[metricType].detailDashboardConfig[configField]
        ))
      ], function(metricTypeConfig) std.toString(metricTypeConfig))
      for configItem in getConfigItems(configField, sliSpecMetricTypes)
    }
    for configField in ['standardTemplates', 'elements']
  };

// Gets the unique list of metric field names for list of metric types
// @param configItemMetricTypes The list of metric types for the config item
// @returns List of metric fields
local getTargetMetricFields(configItemMetricTypes) =
  std.set([
    metricField
    for metricType in configItemMetricTypes
    for metricField in std.objectFields(macConfig.metricTypes[metricType].detailDashboardConfig.targetMetrics)
  ]);

// Gets the unique list of all metrics for each detail dashboard config item
// @param detailDashboardConfig Object containing the config for detail dashboard
// @returns Object containing list of metrics for each config item
local getMetrics(detailDashboardConfig) =
  local metricAttributes = {
    inbound: 'metrics',
    outbound: 'outboundMetrics',
  };

  {
    [direction]: {
      [configField]: {
        [configItem]: {
          [targetMetricField]: std.set([
            macConfig.metricTypes[metricType].metricTypeConfig[metricAttributes[direction]][
              macConfig.metricTypes[metricType].detailDashboardConfig.targetMetrics[targetMetricField]]
            for metricType in detailDashboardConfig[configField][configItem]
            if std.objectHas(macConfig.metricTypes[metricType].metricTypeConfig, metricAttributes[direction]) &&
               std.objectHas(macConfig.metricTypes[metricType].detailDashboardConfig.targetMetrics, targetMetricField) &&
               std.objectHas(macConfig.metricTypes[metricType].metricTypeConfig[metricAttributes[direction]],
                             macConfig.metricTypes[metricType].detailDashboardConfig.targetMetrics[targetMetricField])
          ])
          for targetMetricField in getTargetMetricFields(detailDashboardConfig[configField][configItem])
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
      }
      for configField in ['standardTemplates', 'elements']
    }
    for direction in std.objectFields(metricAttributes)
  };

// Gets the unique list of field names inside target attribute for list of metric types
// @param target The name of the target attribute
// @param configItemMetricTypes The list of metric types for the config item
// @returns List of fields inside target attribute
local getTargetFields(target, configItemMetricTypes) =
  std.set([
    targetField
    for metricType in configItemMetricTypes
    if std.objectHas(macConfig.metricTypes[metricType].metricTypeConfig, target)
    for targetField in std.objectFields(macConfig.metricTypes[metricType].metricTypeConfig[target])
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
            macConfig.metricTypes[metricType].metricTypeConfig[target][targetField]
            for metricType in detailDashboardConfig[configField][configItem]
            if std.objectHas(macConfig.metricTypes[metricType].metricTypeConfig, target) &&
               std.objectHas(macConfig.metricTypes[metricType].metricTypeConfig[target], targetField)
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
// @param configItemMetricTypes The list of metric types for the config item
// @param journeyKey The key of the journey having its detail dashboard generated
// @param config The config for the service defined in the mixin file
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns List of products used by SLIs
local getProductList(configItemMetricTypes, journeyKey, config, sliSpecList) =
  if std.objectHas(config, 'generic') && config.generic then '$product' else
    std.join('|', std.set([
      sliSpec.selectors.product
      for sliSpec in std.objectValues(sliSpecList[journeyKey])
      if std.objectHas(sliSpec.selectors, 'product')
      for metricType in configItemMetricTypes
      if metricType == sliSpec.metricType
    ]));

// Creates Grafana selectors for templates and dashboards
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param detailDashboardConfig Object containing the config for detail dashboard
// @param journeyKey The key of the journey having its detail dashboard generated
// @param config The config for the service defined in the mixin file
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing Grafana selectors
local createSelectors(metrics, selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, config, sliSpecList) =
  {
    [direction]: {
      [configField]: {
        [configItem]: {
          environment: std.join(', ', std.map(
            function(selectorLabel) '%s=~"$environment|"' % selectorLabel,
            selectorLabels[direction][configField][configItem].environment
          )),
          product: std.join(', ', std.map(
            function(selectorLabel) '%s=~"%s|"' % [
              selectorLabel,
              getProductList(detailDashboardConfig[configField][configItem], journeyKey, config, sliSpecList),
            ],
            selectorLabels[direction][configField][configItem].product
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
          direction, customSelectorLabels[direction].elements[element], customSelectorValues[direction].elements[element]
        )
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
        name='%s_%s' % [direction, selectorLabel],
        datasource='prometheus',
        query='label_values({__name__=~"%(metrics)s", %(environmentSelectors)s, %(productSelectors)s}, %(selectorLabel)s)' % {
          metrics: std.join('|', std.set(std.flattenArrays(std.map(
            function(metricField) metrics[direction].standardTemplates[selectorLabelField][metricField],
            std.objectFields(metrics[direction].standardTemplates[selectorLabelField])
          )))),
          environmentSelectors: selectors[direction].standardTemplates[selectorLabelField].environment,
          productSelectors: selectors[direction].standardTemplates[selectorLabelField].product,
          selectorLabel: selectorLabel,
        },
        includeAll=true,
        multi=true,
        refresh='time',
        label=stringFormattingFunctions.capitaliseFirstLetters('%s %s' % [direction, std.strReplace(selectorLabel, '_', ' ')]),
      )
      for selectorLabelField in std.objectFields(detailDashboardConfig.standardTemplates)
      if checkDirectionValid(direction, 'standardTemplates', selectorLabelField, metrics, selectorLabels)
      for selectorLabel in selectorLabels[direction].standardTemplates[selectorLabelField][selectorLabelField]
    ] + std.flattenArrays([
      macConfig.detailDashboardElements[element].createCustomTemplates(
        direction,
        metrics[direction].elements[element],
        customSelectorLabels[direction].elements[element],
        customSelectorValues[direction].elements[element],
        selectors[direction].elements[element]
      )
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
      direction,
      metrics[direction].elements[element],
      selectorLabels[direction].elements[element],
      customSelectorLabels[direction].elements[element],
      customSelectorValues[direction].elements[element],
      selectors[direction].elements[element]
    )
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

  local metrics = getMetrics(detailDashboardConfig);

  local selectorLabels = getTargets('selectorLabels', 'inbound', detailDashboardConfig) +
                         getTargets('outboundSelectorLabels', 'outbound', detailDashboardConfig);

  local customSelectorLabels = getTargets('customSelectorLabels', 'inbound', detailDashboardConfig) +
                               getTargets('customSelectorLabels', 'outbound', detailDashboardConfig);

  local customSelectorValues = getTargets('customSelectors', 'inbound', detailDashboardConfig) +
                               getTargets('customSelectors', 'outbound', detailDashboardConfig);

  local selectors = createSelectors(
    metrics, selectorLabels, customSelectorLabels, customSelectorValues, detailDashboardConfig, journeyKey, config, sliSpecList
  );

  dashboard.new(
    title=stringFormattingFunctions.capitaliseFirstLetters(std.join(' / ', [macConfig.macDashboardPrefix.title, config.product, journeyKey, 'detail'])),
    uid=std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey, 'detail']),
    tags=[config.product, 'mac-version: %s' % config.macVersion, journeyKey, 'detail-view'],
    schemaVersion=18,
    editable=true,
    time_from='now-3h',
    refresh='5m',
  ).addLinks(
    dashboardLinks=links
  ).addTemplates(
    config.templates
  ).addTemplates(
    std.prune(createTemplates(
      metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig
    ))
  ).addPanel(
    dashboardFunctions.createDocsTextPanel(macConfig.dashboardDocs.detailView), gridPos={ h: 3, w: 24, x: 0, y: 0 }
  ).addPanels(
    std.prune(createPanels(
      metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors, detailDashboardConfig
    ))
  );

// Creates the list of detail dashboards for a mixin file
// @param config The config for the service defined in the mixin file
// @param links The links to other dashboards
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns JSON for the detail dashboards
local createDetailDashboards(config, links, sliSpecList) =
  {
    [std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey, 'detail']) + '.json']:
      createDetailDashboard(journeyKey, config, links, sliSpecList)
    for journeyKey in std.objectFields(sliSpecList)
  };

// File exports
{
  createDetailDashboards(config, links, sliSpecList):
    createDetailDashboards(config, links, sliSpecList),
}

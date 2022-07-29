// This file is for generating the detail dashboards which show more in depth information about
// what the service is doing

// MaC imports
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';
local macConfig = import '../mac-config.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;

// Gets the list of SLI types used in this journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns List of SLI types used in this journey
local getSliTypesList(journeyKey, sliSpecList) =
  std.set([
    sliSpec.sliType
    for sliSpec in std.objectValues(sliSpecList[journeyKey])
  ]);

// Gets the list of metric types used for each SLI type in the journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing metric types for each SLI type
local getMetricTypesList(journeyKey, sliSpecList) =
  {
    [sliType]: std.set(std.filterMap(
      function(sliSpec) sliSpec.sliType == sliType,
      function(sliSpec) sliSpec.metricType,
      std.objectValues(sliSpecList[journeyKey])
    ))
    for sliType in getSliTypesList(journeyKey, sliSpecList)
  };

local getConfigItems(configField, metricTypesList) =
  std.set([
    configItem
    for sliType in std.objectFields(metricTypesList)
    for configItem in macConfig.sliMetricLibs[sliType].detailDashboardConfig[configField]
  ]);

local getDetailDashboardConfig(metricTypesList) =
  {
    [configField]: {
      [configItem]: std.set(std.filterMap(
        function(sliType) 0 < std.length(std.find(
          configItem, macConfig.sliMetricLibs[sliType].detailDashboardConfig[configField])),
        function(sliType) sliType,
        std.objectFields(metricTypesList)
      ))
      for configItem in getConfigItems(configField, metricTypesList)
    },
    for configField in ['standardTemplates', 'elements']
  };

// Gets the list of fields used for metrics by an SLI type
// @param target The name of the field in the MaC config containing metrics (inbound or outbound)
// @param sliType The type of SLI currently being processed
// @param metricTypesList The object containing metric types for each SLI type
// @returns List of metric fields used by an SLI type
local getTargetFields(target, sliTypes, metricTypesList) =
  std.set([
    targetField
    for sliType in sliTypes
    for metricType in metricTypesList[sliType]
    if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target)
    for targetField in std.objectFields(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target])
  ]);

// Gets the collection of metrics used by each SLI type
// @param metricTypesList The object containing metric types for each SLI type
// @returns Object containing metrics for each SLI type
local getTargets(target, direction, detailDashboardConfig, metricTypesList) =
  {
    [direction]: {
      [configField]: {
        [configItem]: {
          [targetField]: std.set([
            macConfig.sliMetricLibs[sliType].metricTypes[metricType][target][targetField]
            for sliType in detailDashboardConfig[configField][configItem]
            for metricType in metricTypesList[sliType]
            if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target) &&
              std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target], targetField)
          ])
          for targetField in getTargetFields(target, detailDashboardConfig[configField][configItem], metricTypesList)
        }
        for configItem in std.objectFields(detailDashboardConfig[configField])
      }
      for configField in std.objectFields(detailDashboardConfig)
    },
  };

// Gets the list of products being used by SLIs in journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns The list of products used by SLIs
local getProductList(sliTypes, journeyKey, sliSpecList) =
  std.join('|', std.set(std.filterMap(
    function(sliSpec) std.objectHas(sliSpec.selectors, 'product') &&
      0 < std.length(std.find(sliSpec.sliType, sliTypes)),
    function(sliSpec) sliSpec.selectors.product,
    std.objectValues(sliSpecList[journeyKey])
  )));

// Creates Grafana selectors using templates for each selector label
// @param selectorLabels Object containing selector labels
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing Grafana selectors
local createSelectors(direction, selectorLabels, detailDashboardConfig, journeyKey, sliSpecList) =
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
        [configItem]+: {
          [selectorLabelField]: std.join(', ', std.map(
            function(selectorLabel) '%s=~"$%s|"' % [selectorLabel, '%s_%s' % [direction, selectorLabel]],
            selectorLabels[direction].elements[configItem][selectorLabelField]
          ))
          for selectorLabelField in std.objectFields(selectorLabels[direction].elements[configItem])
          if 0 < std.length(std.find(selectorLabelField, std.objectFields(detailDashboardConfig.standardTemplates)))
        } // + custom selectors
        for configItem in std.objectFields(detailDashboardConfig.elements)
      },
    },
  };

// Checks if any metrics were found for the direction and SLI type
// @param direction Whether inbound or outbound metrics are being processed
// @param sliType The type of SLI currently being processed
// @param metrics Object containing metrics for each SLI type
// @returns True if any metrics exist, false if no metrics exist
local checkMetricsExist(direction, sliType, metrics) =
  std.length(std.flattenArrays([
    metrics
    for metrics in std.objectValues(metrics[direction][sliType])
  ])) > 0;

// Creates the Grafana templates for the detail dashboard
// @param metrics Object containing metrics for each SLI type
// @param selectorLabels Object containing selector labels
// @param selectors Object containing Grafana selectors
// @param direction Whether inbound or outbound metrics are being processed
// @returns List of Grafana template objects for detail dashboard
local createTemplates(direction, metrics, selectorLabels, selectors, detailDashboardConfig) =
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
    // std.flattenArrays([
    //   macConfig.sliMetricLibs[sliType].library.createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction)
    //   for sliType in std.objectFields(metrics[direction])
    //   if checkMetricsExist(direction, sliType, metrics)
    // ]),
  ]), function(template) template.name);

// Creates the Grafana panels for the detail dashboard
// @param metrics Object containing metrics for each SLI type
// @param selectorLabels Object containing selector labels
// @param selectors Object containing Grafana selectors
// @returns List of Grafana panel objects for detail dashboard
local createPanels(metrics, selectorLabels, otherConfig, selectors) =
  std.flattenArrays([
    macConfig.sliMetricLibs[sliType].library.createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction)
    for direction in std.objectFields(metrics)
    for sliType in std.objectFields(metrics[direction])
    if checkMetricsExist(direction, sliType, metrics)
  ]);

// Creates a single detail dashboard for a journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param config The config for the service defined in the mixin file
// @param links The links to other dashboards
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns JSON for a detail dashboard
local createDetailDashboard(journeyKey, config, links, sliSpecList) =
  local metricTypesList = getMetricTypesList(journeyKey, sliSpecList);

  local detailDashboardConfig = getDetailDashboardConfig(metricTypesList);

  local metrics = getTargets('metrics', 'inbound', detailDashboardConfig, metricTypesList);

  local selectorLabels = getTargets('selectorLabels', 'inbound', detailDashboardConfig, metricTypesList);

  local customSelectorLabels = getTargets('customSelectorLabels', 'inbound', detailDashboardConfig, metricTypesList);

  local customSelectorValues = getTargets('customSelectors', 'inbound', detailDashboardConfig, metricTypesList);

  local selectors = createSelectors('inbound', selectorLabels, detailDashboardConfig, journeyKey, sliSpecList);

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
    std.prune(createTemplates('inbound', metrics, selectorLabels, selectors, detailDashboardConfig))
  ).addPanels(
    []
    //std.prune(createPanels(metrics, selectorLabels, otherConfig, selectors))
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

// metrics = {
//   inbound: {
//     standardTemplates: {
//       resource: {
//         count: ['a', 'b', 'c', 'x', 'y', 'z'],
//         bucket: ['a', 'b', 'c'],
//       },
//       errorStatus: {
//         count: ['x', 'y', 'z'],
//       },
//     },
//     elements: {
//       httpRequestsAvailability: {
//         count: ['x', 'y', 'z'],
//       },
//       httpRequestsLatency: {
//         count: ['a', 'b', 'c'],
//         bucket: ['a', 'b', 'c'],
//       },
//     },
//   },
// },

// selectorLabels = {
//   inbound: {
//     standardTemplates: {
//       resource: {
//         product: ['a', 'b'],
//         environment: ['a', 'b'],
//       },
//       errorStatus: {
//         product: ['b'],
//         environment: ['b'],
//       },
//     },
//     elements: {
//       httpRequestsAvailability: {
//         product: ['b'],
//         environment: ['b'],
//       },
//       httpRequestsLatency: {
//         product: ['a'],
//         environment: ['a'],
//       },
//     },
//   },
// },
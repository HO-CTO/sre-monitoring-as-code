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

// Gets the list of fields used for metrics by an SLI type
// @param target The name of the field in the MaC config containing metrics (inbound or outbound)
// @param sliType The type of SLI currently being processed
// @param metricTypesList The object containing metric types for each SLI type
// @returns List of metric fields used by an SLI type
local getMetricFields(target, sliType, metricTypesList) =
  std.set([
    metricField
    for metricType in metricTypesList[sliType]
    if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target)
    for metricField in std.objectFields(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target])
  ]);

// Gets the collection of metrics used by each SLI type
// @param metricTypesList The object containing metric types for each SLI type
// @returns Object containing metrics for each SLI type
local getMetrics(metricTypesList) =
  {
    inbound: {
      [sliType]: {
        [metricField]: std.set([
          macConfig.sliMetricLibs[sliType].metricTypes[metricType].metrics[metricField]
          for metricType in metricTypesList[sliType]
        ])
        for metricField in getMetricFields('metrics', sliType, metricTypesList)
      }
      for sliType in std.objectFields(metricTypesList)
    },
    outbound: {
      [sliType]: {
        [metricField]: std.set([
          macConfig.sliMetricLibs[sliType].metricTypes[metricType].metrics[metricField]
          for metricType in metricTypesList[sliType]
          if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], 'outboundMetrics') &&
            std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], 'outboundSelectorLabels')
        ])
        for metricField in getMetricFields('outboundMetrics', sliType, metricTypesList)
      }
      for sliType in std.objectFields(metricTypesList)
    },
  };

// Gets the list of fields used for selector labels by SLI types in journey
// @param target The name of the field in the MaC config containing selector labels (inbound or outbound)
// @param metricTypesList The object containing metric types for each SLI type
// @returns List of selector label fields
local getSelectorLabelFields(target, metricTypesList) =
  std.set([
    selectorLabelField
    for sliType in std.objectFields(metricTypesList)
    for metricType in metricTypesList[sliType]
    if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], target)
    for selectorLabelField in std.objectFields(macConfig.sliMetricLibs[sliType].metricTypes[metricType][target])
  ]);

// Gets the list of selector labels used by SLI types in the journey
// @param metricTypesList The object containing metric types for each SLI type
// @returns Object containing selector labels
local getSelectorLabels(metricTypesList) =
  {
    inbound: {
      [selectorLabelField]: std.set([
        macConfig.sliMetricLibs[sliType].metricTypes[metricType].selectorLabels[selectorLabelField]
        for sliType in std.objectFields(metricTypesList)
        for metricType in metricTypesList[sliType]
        if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType].selectorLabels, selectorLabelField)
      ])
      for selectorLabelField in getSelectorLabelFields('selectorLabels', metricTypesList)
    },
    outbound: {
      [selectorLabelField]: std.set([
        macConfig.sliMetricLibs[sliType].metricTypes[metricType].outboundSelectorLabels[selectorLabelField]
        for sliType in std.objectFields(metricTypesList)
        for metricType in metricTypesList[sliType]
        if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], 'outboundMetrics') &&
          std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], 'outboundSelectorLabels') &&
          std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType].outboundSelectorLabels, selectorLabelField)
      ])
      for selectorLabelField in getSelectorLabelFields('outboundSelectorLabels', metricTypesList)
    },
  };

local getOtherConfigFields(metricTypesList) =
  std.set([
    field
    for sliType in std.objectFields(metricTypesList)
    for metricType in metricTypesList[sliType]
    for field in std.objectFields(macConfig.sliMetricLibs[sliType].metricTypes[metricType])
    if field != 'selectorLabels' && field != 'metrics' && field != 'outboundSelectorLabels' &&
      field != 'outboundMetrics'
  ]);

local getOtherConfig(metricTypesList) = 
  {
    [field]: std.set([
      macConfig.sliMetricLibs[sliType].metricTypes[metricType][field]
      for sliType in std.objectFields(metricTypesList)
      for metricType in metricTypesList[sliType]
      if std.objectHas(macConfig.sliMetricLibs[sliType].metricTypes[metricType], field)
    ])
    for field in getOtherConfigFields(metricTypesList)
  };

// Gets the list of products being used by SLIs in journey
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns The list of products used by SLIs
local getProductList(journeyKey, sliSpecList) =
  std.join('|', std.set(std.filterMap(
    function(sliSpec) std.objectHas(sliSpec.selectors, 'product'),
    function(sliSpec) sliSpec.selectors.product,
    std.objectValues(sliSpecList[journeyKey])
  )));

// Creates Grafana selectors using templates for each selector label
// @param selectorLabels Object containing selector labels
// @param journeyKey The key of the journey having its detail dashboard generated
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns Object containing Grafana selectors
local createSelectors(selectorLabels, journeyKey, sliSpecList) =
  {
    [direction]: {
      [selectorLabelField]: std.join(', ', std.map( 
        function(selectorLabel) '%s=~"$%s|"' % [selectorLabel, '%s_%s' % [direction, selectorLabel]],
        selectorLabels[direction][selectorLabelField]
      ))
      for selectorLabelField in std.objectFields(selectorLabels[direction])
      if selectorLabelField != 'environment' && selectorLabelField != 'product'
    } + {
      environment: std.join(', ', std.map( 
        function(selectorLabel) '%s=~"$environment|"' % selectorLabel,
        selectorLabels[direction]['environment']
      )),
      product: std.join(', ', std.map( 
        function(selectorLabel) '%s=~"%s|"' % [selectorLabel, getProductList(journeyKey, sliSpecList)],
        selectorLabels[direction]['product']
      )),
    }
    for direction in std.objectFields(selectorLabels)
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
local createTemplates(metrics, selectorLabels, otherConfig, selectors, direction) =
  local allMetrics = std.set([
    metric
    for sliType in std.objectFields(metrics[direction])
    for metricField in std.objectFields(metrics[direction][sliType])
    for metric in metrics[direction][sliType][metricField]
  ]);

  std.set(std.flattenArrays([
    [
      template.new(
        name = '%s_%s' % [direction, selectorLabel],
        datasource = 'prometheus',
        query = 'label_values({__name__=~"%(allMetrics)s", %(environmentSelectors)s, %(productSelectors)s}, %(selectorLabel)s)' % {
          allMetrics: std.join('|', allMetrics),
          environmentSelectors: selectors[direction].environment,
          productSelectors: selectors[direction].product,
          selectorLabel: selectorLabel,
        },
        includeAll = true,
        multi = true,
        refresh = 'time',
        label = stringFormattingFunctions.capitaliseFirstLetters('%s %s' % [direction, std.strReplace(selectorLabel, '_', ' ')]),
      )
      for selectorLabelField in std.objectFields(selectorLabels[direction])
      if selectorLabelField != 'environment' && selectorLabelField != 'product'
      for selectorLabel in selectorLabels[direction][selectorLabelField]
    ],
    std.flattenArrays([
      macConfig.sliMetricLibs[sliType].library.createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction)
      for sliType in std.objectFields(metrics[direction])
      if checkMetricsExist(direction, sliType, metrics)
    ]),
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

  local metrics = getMetrics(metricTypesList);

  local selectorLabels = getSelectorLabels(metricTypesList);

  local otherConfig = getOtherConfig(metricTypesList);

  local selectors = createSelectors(selectorLabels, journeyKey, sliSpecList);

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
    std.prune(std.flattenArrays([
      createTemplates(metrics, selectorLabels, otherConfig, selectors, direction)
      for direction in std.objectFields(metrics)
    ]))
  ).addPanels(
    std.prune(createPanels(metrics, selectorLabels, otherConfig, selectors))
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

// This file is for generating the summary dashboard which shows an overview of the SLI
// performances of all of the services being monitored

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local dashboard = grafana.dashboard;
local template = grafana.template;
local tablePanel = grafana.tablePanel;

local envMap = {
  dev: 'dev',
  test: 'test|qa',
  stage: 'staging|stage',
  prod: 'prod|live',
  mgmt: 'mgmt',
};

// PromQL selector for environment label
local environmentLabelSelector = 'environment="$environment"';

// The panels for the summary dashboard
local panels = [
  tablePanel.new(
    title = 'SLO Status Aggregated by Service',
    datasource = 'prometheus',
  ).addTarget(
    prometheus.target(
      'avg(avg_over_time(sli_percentage{%(environmentLabelSelector)s}[30d])) by (service) * 100' % 
        environmentLabelSelector,
      format = 'table',
      instant = true,
      legendFormat = 'SLO Status',
    ),
  ).addTarget(
    prometheus.target(
      '(avg(avg_over_time(sli_percentage{%(environmentLabelSelector)s}[30d])) by (service) - 
        avg(avg_over_time(sli_percentage{%(environmentLabelSelector)s}[30d] offset 30d)) by (service))    
        / (avg(avg_over_time(sli_percentage{%(environmentLabelSelector)s}[30d])) by (service)) * 100' % {
          environmentLabelSelector: environmentLabelSelector,
        },
      format = 'table',
      instant = true,
      legendFormat = '% Change',
    ),
  ).addTarget(
    prometheus.target(
      'count by (service)(count_over_time((sli_value{%(environmentLabelSelector)s} < bool Inf)[30d:10m]))' %
        environmentLabelSelector,
      format = 'table',
      instant = true,
      legendFormat = 'SLO Coverage',
    ),
  ).addTarget(
    prometheus.target(
      '(sum(sum_over_time(aggregated_alb_request_count_sum{%(environmentLabelSelector)s}[30d])) by (service))' %
        environmentLabelSelector,
      format = 'table',
      instant = true,
      legendFormat = 'Traffic',
    ),
  ).addTransformations(
    [
      { id: 'labelsToFields' },
      {
        id: 'organize',
        options: {
          excludeByName: {
            Time: true,
          },
          renameByName: {
            'Value #A': 'SLO Status',
            'Value #B': '% Change',
            'Value #C': 'SLO Coverage',
            'Value #D': 'Traffic',
            service: 'Service',
            environment: 'Environment',
          },
        },
      },
      //{ id: 'sortBy',
      //options:
      //{
      //fields: {},
      //sort: [
      //{
      //"field": "Service",
      //},
      //],
      //},
      //},
    ]
  ) + { fieldConfig+: {
    overrides+:
      [
        {
          matcher: { id: 'byName', options: 'SLO Status' },
          properties: [
            { id: 'unit', value: 'percent' },
            { id: 'custom.displayMode', value: 'basic' },
            {
              id: 'thresholds',
              value: {
                mode: 'absolute',
                steps: [
                  { color: 'rgba(86, 166, 75, 0.01)', value: null },
                  { color: 'red', value: 1 },
                  { color: '#EAB839', value: 90 },
                  { color: 'green', value: 95 },
                ],
              },
            },
          ],
        },
        {
          matcher: { id: 'byName', options: '% Change' },
          properties: [{ id: 'unit', value: 'percent' }],
        },
        {
          matcher: { id: 'byName', options: 'Coverage' },
          properties: [{ id: 'unit', value: 'none' }],
        },
        {
          matcher: { id: 'byName', options: 'Traffic' },
          properties: [{ id: 'unit', value: 'none' }],
        },
        {
          matcher: { id: 'byName', options: 'environment' },
          properties: [{ id: 'custom.width', value: '2' }],
        },
      ],
    defaults+:
      {
        links:
          [
            {
              title: '${__data.fields.service} product view',
              url: '/d/${__data.fields.service}-product-view?${environment:queryparam}',
            },
          ],
        custom+:
          {
            align: 'left',
          },
      },
  } } + { gridPos: { w: 24, h: 10 } },

  tablePanel.new(
    title = 'SLO Status Aggregated by Service and SLI Category',
    datasource = 'prometheus',
  ).addTarget(
    prometheus.target(
      'avg(avg_over_time(sli_percentage{%(environmentLabelSelector)s}[30d])) by (service, category) * 100' %
        environmentLabelSelector,
      format = 'time_series',
      instant = true,
      legendFormat = 'SLO Status',
    ),
  ).addTransformations(
    [
      {
        id: 'labelsToFields',
        options: {
          valueLabel: 'category',
        },
      },
      {
        id: 'organize',
        options:
          {
            excludeByName: {
              Time: true,
              Value: true,
            },
            indexByName: {
              Availability: 3,
              Latency: 4,
              'Pipeline Correctness': 5,
              'Pipeline Freshness': 6,
              Time: 0,
              Value: 7,
              service: 2,
            },
            renameByName: {
              service: 'Service',
            },
          },
      },
      //{ id: 'sortBy',
      //options:
      //{
      //fields: {},
      //sort: [
      //{
      //"field": "Service",
      //},
      //],
      //},
      //},
    ]
  ) + { fieldConfig: {
    overrides+:
      [
        {
          matcher: { id: 'byName', options: 'Availability' },
          properties: [
            { id: 'unit', value: 'percent' },
            { id: 'custom.displayMode', value: 'basic' },
            {
              id: 'thresholds',
              value: {
                mode: 'absolute',
                steps: [
                  { color: 'rgba(86, 166, 75, 0.01)', value: null },
                  { color: 'red', value: 1 },
                  { color: '#EAB839', value: 90 },
                  { color: 'green', value: 95 },
                ],
              },
            },
          ],
        },
        {
          matcher: { id: 'byName', options: 'Latency' },
          properties: [
            { id: 'unit', value: 'percent' },
            { id: 'custom.displayMode', value: 'basic' },
            {
              id: 'thresholds',
              value: {
                mode: 'absolute',
                steps: [
                  { color: 'rgba(86, 166, 75, 0.01)', value: null },
                  { color: 'red', value: 1 },
                  { color: '#EAB839', value: 90 },
                  { color: 'green', value: 95 },
                ],
              },
            },
          ],
        },
        {
          matcher: { id: 'byName', options: 'Pipeline Correctness' },
          properties: [
            { id: 'unit', value: 'percent' },
            { id: 'custom.displayMode', value: 'basic' },
            {
              id: 'thresholds',
              value: {
                mode: 'absolute',
                steps: [
                  { color: 'rgba(86, 166, 75, 0.01)', value: null },
                  { color: 'red', value: 1 },
                  { color: '#EAB839', value: 90 },
                  { color: 'green', value: 95 },
                ],
              },
            },
          ],
        },
        {
          matcher: { id: 'byName', options: 'Pipeline Freshness' },
          properties: [
            { id: 'unit', value: 'percent' },
            { id: 'custom.displayMode', value: 'basic' },
            {
              id: 'thresholds',
              value: {
                mode: 'absolute',
                steps: [
                  { color: 'rgba(86, 166, 75, 0.01)', value: null },
                  { color: 'red', value: 1 },
                  { color: '#EAB839', value: 90 },
                  { color: 'green', value: 95 },
                ],
              },
            },
          ],
        },
      ],
    defaults+:
      {
        links:
          [
            {
              title: '${__data.fields.service} product view',
              url: '/d/${__data.fields.service}-product-view?${environment:queryparam}',
            },
          ],
        custom+:
          {
            align: 'left',
          },
      },
  } } + { gridPos: { w: 24, h: 10 } },
];

// Creates the summary dashboard containing two tables: one which shows overall SLI performance
// for each service and how many SLIs they have and one which shows the SLI performance of
// different SLI types for each service
// @param config The config defined in the platform mixin file
// @returns The JSON defining the summary dashboard
local createSummaryDashboard(config) =
  {
    grafanaDashboards+: {
      'summary-view.json':
        dashboard.new(
          title = 'summary-view',
          uid = 'summary-view',
          tags = ['mac-version: %s' % config.macVersion, 'summary-view'],
          schemaVersion = 18,
          editable = true,
          time_from = 'now-3h',
          refresh = '5m',
        ).addLinks(
          [
            {
              asDropdown: false,
              icon: 'dashboard',
              includeVars: true,
              tags: ['summary-view'],
              title: 'summary-view',
              type: 'dashboards',
            },
          ]
        ).addTemplate(
          template.new(
            name = 'environment',
            datasource = 'prometheus',
            query = 'label_values(environment)',
            refresh = 'load',
            label = 'Environment',
          )
        ).addPanels(std.prune(panels))
    },
  };

// File exports
{
  createSummaryDashboard(config): createSummaryDashboard(config),
}

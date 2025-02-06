// This file is for generating the summary view dashboard which shows an  summary view of the SLI
// performances of all of the services being monitored

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local dashboard = grafana.dashboard;
local template = grafana.template;
local tablePanel = grafana.tablePanel;

// MaC imports
local macConfig = import '../mac-config.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';
local dashboardFunctions = import './dashboard-standard-elements.libsonnet';

// PromQL selector for environment label
local labelSelector = 'sli_environment=~"$environment", aws_account=~"$aws_account|"';

// The panels for the summary view dashboard
local panels = [

  tablePanel.new(
    title='SLO Status Aggregated by Service (30d unless otherwise stated) ',
    datasource='prometheus',
  ).addTarget(
    prometheus.target(
      'avg(avg_over_time(sli_percentage{%(labelSelector)s}[30d])) by (service, sli_environment) * 100' %
      labelSelector,
      format='table',
      instant=true,
      legendFormat='SLO Status',
    ),
  ).addTarget(
    prometheus.target(
      |||
        (avg(avg_over_time(sli_percentage{%(labelSelector)s}[30d])) by (service, sli_environment) -
        avg(avg_over_time(sli_percentage{%(labelSelector)s}[30d] offset 30d)) by (service, sli_environment))
        / (avg(avg_over_time(sli_percentage{%(labelSelector)s}[30d])) by (service, sli_environment)) * 100
      ||| % {
        labelSelector: labelSelector,
      },
      format='table',
      instant=true,
      legendFormat='% Change',
    ),
  ).addTarget(
    prometheus.target(
      'count by (service, sli_environment)(count_over_time((sli_value{%(labelSelector)s} < bool Inf)[30d:10m]))' %
      labelSelector,
      format='table',
      instant=true,
      legendFormat='SLO Coverage',
    ),
  ).addTarget(
    prometheus.target(
      'count by (service, sli_environment)(rate(ALERTS{%(labelSelector)s,alertstate="firing"}[30d]))' %
      labelSelector,
      format='table',
      instant=true,
      legendFormat='Fired Alerts',
    ),
  ).addTarget(
    prometheus.target(
      'sum without (exported_namespace) (label_replace( sum by(exported_namespace) (increase(nginx_ingress_controller_request_duration_seconds_count{exported_namespace=~"$environment"}[6h])), "sli_environment", "$1", "exported_namespace", "(.*)"))',
      format='table',
      instant=true,
      legendFormat='Traffic',
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
            'Value #D': 'Fired Alerts',
            'Value #E': 'Traffic (6h)',
            service: 'Service',
            sli_environment: 'Environment',
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
          matcher: { id: 'byName', options: 'SLO Coverage' },
          properties: [{ id: 'unit', value: 'none' }],
        },
        {
          matcher: { id: 'byName', options: 'environment' },
          properties: [{ id: 'custom.width', value: '2' }],
        },
        {
          matcher: { id: 'byName', options: 'Fired Alerts' },
          properties: [{ id: 'unit', value: 'none' }, { id: 'unit', value: 'locale' }],
        },
        {
          matcher: { id: 'byName', options: 'Traffic' },
          properties: [{ id: 'decimals', value: '0' }, { id: 'unit', value: 'locale' }],
        },
      ],
    defaults+:
      {
        links:
          [
            {
              title: '%s-${__data.fields.service}' % macConfig.macDashboardPrefix.uid,
              url: '/d/%s-${__data.fields.service}?${environment:queryparam}' % macConfig.macDashboardPrefix.uid,
            },
          ],
        custom+:
          {
            align: 'left',
          },
      },
  } } + { gridPos: { w: 24, h: 10 } },
  tablePanel.new(
    title='SLO Status Aggregated by Service and SLI Category',
    datasource='prometheus',
  ).addTarget(
    prometheus.target(
      'avg(avg_over_time(sli_percentage{%(labelSelector)s}[30d])) by (service, sli_environment, sli_type) * 100' %
      labelSelector,
      format='time_series',
      instant=true,
      legendFormat='SLO Status',
    ),
  ).addTransformations(
    [
      {
        id: 'labelsToFields',
        options: {
          valueLabel: 'sli_type',
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
              availability: 3,
              latency: 4,
              correctness: 5,
              freshness: 6,
              throughput: 7,
              iops: 8,
              Time: 0,
              Value: 9,
              service: 1,
              sli_environment: 2,
            },
            renameByName: {
              service: 'Service',
              sli_environment: 'Environment',
              availability: 'Availability',
              latency: 'Latency',
              correctness: 'Pipeline Correctness',
              freshness: 'Pipeline Freshness',
              throughput: 'Throughput',
              iops: 'IOPS',
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
          matcher: { id: 'byName', options: 'availability' },
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
          matcher: { id: 'byName', options: 'latency' },
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
          matcher: { id: 'byName', options: 'correctness' },
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
          matcher: { id: 'byName', options: 'freshness' },
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
          matcher: { id: 'byName', options: 'throughput' },
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
          matcher: { id: 'byName', options: 'iops' },
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
              title: '%s-${__data.fields.service} product view' % macConfig.macDashboardPrefix.uid,
              url: '/d/%s-${__data.fields.service}?${environment:queryparam}' % macConfig.macDashboardPrefix.uid,
            },
          ],
        custom+:
          {
            align: 'left',
          },
      },
  } } + { gridPos: { w: 24, h: 10 } },
];

// Creates the  summary view dashboard containing two tables: one which shows overall SLI performance
// for each service and how many SLIs they have and one which shows the SLI performance of
// different SLI types for each service
// @param config The config defined in the platform mixin file
// @returns The JSON defining the summary view dashboard
local createSummaryDashboard(config) =
  {
    grafanaDashboards+: {
      [std.join('-', [macConfig.macDashboardPrefix.uid, 'summary']) + '.json']:
        dashboard.new(
          title=stringFormattingFunctions.capitaliseFirstLetters(std.join(' / ', [macConfig.macDashboardPrefix.title, 'summary'])),
          uid=std.join('-', [macConfig.macDashboardPrefix.uid, 'summary']),
          tags=['mac-version: %s' % config.macVersion, 'summary'],
          schemaVersion=18,
          editable=true,
          time_from='now-3h',
          refresh='5m',
        ).addLinks(
          [
            {
              asDropdown: false,
              icon: 'dashboard',
              includeVars: true,
              tags: ['view:summary'],
              title: 'view:summary',
              type: 'dashboards',
            },
            {
              asDropdown: true,
              icon: 'dashboard',
              includeVars: false,
              tags: ['view:product'],
              title: 'view:product',
              type: 'dashboards',
            },
          ]
        ).addTemplate(
          template.new(
            name='environment',
            datasource='prometheus',
            query='label_values(sli_value, sli_environment)',
            refresh='load',
            includeAll=true,
            multi=true,
            label='Environment',
          )
        ).addTemplate(
          template.new(
            name='aws_account',
            datasource='prometheus',
            query='label_values(sli_value{sli_environment=~"$environment"}, aws_account)',
            refresh='time',
            includeAll=true,
            multi=true,
            label='AWS Account',
          )
        ).addPanel(
          dashboardFunctions.createDocsTextPanel(macConfig.dashboardDocs.summaryView), gridPos={ h: 4, w: 24, x: 0, y: 0 }
        ).addPanels(std.prune(panels)),
    },
  };

// File exports
{
  createSummaryDashboard(config): createSummaryDashboard(config),
}

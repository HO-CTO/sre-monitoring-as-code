# How to contribute

This is the contribution guide for sre-monitoring-as-code. This guide will cover the primary way we
expect contributions to be made, which is adding new metric types, SLI values and detail dashboard
elements.

# File and object layouts

This section will describe the layouts of the files and objects that will be used when creating new
metric types, SLI values and detail dashboard elements.

## metric-types.libsonnet

The metric-types.libsonnet file in the monitoring-as-code/src directory contains the config for the
different metric types.

```
{
  'metric_type_name': {
    // The config for the metric type
    metricTypeConfig: {
      // Standard keywords mapped to the Prometheus selector labels for metric type
      // Required
      selectorLabels: {
        // Required
        environment: 'name_of_metric_label_specifying_environment',
        // Required
        product: 'name_of_metric_label_specifying_product',
        // Optional
        resource: 'name_of_metric-label_specifying_resource',
        // Only required for certain SLI values and detail dashboard elements
        errorStatus: 'name_of_metric_label_specifying_status',
      },
      // Keywords for metrics mapped to metrics used by SLI values and detail dashboard elements
      // Required
      metrics: {
        metricKeyword: 'name_of_metric',
      },
      // Same as selectorLabels item but for outbound detail dashboard elements
      // Optional
      outboundSelectorLabels: {
        // Required
        environment: 'name_of_metric_label_specifying_environment',
        // Required
        product: 'name_of_metric_label_specifying_product',
        // Optional
        resource: 'name_of_metric-label_specifying_resource',
        // Only required for certain detail dashboard elements
        errorStatus: 'name_of_metric_label_specifying_status',
      },
      // Same as metrics item but for outbound detail dashboard elements
      // Optional
      outboundMetrics: {
        metricKeyword: 'name_of_metric',
      },
      // Labels for custom selectors
      // Only required for certain SLI values and detail dashboard elements
      customSelectorLabels: {
        customSelectorKeyword: 'name_of_metric_label_for_custom_selector',
      },
      // Values for custom selectors
      // Only required for certain SLI values and detail dashboard elements
      customSelectors: {
        customSelectorKeyword: 'value for custom selector',
      },
    },
    // The config for the different SLI types (availability, latency, etcetera) that can be used
    // with this metric type
    sliTypesConfig: {
      // Name of the SLI type (availability, latency, etcetera)
      sliType: {
        // Import for SLI value library file used by the SLI type
        library: (import 'sli-value-libraries/name-of-sli-value-library-file.libsonnet'), 
        // The description for the SLI type
        description: 'Description for the SLI type',
        // Metric keywords used by the SLI value library file mapped to corresponding metric
        // keywords defined in metricTypeConfig
        targetMetrics: {
          targetMetricKeyword: 'metricKeyword',
        },
      },
    },
    // The config for the detail dashboard elements that will be generated when this metric type is
    // included in journey
    detailDashboardConfig: {
      // List of selector label keywords that standard dynamic templates will be generated for
      standardTemplates: ['selectorLabelKeyword'],
      // List of detail dashboard element keywords that will be used when creating detail dashboard
      // for journey containing this metric type
      elements: ['elementKeyword'],
      // Metric keywords used by the detail dashboard element files mapped to corresponding metric
      // keywords defined in metricTypeConfig
      targetMetrics: {
        targetMetricKeyword: 'metricKeyword',
      },
    },
  },
}
```

## sli-value-libraries

The sli-value-libraries directory contains all of the files for generating different types of SLI
value recording rules and the corresponding graph panels.

SLI value library files should be named in a way that gives a very basic explanation of what the
SLI value represents and what differentiates it from similar SLI value library files.

As well as the createSliValueRule and createGraphPanel functions, at the top of each SLI value
library should be a description of the SLI value calculation, the list of target metrics and a list
of any additional config (either from the mixin file SLI specs or the metric type config).

## detailDashboardElements

The detailDashboardElements object is defined in the mac-config.libsonnet file. It maps keywords
for the detail dashboard elements to imports for the corresponding file in the
detail-dashboard-elements directory.

These keywords should have names that give users an idea of what metric types these elements would
be applicable for.

## detail-dashboard-elements

The detail-dashboard-elements directory contains all of the files for generating panels, custom
templates and custom selectors for the detail dashboard.

The names of detail dashboard element files should match the corresponding keyword in the
detailDashboardElements object in mac-config.libsonnet, however instead of being in camel case the
file name should be separated using hyphens in line with other file and directory names.

Similar to SLI value library files, at the top of each detail dashboard elements file there should
be lists of target metrics and additional config. Each detail dashboard elements file must also
contain the createCustomTemplates, createCustomSelectors and createPanels functions.
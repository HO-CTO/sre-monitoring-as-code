# How to contribute

This is the contribution guide for sre-monitoring-as-code. This guide will cover the primary way we
expect contributions to be made, which is adding new metric types, SLI values and detail dashboard
elements, however general advice can be applied to other types of contribution as well.

When making a contribution you should start by creating a GitHub issue. Once the issue is created
you should then select the option to create a branch for the issue. Once this new branch has been
created and checked out you can start working on the changes.

Once you have made the changes you should commit them with an all lower case message describing the
changes made and prefixed by the type of change, for example, "feat: added new metric type for
grafana". Below are the different types of changes:

- **feat**: New feature for the user, not a new feature for build script.
- **fix**: Bug fix for the user, not a fix to a build script.
- **docs**: Changes to the documentation.
- **style**: Formatting, missing semi colons, etcetera, no production code change.
- **refactor**: Refactoring production code, for example, renaming a variable.
- **test**: Adding missing tests, refactoring tests, no production code change.
- **chore**: Updating grunt tasks, etcetera, no production code change.

Once the changes have been committed, push them to the origin and create a pull request. The
description of the pull request should include a link to the issue, which can be done by adding
\#x where x is the number of the issue.

The pull request must be reviewed by two members of our team and pass the checks in our pipelines
before it can be squashed and merged.

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

# Contributing to metric-types.libsonnet

This section will explain how to contribute to the metric-types.libsonnet file.

The purpose of the metric types is to group together metrics that are exposed from the same source,
typically by grouping metrics which names start the same, for example,
http\_server\_requests\_seconds\_count and http\_server\_requests\_seconds\_bucket only differ with
the last word, so can be sensibly grouped together under the http\_server\_requests\_seconds metric
type.

It is also important to ensure that the metrics share the same selector labels, otherwise it won't
work, however by using the logic described above this typically won't be an issue.

## Updating a metric type that already exists

### Adding new selector labels

The selector labels in metricTypeConfig are designed to be mapped to the selectors defined in the
SLI specs in the mixin files and the environment specified when running sre-monitoring-as-code.

There are four standard selector labels:

- **environment**: The selector label used by the metrics to select the environment, required by
all metric types.
- **product**: The selector label used by the metrics to select the product or service, required by
all metric types.
- **resource**: The selector label used by the metrics to select the resource, for example, URI
path, optional.
- **errorStatus**: The selector label used by the metrics to select the value that will be used to
determine if a metric sample is good or bad, required by metric types that use SLI values which
need an errorStatus selector.

The environment and product selector labels should always be present in a metric type since there
will always be an environment selector and each SLI spec should have a product selector.

The resource selector label is used for any label that can be used to specify a specific path or
component of a product. It will allow SLI specs using the metric type to have a resource selector
for a more precise SLI.

The errorStatus selector label is used for labels that can be used to determine if a metric sample
is good or bad, for example, status code for HTTP requests. It is required by certain SLI values.

Certain detail dashboard elements files may also require a resource or errorStatus selector label.

If a metric type could make use of additional selectors in the SLI spec, other selector labels may
be added. The keyword should be camel case and descriptive like the standard selector labels.
Additional selector labels should not be referred to by SLI value library files and detail
dashboard elements files unless absolutely necessary, however it is fine to include them in the
standardTemplates of the metric types detailDashboardConfig.

To add a new selector label add the keyword for the selector to the selectorLabels item in
metricTypeConfig, then set the value to be the name of the actual selector label as it is shown in
Prometheus.

### Adding new metrics

Metrics are defined using a keyword mapped to the name of the actual metric. The keyword is written
in camel case and should give a basic description of what the metric represents in the metric type.

To add a new metric add the keyword for the metric to the metrics item in metricTypeConfig, then
set the value to be the name of the actual metric as it is shown in Prometheus.

### Adding outbound selector labels and metrics

To enable outbound elements for the detail dashboard one of the metric types used in the journey
must have both the outboundSelectorLabels and outboundMetrics items in the metricTypeConfig.

The outboundSelectorLabels and outboundMetrics items are defined the same way as the regular
selectorLabels and metrics item, however the outbound variants are for metrics that track actions
made by the service to other services, rather than actions being made to the service itself.

It is important that the keywords for outboundSelectorLabels and outboundMetrics match the keywords
used by selectorLabels and metrics.

Since the outbound items are only used by the detail dashboard elements files and not the SLI value
library files, you only need to include selector labels and metrics used by the detail dashboard
elements files.

To add new outbound selector labels or metrics follow the same instructions detailed in the adding
new selector labels and adding new metrics sections but with outboundSelectorLabels and
outboundMetrics instead of the regular variants.

### Adding custom metric type config

Custom config for metric types can be defined using the customSelectorLabels and customSelectors
items in metricTypeConfig.

Unlike the relationship between selectorLabels defined for metric types and selectors defined for
SLI specs, both customSelectorLabels and customSelectors are defined in metricTypeConfig with
static values.

Unlike non standard selector labels, custom selector labels and custom selectors are referred to in
SLI value library files and detail dashboard elements files and should be included in the
additional config section at the top of those two file types. Custom selector labels cannot be
added to standardTemplates in detailDashboardConfig however.

When adding new custom selector labels or custom selectors make sure the keywords used match the
keywords defined in the additional config sections at the top of SLI value library files and detail
dashboard elements files being used by the metric type.

To add a new custom selector label add the keyword for the custom selector label to the
customSelectorLabels item in metricTypeConfig, then set the value to be the name of the actual
selector label as it is shown in Prometheus.

To add a new custom selector add the keyword for the custom selector to the customSelectors item in
metricTypeConfig, then set the value.

### Adding new SLI types

SLI types should be named after an SLI category, for example, availability, latency, etcetera and
should have appropriate description, SLI value library and target metrics to provide that SLI
category for the metric type.

The SLI types of a metric type are stored in the sliTypesConfig item.

When adding a new SLI type you first need to decide which SLI value library is most appropriate by
examining the target metrics, additional config and calculations performed by the library. The
metric type must have the correct metrics to meet the criteria of the target metrics and all of the
additional config must exist for the metric type. The calculation must also produce an appropriate
value for the SLI category you are adding.

Once you've selected the SLI value library you want to use, add to the SLI type the library item
which holds the import for the SLI value library you are using, then add the targetMetrics item
which maps the target metric keywords defined in the SLI value library to the metric keywords
defined in the metrics item in metricTypeConfig.

The final step is to add an appropriate description for the SLI type, this is stored in the
description item of the SLI type.

### Adding to detailDashboardConfig

There are three items in the detailDashboardConfig for each metric type. These are the
standardTemplates item which contains a list of selector label keywords, the elements item which
contains a list of detail dashboard elements keywords and the targetMetrics item, which is similar
to the targetMetrics item for SLI types but using the target metrics defined in detail dashboard
elements files instead.

To add to the standardTemplates item add the keyword of one of the selector labels in the
selectorLabels item in metricTypeConfig (not product or environment) to the list.

To add to the elements item you first need to check that the corresponding detail dashboard
elements file is appropriate for the metric type. The metric type must have the correct metrics to
meet the criteria of the target metrics and all of the additional config must exist for the metric
type. If this is the case add the detail dashboard elements keyword to the elements item list. The
target metrics item must be kept up to date with all of the target metric keywords present and
mapped to a corresponding metric keyword from the metrics item in metricTypeConfig.

## Adding a new metric type

This section will only cover the bare minimum when creating a new metric type, to add more detailed
config refer to the previous section **Updating a metric type that already exists**.

Start by copying the template metric type object at the bottom of the file and pasting it further
up. Rename the new object from template to the matching part of the metric names you are grouping
together.

Fill in the values for environment and product in the selectorLabels item in the metricTypeConfig
of the new metric type, more information in the section **Adding new selector labels**.

Then follow instructions in sections **Adding new metrics** and **Adding new SLI types** to add the
first set of metrics and the first SLI type. The metric type can now be used for an SLI spec in a
mixin file.

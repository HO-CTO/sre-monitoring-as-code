// @ts-check

const { compact, filter } = require("lodash");

const histograms = [];

const { promClient, register } = require("../prometheus");

const _createHistogram = ({ name, description, labels = {}, buckets }) => {
  const histogramConfig = {
    name: name,
    help: description,
    labelNames: Object.keys(labels),
  };

  if (buckets) {
    histogramConfig["buckets"] = buckets;
  }

  const histogram = new promClient.Histogram(histogramConfig);

  return histogram;
};

const _getHistogramValue = async (name, labelFilter = {}) => {
  const metricValue = await register.getSingleMetricAsString(name);
  const metricValueLines = metricValue.split("\n");

  const result = metricValueLines.filter((value) => !value.startsWith("#"));

  const returnValue = result.map((item) => {
    const matches = item.match(
      /^(?<metricName>\w+){(?<labels>.+)}\s+(?<value>\d+)$/
    );
    if (matches === null) {
      return null;
    }

    return {
      name: matches.groups?.metricName,
      labels: matches.groups?.labels.split(",").reduce((prev, curr) => {
        const [labelKey, labelValue] = curr.split("=");
        return { ...prev, [labelKey]: labelValue.replace(/"/g, "") };
      }, {}),
      value: matches.groups?.value,
    };
  });

  return Promise.resolve(compact(filter(returnValue, { labels: labelFilter })));
};

const listHistograms = () => {
  return histograms;
};

const getHistogram = (id) => {
  const [gauge] = histograms.filter((item) => item?.name === id);
  return gauge;
};

const createHistogram = ({ name, description, labels, buckets, value }) => {
  const histogram = _createHistogram({
    name,
    description,
    labels,
    buckets,
  });

  register.registerMetric(histogram);
  histograms.push(histogram);
  return histogram;
};

const deleteHistogram = async (id) => {
  const index = histograms.findIndex((item) => item?.name === id);
  if (index < 0) {
    throw new Error(`Gauge with name ${id} does not exist.`);
  }

  register.removeSingleMetric(id);
  const [removed] = histograms.splice(index, 1);
  return Promise.resolve(removed);
};

const observe = (id, labels = {}, value = 1) => {
  const index = histograms.findIndex((item) => item?.name === id);
  if (index < 0) {
    throw new Error(`Gauge with name ${id} does not exist.`);
  }

  histograms[index].labels(labels).observe(value);
  return histograms[index];
};

module.exports = {
  listHistograms,
  getHistogram,
  createHistogram,
  deleteHistogram,
  observe,
  _getHistogramValue,
};

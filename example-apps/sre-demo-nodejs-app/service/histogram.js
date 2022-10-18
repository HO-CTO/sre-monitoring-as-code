const histogramDAO = require("../data/histogramDAO");

const listHistograms = async () => {
  const histograms = histogramDAO.listHistograms();

  return Promise.all(
    histograms.map(async (item) => ({
      name: item.name,
      value: await histogramDAO._getHistogramValue(item.name),
    }))
  );
};

const getHistogram = async (id) => {
  const histogram = histogramDAO.getHistogram(id);
  return Promise.resolve({
    name: histogram.name,
    value: await histogramDAO._getHistogramValue(histogram.name),
  });
};

const createHistogram = ({ name, description, labelNames, buckets }) => {
  histogramDAO.createHistogram({
    name,
    description,
    labelNames,
    buckets,
  });

  return {
    name,
    description,
    labelNames,
  };
};

const deleteHistogram = async (id) => {
  const histogram = await getHistogram(id);
  await histogramDAO.deleteHistogram(id);
  return Promise.resolve(histogram);
};

const observe = async (id, labels = {}, value = 1) => {
  const histogram = histogramDAO.observe(id, labels, value);
  const histogramValue = await histogramDAO._getHistogramValue(
    histogram.name,
    labels
  );
  return Promise.resolve({
    name: histogram.name,
    value: histogramValue,
  });
};

module.exports = {
  listHistograms,
  getHistogram,
  createHistogram,
  deleteHistogram,
  observe,
};

const gaugeDAO = require("../data/gaugeDAO");

const listGauges = async () => {
  const gauges = gaugeDAO.listGauges();

  return Promise.all(
    gauges.map(async (item) => ({
      name: item.name,
      value: await gaugeDAO._getGaugeValue(item.name),
    }))
  );
};

const getGauge = async (id) => {
  const gauge = gaugeDAO.getGauge(id);
  return Promise.resolve({
    name: gauge.name,
    value: await gaugeDAO._getGaugeValue(gauge.name),
  });
};

const createGauge = ({ name, description, labels = {}, value }) => {
  gaugeDAO.createGauge({
    name,
    description,
    labels,
    value,
  });

  return {
    name,
    description,
    labels,
    value,
  };
};

const deleteGauge = async (id) => {
  const gauge = await getGauge(id);
  await gaugeDAO.deleteGauge(id);
  return Promise.resolve(gauge);
};

const incrementGauge = async (id, labels = {}, value = 1) => {
  const gauge = gaugeDAO.incrementGauge(id, labels, value);
  const gaugeValue = await gaugeDAO._getGaugeValue(gauge.name, labels);
  return Promise.resolve({
    name: gauge.name,
    value: gaugeValue,
  });
};

const decrementGauge = async (id, labels = {}, value = 1) => {
  const gauge = gaugeDAO.decrementGauge(id, labels, value);
  const gaugeValue = await gaugeDAO._getGaugeValue(gauge.name, labels);
  return Promise.resolve({
    name: gauge.name,
    value: gaugeValue,
  });
};

const setGauge = async (id, labels = {}, value = 1) => {
  const gauge = gaugeDAO.setGauge(id, labels, value);
  const gaugeValue = await gaugeDAO._getGaugeValue(gauge.name, labels);
  return Promise.resolve({
    name: gauge.name,
    value: gaugeValue,
  });
};

module.exports = {
  listGauges,
  getGauge,
  createGauge,
  deleteGauge,
  incrementGauge,
  decrementGauge,
  setGauge,
};

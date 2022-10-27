const counterDAO = require("../data/counterDAO");
const { defaultLabelKeys } = require("../prometheus");

const listCounters = async () => {
  const listOfCounters = counterDAO.listCounters();

  return Promise.all(
    listOfCounters.map(async (item) => ({
      name: item.name,
      value: await counterDAO._getCounterValue(item.name),
    }))
  );
};

const getCounter = async (id) => {
  const counter = counterDAO.getCounter(id);
  return Promise.resolve({
    name: counter.name,
    value: await counterDAO._getCounterValue(counter.name),
  });
};

const createCounter = ({ name, description, labels = {}, value }) => {
  counterDAO.createCounter({
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

const deleteCounter = async (id) => {
  const counter = await getCounter(id);
  await counterDAO.deleteCounter(id);
  return Promise.resolve(counter);
};

const incrementCounter = async (id, labels = {}, value = 1) => {
  const counter = counterDAO.incrementCounter(id, labels, value);
  const counterValue = await counterDAO._getCounterValue(counter.name, labels);
  return Promise.resolve({
    name: counter.name,
    value: counterValue,
  });
};

module.exports = {
  listCounters,
  getCounter,
  createCounter,
  deleteCounter,
  incrementCounter,
};

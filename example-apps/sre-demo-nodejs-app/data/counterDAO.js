// @ts-check

const counters = [];

const { promClient, register } = require('../prometheus');

const _createCounter = ({name, description, labelNames = [], value}) => {
    const counter = new promClient.Counter({
        name: name,
        help: description,
        labelNames,
    });

    if (value) {
        counter.inc(value);
    }

    return counter;
}

const _getCounterValue = async (name, label = "") => {
    const metricValue = await register.getSingleMetricAsString(name);

    const metricValueLines = metricValue.split('\n');
    console.log({metricValueLines})

    const result = metricValueLines.filter(value => value.includes(label));

    if (result.length === 0) {
        return Promise.resolve(0);
    }

    const matches = result[0].match(/(\d+)$/);
    if (matches === null) {
        return Promise.resolve(0);
    }

    const value = matches.length > 1 ? Number.parseInt(matches[matches.length - 1], 10) : 0;
    return Promise.resolve(value);
}


const listCounters = () => {
    return counters;
}

const getCounter = (id) => {
    const [counter] = counters.filter(item => item?.name === id);
    return counter;
}

const createCounter = ({name, description, labelNames, value}) => {
    const newCounter = _createCounter({
        name, description, labelNames, value
    })

    register.registerMetric(newCounter);
    counters.push(newCounter);
    return newCounter;
}

const deleteCounter = async (id) => {
    const index = counters.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Counter with name ${id} does not exist.`)
    }

    register.removeSingleMetric(id);
    const [removedCounter] = counters.splice(index, 1);
    return Promise.resolve(removedCounter);
}

const incrementCounter = (id, labels = {}, value = 1) => {
    const index = counters.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Counter with name ${id} does not exist.`)
    }

    counters[index].labels(labels).inc(value);
    return counters[index];
}

module.exports = {
    listCounters,
    getCounter,
    createCounter,
    deleteCounter,
    incrementCounter,
    _getCounterValue,
}
// @ts-check

const { compact, filter } = require('lodash');

const counters = [];

const { promClient, register } = require('../prometheus');

const _createCounter = ({name, description, labels = {}, value}) => {
    const counter = new promClient.Counter({
        name: name,
        help: description,
        labelNames: Object.keys(labels),
    });

    if (value) {
        counter.inc(value);
    }

    return counter;
}

const _getCounterValue = async (name, labelFilter = {}) => {
    const metricValue = await register.getSingleMetricAsString(name);
    const metricValueLines = metricValue.split('\n');
    
    const result = metricValueLines.filter(value => !value.startsWith("#"));

    const returnValue = result.map(item => {
        const matches = item.match(/^(?<metricName>\w+){(?<labels>.+)}\s+(?<value>\d+)$/);
        if (matches === null) {
            return null;
        }

        return {
            labels: matches.groups?.labels.split(",").reduce((prev, curr) => {
                const [labelKey, labelValue] = curr.split('=');
                return {...prev, [labelKey]: labelValue.replace(/"/g, "")};
            }, {}),
            value: matches.groups?.value,
        }
    });

    
    return Promise.resolve(compact(filter(returnValue, {labels: labelFilter})))
}


const listCounters = () => {
    return counters;
}

const getCounter = (id) => {
    const [counter] = counters.filter(item => item?.name === id);
    return counter;
}

const createCounter = ({name, description, labels, value}) => {
    const newCounter = _createCounter({
        name, description, labels, value
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
// @ts-check

const { matches, compact, filter, isEmpty } = require('lodash');

const gauges = [];

const { promClient, register } = require('../prometheus');

const _createGauge = ({name, description, labels = {}, value}) => {

    const gauge = new promClient.Gauge({
        name: name,
        help: description,
        labelNames: Object.keys(labels),
    });

    if (value) {
        gauge.set(value);
    }

    return gauge;
}

const _getGaugeValue = async (name, labelFilter = {}) => {
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


const listGauges = () => {
    return gauges;
}

const getGauge = (id) => {
    const [gauge] = gauges.filter(item => item?.name === id);
    return gauge;
}

const createGauge = ({name, description, labels, value}) => {
    const gauge = _createGauge({
        name, description, labels, value
    })

    register.registerMetric(gauge);
    gauges.push(gauge);
    return gauge;
}

const deleteGauge = async (id) => {
    const index = gauges.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Gauge with name ${id} does not exist.`)
    }

    register.removeSingleMetric(id);
    const [removed] = gauges.splice(index, 1);
    return Promise.resolve(removed);
}

const incrementGauge = (id, labels = {}, value = 1) => {
    const index = gauges.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Gauge with name ${id} does not exist.`)
    }

    gauges[index].labels(labels).inc(value);
    return gauges[index];
}

const decrementGauge = (id, labels = {}, value = 1) => {
    const index = gauges.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Gauge with name ${id} does not exist.`)
    }

    gauges[index].labels(labels).dec(value);
    return gauges[index];
}

const setGauge = (id, labels = {}, value = 1) => {
    const index = gauges.findIndex(item => item?.name === id);
    if (index < 0) {
        throw new Error(`Gauge with name ${id} does not exist.`)
    }

    gauges[index].labels(labels).set(value);
    return gauges[index];
}

module.exports = {
    listGauges,
    getGauge,
    createGauge,
    deleteGauge,
    incrementGauge,
    decrementGauge,
    setGauge,
    _getGaugeValue,
}

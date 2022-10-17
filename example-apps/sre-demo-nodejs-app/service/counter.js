const counterDAO = require('../data/counterDAO');

const listCounters = async () => {
    const listOfCounters = counterDAO.listCounters();

    console.log({listCounters: {counterValue}})
    return Promise.all(listOfCounters.map(async item => ({
        name: item.name,
        value: await counterDAO._getCounterValue(item.name),
    })));
}

const getCounter = async (id) => {
    const counter = counterDAO.getCounter(id);
    return Promise.resolve({
        name: counter.name,
        value: await counterDAO._getCounterValue(counter.name)
    });
}

const createCounter = ({name, description, labelNames = [], value}) => {
    counterDAO.createCounter({
        name,
        description,
        labelNames,
        value,
    });

    return {
        name,
        description,
        labelNames,
        value,
    }
}

const deleteCounter = async (id) => {
    const counter = await getCounter(id);
    await counterDAO.deleteCounter(id);
    return Promise.resolve(counter);
}

const incrementCounter = async (id, labels = {}, value = 1) => {
    const counter = counterDAO.incrementCounter(id, labels, value)

    const labelKeys = Object.keys(labels);
    const searchString = labelKeys.reduce((prev, curr) => {
        return prev += `${curr}="${labels[curr]}"`
    }, "");

    console.log({searchString});



    const counterValue = await counterDAO._getCounterValue(counter.name, searchString);
    console.log({counter, counterValue})
    return  Promise.resolve({
        name: counter.name,
        value: counterValue,
    });
}

module.exports = {
    listCounters,
    getCounter,
    createCounter,
    deleteCounter,
    incrementCounter,
}
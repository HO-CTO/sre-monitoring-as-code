const promClient = require('prom-client');
const express = require('express');

const register = new promClient.Registry();
const promClientRoute = new express.Router();

promClientRoute.get('/', async (req, res) => {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
});

// Add a default label which is added to all metrics
register.setDefaultLabels({
    app: 'demo',
    team: "sre",
});

promClient.collectDefaultMetrics({
    register,
});

module.exports = {
    promClient,
    promClientRoute,
    register,
}
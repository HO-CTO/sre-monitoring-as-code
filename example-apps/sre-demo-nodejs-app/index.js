const express = require('express');
const promBundle = require('express-prom-bundle');
const cors = require('cors')

const promClient = require('prom-client');

const PORT = process.env.PORT || 4001;
const app = express();

app.use(express.json());
app.use(cors());

// Create a Registry which registers the metrics
const register = new promClient.Registry();

const expressPromMiddleware = promBundle({
    includeMethod: true,
    includePath: true,
    includeStatusCode: true,
    promCLient: promClient,
    promRegistry: register
});
app.use(expressPromMiddleware);

// Add a default label which is added to all metrics
register.setDefaultLabels({
    app: 'demo',
    team: "sre",
});

promClient.collectDefaultMetrics({
    register,
})

const metricName = "simple_counter_total";

const counter = new promClient.Counter({
    name: metricName,
    help: 'A demo counter metric',
    labelNames: [
    "status"
    ],
});

register.registerMetric(counter);

const getCounterValue = async (name, label) => {
    const metricValue = await register.getSingleMetricAsString(name);
    const result = metricValue.split('\n').filter(value => value.includes(label));

    if (result.length === 0) {
        return Promise.resolve(0);
    }

    const matches = result[0].match(/(\d+)$/);
    const value = matches.length > 1 ? Number.parseInt(matches[matches.length - 1], 10) : 0;
    return Promise.resolve(value);
}

const getLastSuccessValue = async () => {
    return getCounterValue(metricName, "SUCCESS");
}

const getLastExceptionValue = async () => {
    return getCounterValue(metricName, "EXCEPTION");
}

async function getCounterValues() {
    const good = await getLastSuccessValue();
    const bad = await getLastExceptionValue();
    const total = good + bad;
    return Promise.resolve({
        good, bad, total
    })
}

app.get('/metrics', async (req, res) => {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
});

app.get('/values', async(req, res) => {
    const values = await getCounterValues(res);
    res.json(values)
    
});

app.get('/version', async(req, res) => {
    res.json({
        runtime: process.title,
        version: process.version,
    }
    )
    
});

app.post('/success', async (req, res) => {
    const inc = Number.parseFloat(req.body.amount);
    counter.labels({ status: "SUCCESS" }).inc(inc);
    const values = await getCounterValues();
    res.json(values)
});

app.post('/exception', async (req, res) => {
    const inc = Number.parseFloat(req.body.amount);
    counter.labels({ status: "EXCEPTION" }).inc(inc);
    const values = await getCounterValues();
    res.json(values)
});

app.listen(PORT, () => {
    console.log(`sre-demo-nodejs-app listening on port: http://localhost:${PORT}`);
});
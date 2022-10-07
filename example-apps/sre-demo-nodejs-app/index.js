const express = require('express');
const bodyParser = require('body-parser');
const promBundle = require('express-prom-bundle');

const nunjucks = require('nunjucks');
const promClient = require('prom-client');

const PORT = 8081;
const app = express();

app.use(bodyParser.urlencoded({extended: true}));

nunjucks.configure('views', {
    autoescape: true,
    express: app
});

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
    ]
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

app.get('/metrics', async (req, res) => {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
});

app.get('/', async (req, res) => {
    const good = await getLastSuccessValue();
    const bad = await getLastExceptionValue();
    const total = good + bad;
    res.render('index.html', {successful: good, exceptions: bad, total});
});

app.post('/success', (req, res) => {
    const inc = Number.parseFloat(req.body.amount);
    counter.labels({ status: "SUCCESS" }).inc(inc);
    res.redirect('/');
});

app.post('/exception', (req, res) => {
    const inc = Number.parseFloat(req.body.amount);
    counter.labels({ status: "EXCEPTION" }).inc(inc);
    res.redirect('/');
});

app.listen(PORT, () => {
    console.log(`sre-demo-nodejs-app listening on port: http://localhost:${PORT}`);
});

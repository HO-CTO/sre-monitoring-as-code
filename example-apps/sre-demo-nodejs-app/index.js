const express = require('express');
const promBundle = require('express-prom-bundle');
const cors = require('cors')

const { promClient, register, promClientRoute } = require('./prometheus')

const PORT = process.env.PORT || 4001;
const app = express();

app.use(express.json());
app.use(cors());

const expressPromMiddleware = promBundle({
    includeMethod: true,
    includePath: true,
    includeStatusCode: true,
    promCLient: promClient,
    promRegistry: register
});
app.use(expressPromMiddleware);

const countersRoute = require('./routes/counter');

app.use('/counters', countersRoute);
app.use('/metrics', promClientRoute);
app.get('/version', async(req, res) => {
    res.json({
        runtime: process.title,
        version: process.version,
    })
});

app.listen(PORT, () => {
    console.log(`sre-demo-nodejs-app listening on port: http://localhost:${PORT}`);
});

async function getCounterValues() {
    const good = await getLastSuccessValue();
    const bad = await getLastExceptionValue();
    const total = good + bad;
    return Promise.resolve({
        good, bad, total
    })
}

const express = require('express')
const router = express.Router()

const counterService = require("../service/counter");

router.get('/', async (req, res) => {
    const result = await counterService.listCounters();
    res.json(result);
});

// /counters/:id
router.get("/:id", async (req, res) => {
    const {id} = req.params;
    const result = await counterService.getCounter(id);
    res.json(result)
});

router.post('/', (req, res) => {
    // Create the new counter
    // return it
    const result = counterService.createCounter(req.body);
    res.status(201).json(result);
});

router.delete('/:id', async (req, res) => {
    // Delete the counter
    // return it
    const {id} = req.params;
    const result = await counterService.deleteCounter(id);
    res.status(202).json(result);
});

router.post('/:id/increment', async (req, res) => {
    // Increment the counter
    // return the new value
    const {id} = req.params;
    const { labels, value } = req.body;
    const result = await counterService.incrementCounter(id, labels, value);
    res.json(result);
})

module.exports = router;

// const metricName = "simple_counter_total";

// const counter = new promClient.Counter({
//     name: metricName,
//     help: 'A demo counter metric',
//     labelNames: [
//     "status"
//     ]
// });

// register.registerMetric(counter);

// app.post('/success', async (req, res) => {
//     const inc = Number.parseFloat(req.body.amount);
//     counter.labels({ status: "SUCCESS" }).inc(inc);
//     const values = await getCounterValues();
//     res.json(values)
// });

// app.post('/exception', async (req, res) => {
//     const inc = Number.parseFloat(req.body.amount);
//     counter.labels({ status: "EXCEPTION" }).inc(inc);
//     const values = await getCounterValues();
//     res.json(values)
// });



// const getLastSuccessValue = async () => {
//     return getCounterValue(metricName, "SUCCESS");
// }

// const getLastExceptionValue = async () => {
//     return getCounterValue(metricName, "EXCEPTION");
// }

// async function getCounterValues() {
//     const good = await getLastSuccessValue();
//     const bad = await getLastExceptionValue();
//     const total = good + bad;
//     return Promise.resolve({
//         good, bad, total
//     })
// }
const express = require('express')
const router = express.Router()

const gaugeService = require("../service/gauge");

router.get('/', async (req, res) => {
    const result = await gaugeService.listGauges();
    res.json(result);
});

router.get("/:id", async (req, res) => {
    const {id} = req.params;
    const result = await gaugeService.getGauge(id);
    res.json(result)
});

router.post('/', (req, res) => {
    const result = gaugeService.createGauge(req.body);
    res.status(201).json(result);
});

router.delete('/:id', async (req, res) => {
    const {id} = req.params;
    const result = await gaugeService.deleteGauge(id);
    res.status(202).json(result);
});

router.post('/:id/increment', async (req, res) => {
    const {id} = req.params;
    const { labels, value } = req.body;
    const result = await gaugeService.incrementGauge(id, labels, value);
    res.json(result);
})

router.post('/:id/decrement', async (req, res) => {
    const {id} = req.params;
    const { labels, value } = req.body;
    const result = await gaugeService.decrementGauge(id, labels, value);
    res.json(result);
})

router.put('/:id', async (req, res) => {
    const {id} = req.params;
    const { labels, value } = req.body;
    const result = await gaugeService.setGauge(id, labels, value);
    res.json(result);
})

module.exports = router;

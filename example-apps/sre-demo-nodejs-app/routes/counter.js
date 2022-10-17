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
    res.json(result);
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
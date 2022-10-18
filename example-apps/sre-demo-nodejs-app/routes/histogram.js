const express = require("express");
const router = express.Router();

const histogramService = require("../service/histogram");

router.get("/", async (req, res) => {
  const result = await histogramService.listHistograms();
  res.json(result);
});

router.get("/:id", async (req, res) => {
  const { id } = req.params;
  const result = await histogramService.getHistogram(id);
  res.json(result);
});

router.post("/", (req, res) => {
  const result = histogramService.createHistogram(req.body);
  res.status(201).json(result);
});

router.delete("/:id", async (req, res) => {
  const { id } = req.params;
  const result = await histogramService.deleteHistogram(id);
  res.status(202).json(result);
});

router.post("/:id/observe", async (req, res) => {
  const { id } = req.params;
  const { labels, value } = req.body;
  const result = await histogramService.observe(id, labels, value);
  res.json(result);
});

module.exports = router;

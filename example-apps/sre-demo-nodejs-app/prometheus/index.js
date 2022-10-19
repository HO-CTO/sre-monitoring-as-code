const promClient = require("prom-client");
const express = require("express");

const register = new promClient.Registry();
const promClientRoute = new express.Router();

promClientRoute.get("/", async (req, res) => {
  res.setHeader("Content-Type", register.contentType);
  res.send(await register.metrics());
});

const defaultLabels = {
  app: "demo",
  team: "sre",
};

// Add a default label which is added to all metrics
register.setDefaultLabels(defaultLabels);

promClient.collectDefaultMetrics({
  register,
});

module.exports = {
  promClient,
  promClientRoute,
  register,
  defaultLabelKeys: Object.keys(defaultLabels),
};

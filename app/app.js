const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send(
    `Hello from ${process.env.APP_ENV || "local"} | version ${process.env.APP_VERSION || "dev"}`
  );
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

module.exports = app;

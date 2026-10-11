const test = require("node:test");
const assert = require("node:assert");
const app = require("./app");

test("GET /health returns 200", async () => {
  const server = app.listen(0);
  const { port } = server.address();
  const res = await fetch(`http://127.0.0.1:${port}/health`);
  assert.strictEqual(res.status, 200);
  server.close();
});

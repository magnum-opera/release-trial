const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { greet } = require("./greeting");
const { counter } = require("./counter");

const fresh = () => counter(fs.mkdtempSync(path.join(os.tmpdir(), "greetings-")));

test("TC-2.2 A visitor with no name is asked for one", () => {
  assert.deepStrictEqual(greet("  ", fresh()), { status: 400, body: { error: "A name is required" } });
});

test("TC-4.2 A refused greeting is not counted", () => {
  const greetings = fresh();
  greet("Ada", greetings);
  greet("", greetings);
  assert.strictEqual(greet("Bo", greetings).body.count, 2);
});

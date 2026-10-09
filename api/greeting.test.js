const test = require("node:test");
const assert = require("node:assert");
const { greet } = require("./greeting");

test("TC-2.2 A visitor with no name is asked for one", () => {
  assert.deepStrictEqual(greet("  "), { status: 400, body: { error: "A name is required" } });
});

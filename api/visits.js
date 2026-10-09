const fs = require("node:fs");
const path = require("node:path");

// Visits by name, kept beside the count in the greetings file.
function visits(dir) {
  const file = path.join(dir, "greetings.json");
  return {
    record(name) {
      const trimmed = (name || "").trim();
      if (!trimmed) return { status: 400, body: { error: "A name is required" } };
      const data = JSON.parse(fs.readFileSync(file, "utf8"));
      data.byName[trimmed] = (data.byName[trimmed] || 0) + 1;
      fs.writeFileSync(file, JSON.stringify(data));
      return { status: 200, body: { name: trimmed, count: data.byName[trimmed] } };
    },
  };
}

module.exports = { visits };

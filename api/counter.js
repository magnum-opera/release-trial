const fs = require("node:fs");
const path = require("node:path");

// The count of greetings given, kept in DATA_DIR so it outlives a deployment.
function counter(dir) {
  const file = path.join(dir, "greetings.json");
  return {
    next() {
      const data = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : { count: 0 };
      data.count += 1;
      fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(file, JSON.stringify(data));
      return data.count;
    },
  };
}

module.exports = { counter };

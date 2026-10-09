const http = require("node:http");
const { greet } = require("./greeting");
const { counter } = require("./counter");

const greetings = counter(process.env.DATA_DIR || "/data");

function send(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    if (url.pathname === "/health") return send(res, 200, { ok: true });
    if (url.pathname === "/api/greeting") {
      try {
        const { status, body } = greet(url.searchParams.get("name"), greetings);
        return send(res, status, body);
      } catch (err) {
        console.error(err);
        return send(res, 500, { error: "Something went wrong" });
      }
    }
    send(res, 404, { error: "Not found" });
  })
  .listen(3000, () => console.log("api on 3000"));

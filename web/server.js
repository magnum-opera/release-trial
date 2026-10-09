const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

const API_URL = process.env.API_URL || "http://localhost:3000";
const page = fs.readFileSync(path.join(__dirname, "index.html"));

http
  .createServer(async (req, res) => {
    if (req.url === "/health") {
      res.writeHead(200, { "content-type": "application/json" });
      return res.end('{"ok":true}');
    }
    if (req.url.startsWith("/api/")) {
      try {
        const upstream = await fetch(API_URL + req.url);
        res.writeHead(upstream.status, { "content-type": "application/json" });
        return res.end(await upstream.text());
      } catch {
        res.writeHead(502, { "content-type": "application/json" });
        return res.end('{"error":"The greeting service is down"}');
      }
    }
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    res.end(page);
  })
  .listen(8080, () => console.log("web on 8080"));

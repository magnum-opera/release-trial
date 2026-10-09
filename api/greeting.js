function greet(name) {
  const trimmed = (name || "").trim();
  if (!trimmed) return { status: 400, body: { error: "A name is required" } };
  return { status: 200, body: { greeting: `Hello, ${trimmed}!` } };
}

module.exports = { greet };

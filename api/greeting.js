function greet(name, greetings) {
  const trimmed = (name || "").trim();
  if (!trimmed) return { status: 400, body: { error: "A name is required" } };
  return { status: 200, body: { greeting: `Hello, ${trimmed}!`, count: greetings.next() } };
}

module.exports = { greet };

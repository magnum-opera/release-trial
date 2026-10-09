import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  retries: 1,
  reporter: [["list"], ["json", { outputFile: "test-results/results.json" }]],
  use: { baseURL: process.env.BASE_URL, trace: "retain-on-failure" },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
});

import { test, expect } from "@playwright/test";

test("TC-4.1 The count of greetings is shown", { tag: ["@REQ-4.1", "@normal"] }, async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Name").fill("Ada");
  await page.getByRole("button", { name: "Greet" }).click();
  await expect(page.locator("#count")).toHaveText(/^Greetings given: [1-9]\d*$/);
});

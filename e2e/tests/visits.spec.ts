import { test, expect } from "@playwright/test";

test("TC-12.1 A visitor sees how often they have been greeted", { tag: ["@REQ-12.1", "@normal"] }, async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Name").fill("Ada");
  await page.getByRole("button", { name: "Greet" }).click();
  await expect(page.locator("#count")).toHaveText(/^Ada has been greeted [1-9]\d* times?$/);
});

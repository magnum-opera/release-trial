import { test, expect } from "@playwright/test";

test("TC-2.1 A visitor is greeted by name", { tag: ["@REQ-2.1", "@high"] }, async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Name").fill("Ada");
  await page.getByRole("button", { name: "Greet" }).click();
  await expect(page.getByRole("status")).toHaveText("Hello, Ada!");
});

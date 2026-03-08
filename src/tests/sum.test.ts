// import { expect, test } from 'vitest' // already available in global
import { sum } from "../index.js";

test("sum two numbers", () => {
  expect(sum(2, 3)).toBe(5);
});

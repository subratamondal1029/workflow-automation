import { greet } from "../index.js";

test("greet function works correctly", () => {
  const name = "Alice";
  expect(greet(name)).toBe(`Hello, ${name}!`);
});

import { execFile } from "child_process";

const sum = (a: number, b: number): number => {
  return a + b;
};

const sub = (a: number, b: number): number => {
  return a - b;
};

// test codeql dot in github
function echo(userInput: string) {
  execFile("echo", [userInput]);
}

const getData = () => {
  return fetch("https://jsonplaceholder.typicode.com/posts/", {
    headers: {
      "x-api-key": process.env.API_KEY || "",
    },
  });
};
export { sum, sub, getData, echo };

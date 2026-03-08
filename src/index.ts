import { execFile } from "child_process";

const sum = (a: number, b: number): number => {
  return a + b;
};

const sub = (a: number, b: number): number => {
  return a - b;
};

// test CodeRabbit
const getData = () => {
  fetch("https://jsonplaceholder.typicode.com/todos/", {
    headers: {
      "x-api-key": "f651e791e9d8e92e",
    },
  });
};

// test codeql dot in github
function echo(userInput: string) {
  execFile("echo", [userInput]);
}

const getData2 = () => {
  fetch("https://jsonplaceholder.typicode.com/posts/", {
    headers: {
      "x-api-key": "f651e791e9d8e92eqwewq",
    },
  });
};

export { sum, sub, getData, getData2, echo };

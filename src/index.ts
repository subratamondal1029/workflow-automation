import { exec } from "child_process";

const sum = (a: number, b: number): number => {
  return a + b;
};

const sub = (a: number, b: number): number => {
  return a - b;
};

const getData = () => {
  fetch("https://jsonplaceholder.typicode.com/todos/", {
    headers: {
      "x-api-key": "f651e791e9d8e92e",
    },
  });
};

// test codeql dot in github
function echo(userInput: string) {
  exec("echo " + userInput);
}

export { sum, sub, getData, echo };

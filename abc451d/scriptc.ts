import { Main } from "./_base.ts";
//@ts-ignore
import { readFileSync } from "node:fs";
Main(readFileSync("/dev/stdin", "utf8"));
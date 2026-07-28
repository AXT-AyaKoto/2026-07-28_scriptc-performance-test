import { Main } from "./_base.ts";
//@ts-ignore
Main(await Bun.file("/dev/stdin").text());
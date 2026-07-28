import { Main } from "./_base.ts";
//@ts-ignore
Main(await Deno.readTextFile("/dev/stdin"));
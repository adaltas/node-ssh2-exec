import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts", "src/promises.ts"],
  outDir: "dist",
  clean: true,
  format: ["esm", "cjs"],
  target: ["esnext", "esnext"],
  dts: true,
  minify: false,
  sourcemap: false,
  splitting: true,
});

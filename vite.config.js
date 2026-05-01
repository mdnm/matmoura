import { resolve } from "path"
import tailwindcss from "@tailwindcss/vite"
import { defineConfig } from "vite"

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
        company: resolve(__dirname, "company/index.html"),
        privacy: resolve(__dirname, "privacy/index.html"),
        terms: resolve(__dirname, "terms/index.html"),
        "ai-business": resolve(__dirname, "ai-business/index.html"),
        "ai-business-en": resolve(__dirname, "ai-business/en/index.html"),
      },
    },
  },
})
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
export default defineConfig({
  plugins:[react()],
  server:{
    port:5173,
    proxy:{
      "/api":{
        target:"http://localhost:8810",
        changeOrigin:true,
        rewrite:(path)=>path.replace(/^\/api/,"/Enterprise_Case_Management_System/web")
      }
    }
  }
});
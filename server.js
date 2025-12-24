import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import fs from "fs"; // Import fs for file system operations
import { fileURLToPath } from "url";
import https from "https";

// Define __dirname for ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, ".env") });

// Read environment variables
const { PORT = "3001" } = process.env;

// Validate index.html path
const indexHtmlPath = path.join(__dirname, "frontend", "public", "index.html");
if (!fs.existsSync(indexHtmlPath)) {
  throw new Error(`index.html not found at ${indexHtmlPath}`);
}
console.log("[DEBUG] index.html found at:", indexHtmlPath);

const app = express();
app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
  res.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
  next();
});

// Serve static files
app.use(express.static(path.join(__dirname, "frontend", "public")));

// Catch-all middleware to serve index.html (placed after API/proxy routes)
app.use((req, res) => {
  res.sendFile(indexHtmlPath);
});

// choose cert paths via env or default to ./certs
const SSL_KEY_PATH = process.env.SSL_KEY_PATH || path.join(__dirname, "certs", "localhost.key");
const SSL_CERT_PATH = process.env.SSL_CERT_PATH || path.join(__dirname, "certs", "localhost.crt");

const hasSsl = fs.existsSync(SSL_KEY_PATH) && fs.existsSync(SSL_CERT_PATH);

if (hasSsl) {
  const key = fs.readFileSync(SSL_KEY_PATH);
  const cert = fs.readFileSync(SSL_CERT_PATH);
  https
    .createServer({ key, cert }, app)
    .listen(Number(PORT), () => console.log(`🚀 HTTPS server listening on https://localhost:${PORT}`));
} else {
  app.listen(Number(PORT), () => console.log(`🚀 HTTP server listening on http://localhost:${PORT}`));
}

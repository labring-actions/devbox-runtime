const fs = require("fs");
const os = require("os");
const path = require("path");

const homeDir = process.env.HOME || os.homedir();
const configDir = process.env.CLAWDBOT_CONFIG_DIR || path.join(homeDir, ".clawdbot", "devices");
const pendingPath = path.join(configDir, "pending.json");
const pairedPath = path.join(configDir, "paired.json");

let isProcessing = false;

function autoApprove() {
  if (isProcessing) return;
  isProcessing = true;

  try {
    if (!fs.existsSync(pendingPath)) {
      isProcessing = false;
      return;
    }

    const pending = JSON.parse(fs.readFileSync(pendingPath, "utf8"));
    if (Object.keys(pending).length === 0) {
      isProcessing = false;
      return;
    }

    const paired = fs.existsSync(pairedPath) ? JSON.parse(fs.readFileSync(pairedPath, "utf8")) : {};

    for (const [id, device] of Object.entries(pending)) {
      paired[id] = device;
      console.log("[auto-approve] Approved device:", id);
    }

    fs.writeFileSync(pairedPath, JSON.stringify(paired, null, 2));
    fs.writeFileSync(pendingPath, "{}");
  } catch (e) {
    console.error("[auto-approve] Error:", e.message);
  }

  isProcessing = false;
}

// Ensure config dir exists
if (!fs.existsSync(configDir)) {
  fs.mkdirSync(configDir, { recursive: true });
}

// Initial approval on startup
setTimeout(autoApprove, 2000);

// Watch for changes with fast polling (500ms)
setInterval(autoApprove, 500);

// Also watch for file system changes (instant)
if (fs.existsSync(configDir)) {
  fs.watch(configDir, { persistent: true }, (eventType, filename) => {
    if (filename === "pending.json") {
      setTimeout(autoApprove, 100);
    }
  });
}

console.log("[auto-approve] Started auto-approve service (instant mode)");

# Etsy-App-Dev

Purpose
- Workspace for developing an Etsy app / integration. Use this folder to keep prototype code, API experiments, and deployment notes separate from the PowerShell utilities in the repository root.

Suggested structure
- src/        # application source (backend/frontend)
- docs/       # design notes, API keys handling guidance (do not commit secrets)
- scripts/    # local helpers, deployment scripts

Getting started
1. Pick a stack (Node/Express, Python/Flask, or other) and create the app under `src/`.
2. Keep secrets out of the repo; use environment variables or an encrypted store.

Example commands (adjust for your chosen stack)

```bash
# create a Node app
cd "Etsy-App-Dev/src"
npm init -y
# or a Python virtualenv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Notes
- This scaffold is intentionally minimal — add README sections as you decide on architecture and tools.

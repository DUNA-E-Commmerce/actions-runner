#!/bin/bash

echo "🏃 GitHub Actions Runner Startup Script"
echo "======================================="

# Check if runner is configured
if [ ! -f ".runner" ]; then
    echo "⚠️  Runner not configured yet."
    echo "💡 To configure the runner, you need to:"
    echo "   1. Get a registration token from GitHub"
    echo "   2. Run: ./config.sh --url <your-repo-url> --token <your-token>"
    echo ""
    echo "🔧 For now, keeping container alive for configuration..."
    tail -f /dev/null
else
    echo "✅ Runner is configured. Starting..."
    ./run.sh
fi
#!/bin/bash

# Install Additional Dependencies for Raujan Pool Frontend
# This script installs all necessary dependencies that are not included in the template

echo "🚀 Installing additional dependencies for Raujan Pool Frontend..."
echo ""

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root directory."
    exit 1
fi

# Check if node_modules exists (to verify we're in the right directory)
if [ ! -d "node_modules" ]; then
    echo "⚠️  Warning: node_modules not found. Installing base dependencies first..."
    npm install
fi

echo "📦 Installing core dependencies..."
npm install axios react-hook-form @hookform/resolvers zod dayjs socket.io-client

echo "📦 Installing UI & Form dependencies..."
npm install react-dropzone react-image-crop react-big-calendar react-datepicker

echo "📦 Installing QR Code & Barcode dependencies..."
npm install qrcode react-qr-scanner react-barcode

echo "📦 Installing Data & State dependencies..."
npm install @tanstack/react-query lodash uuid

echo "📦 Installing development dependencies..."
npm install --save-dev @types/axios @types/react-hook-form @types/react-dropzone @types/react-big-calendar @types/react-datepicker @types/qrcode @types/react-barcode @types/lodash @types/uuid @tanstack/react-query-devtools

echo "📦 Installing testing dependencies..."
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom msw @testing-library/user-event

echo "📦 Installing development tools..."
npm install --save-dev vite-bundle-analyzer dotenv

echo ""
echo "✅ All dependencies installed successfully!"
echo ""
echo "📋 Summary of installed packages:"
echo "   • Core: axios, react-hook-form, zod, dayjs, socket.io-client"
echo "   • UI: react-dropzone, react-image-crop, react-big-calendar, react-datepicker"
echo "   • QR/Barcode: qrcode, react-qr-scanner, react-barcode"
echo "   • Data: @tanstack/react-query, lodash, uuid"
echo "   • Testing: vitest, @testing-library/*, msw"
echo "   • Dev Tools: vite-bundle-analyzer, dotenv, @tanstack/react-query-devtools"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure environment variables (see 03-environment-configuration.md)"
echo "   2. Setup state management (see 04-state-management.md)"
echo "   3. Start development: npm run dev"
echo ""
echo "📚 For detailed configuration, see:"
echo "   • 05-additional-dependencies.md - Detailed setup guide"
echo "   • 03-environment-configuration.md - Environment setup"
echo "   • 04-state-management.md - State management setup"
echo ""
echo "🎉 Ready to start building Raujan Pool Frontend!"

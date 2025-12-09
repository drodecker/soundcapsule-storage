#!/bin/bash

# SoundCapsule Storage - Development Setup Script
# This script sets up the development environment

set -e

echo "🚀 Setting up SoundCapsule Storage Development Environment..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 20+ first."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed."
    exit 1
fi

echo "✅ npm version: $(npm --version)"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your actual credentials before starting the service!"
    echo ""
else
    echo "✅ .env file already exists"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install
echo ""

# Generate Prisma Client
echo "🔧 Generating Prisma Client..."
npm run prisma:generate
echo ""

# Check if MySQL is accessible
echo "🗄️  Checking database connection..."
if grep -q "localhost:3306" .env; then
    echo "⚠️  Make sure MySQL is running on localhost:3306"
    echo "   You can use Docker: docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0"
fi
echo ""

# Run migrations (optional, may fail if DB not ready)
echo "📊 Would you like to run database migrations now? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Running migrations..."
    npm run prisma:migrate || echo "⚠️  Migration failed. Make sure MySQL is running and DATABASE_URL is correct."
else
    echo "⏭️  Skipping migrations. Run 'npm run prisma:migrate' later."
fi
echo ""

# Build the project
echo "🏗️  Building the project..."
npm run build
echo ""

echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update .env with your S3 credentials and database URL"
echo "   2. Start MySQL if not already running"
echo "   3. Run migrations: npm run prisma:migrate"
echo "   4. Start the dev server: npm run start:dev"
echo ""
echo "🌐 The service will be available at http://localhost:4002"
echo ""
echo "📚 Documentation:"
echo "   - README.md - General overview and API documentation"
echo "   - DEPLOYMENT.md - Production deployment guide"
echo "   - API_TESTING.md - API testing examples with cURL"

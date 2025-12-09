# SoundCapsule Storage - Development Setup Script (Windows)
# Run this in PowerShell

Write-Host "🚀 Setting up SoundCapsule Storage Development Environment..." -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 20+ first." -ForegroundColor Red
    exit 1
}

# Check if npm is installed
try {
    $npmVersion = npm --version
    Write-Host "✅ npm version: $npmVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ npm is not installed." -ForegroundColor Red
    exit 1
}

# Check if .env exists
if (-Not (Test-Path .env)) {
    Write-Host "📝 Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "⚠️  Please update .env with your actual credentials before starting the service!" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
npm install
Write-Host ""

# Generate Prisma Client
Write-Host "🔧 Generating Prisma Client..." -ForegroundColor Cyan
npm run prisma:generate
Write-Host ""

# Check if MySQL is accessible
Write-Host "🗄️  Checking database connection..." -ForegroundColor Cyan
$envContent = Get-Content .env -Raw
if ($envContent -match "localhost:3306") {
    Write-Host "⚠️  Make sure MySQL is running on localhost:3306" -ForegroundColor Yellow
    Write-Host "   You can use Docker: docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0" -ForegroundColor Gray
}
Write-Host ""

# Run migrations (optional)
Write-Host "📊 Would you like to run database migrations now? (Y/N)" -ForegroundColor Cyan
$response = Read-Host
if ($response -eq "Y" -or $response -eq "y") {
    Write-Host "Running migrations..." -ForegroundColor Cyan
    try {
        npm run prisma:migrate
    } catch {
        Write-Host "⚠️  Migration failed. Make sure MySQL is running and DATABASE_URL is correct." -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️  Skipping migrations. Run 'npm run prisma:migrate' later." -ForegroundColor Gray
}
Write-Host ""

# Build the project
Write-Host "🏗️  Building the project..." -ForegroundColor Cyan
npm run build
Write-Host ""

Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Update .env with your S3 credentials and database URL"
Write-Host "   2. Start MySQL if not already running"
Write-Host "   3. Run migrations: npm run prisma:migrate"
Write-Host "   4. Start the dev server: npm run start:dev"
Write-Host ""
Write-Host "🌐 The service will be available at http://localhost:4002" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   - README.md - General overview and API documentation"
Write-Host "   - DEPLOYMENT.md - Production deployment guide"
Write-Host "   - API_TESTING.md - API testing examples with cURL"

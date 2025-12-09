# 🎯 Quick Reference - SoundCapsule Storage

## 📁 Documentation Guide

| File | Purpose | When to Use |
|------|---------|-------------|
| **README.md** | Main documentation, features, setup, API overview | Start here for general overview |
| **PROJECT_SUMMARY.md** | Complete project summary, what's included | Review completed implementation |
| **ARCHITECTURE.md** | System architecture, diagrams, flows | Understand how components work together |
| **DEPLOYMENT.md** | Production deployment guide, AWS setup | When deploying to production |
| **DEPLOYMENT_CHECKLIST.md** | Step-by-step deployment verification | Follow before and after deployment |
| **API_TESTING.md** | cURL examples, Postman collection | Test API endpoints |
| **CONTRIBUTING.md** | Development workflow, code style | When contributing code |

## 🚀 Quick Start Commands

### First Time Setup
```powershell
# Run the setup script
.\setup.ps1

# OR manually:
npm install
npm run prisma:generate
cp .env.example .env
# Edit .env with your credentials
npm run prisma:migrate
npm run build
```

### Development
```powershell
# Start dev server (hot reload)
npm run start:dev

# Run tests
npm test

# Format code
npm run format

# Lint code
npm run lint
```

### Docker
```powershell
# Development (with hot reload)
docker-compose -f docker-compose.dev.yml up

# Production
docker-compose up -d

# View logs
docker-compose logs -f storage

# Stop services
docker-compose down
```

### Database
```powershell
# Generate Prisma Client
npm run prisma:generate

# Create migration
npm run prisma:migrate

# Deploy migrations (production)
npm run prisma:deploy

# Open Prisma Studio (DB GUI)
npm run prisma:studio
```

## 📡 API Endpoints

All endpoints require `Authorization: Bearer YOUR_JWT_TOKEN`

### Generate Upload URL
```bash
POST /v1/files/upload-url
{
  "fileName": "recording.m4a",
  "contentType": "audio/m4a",
  "durationSeconds": 180
}
```

### Get Playback URL
```bash
GET /v1/files/playback-url/:fileKey?expiresHours=24
```

### Get File Metadata
```bash
GET /v1/files/:fileKey/metadata
```

## 🔑 Environment Variables

### Required
```env
DATABASE_URL="mysql://user:password@host:3306/soundcapsule_storage"
S3_BUCKET=soundcapsule-audio
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
```

### Optional
```env
PORT=4002
S3_REGION=us-east-1
S3_ENDPOINT=                    # For DigitalOcean Spaces
JWKS_URI=https://auth.soundcapsule.com/.well-known/jwks.json
JWT_ISSUER=https://auth.soundcapsule.com
JWT_AUDIENCE=soundcapsule
UPLOAD_URL_EXPIRES_IN=900
MAX_PLAYBACK_HOURS=168
```

## 🐛 Common Issues

### Port Already in Use
```powershell
# Find process using port 4002
netstat -ano | findstr :4002
# Kill the process
taskkill /PID <process_id> /F
```

### Database Connection Failed
```powershell
# Check if MySQL is running
docker ps | findstr mysql
# Start MySQL with Docker
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0
```

### Build Errors
```powershell
# Clean install
Remove-Item -Recurse -Force node_modules, dist
npm install
npm run build
```

### Prisma Client Not Generated
```powershell
npm run prisma:generate
```

## 📊 Project Structure

```
soundcapsule-storage/
├── src/
│   ├── auth/           # JWT authentication
│   ├── files/          # File management (main feature)
│   ├── prisma/         # Database connection
│   ├── app.module.ts   # Root module
│   └── main.ts         # Entry point
├── prisma/
│   ├── schema.prisma   # Database schema
│   └── migrations/     # Migration files
├── test/               # E2E tests
└── dist/               # Compiled output
```

## 🔗 Useful Links

- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [AWS S3 SDK Documentation](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-s3/)
- [JWT.io](https://jwt.io/) - Debug JWT tokens
- [JWKS.guru](https://jwks.guru/) - Test JWKS endpoints

## 📞 Getting Help

1. Check existing documentation files
2. Review error messages in logs
3. Search GitHub issues
4. Ask in team chat/Slack
5. Open a GitHub issue with details

## 🎓 Learning Resources

- **NestJS**: Start with `src/main.ts` → `app.module.ts` → feature modules
- **Prisma**: Check `prisma/schema.prisma` and `src/prisma/`
- **JWT Auth**: Review `src/auth/` directory
- **S3 Operations**: See `src/files/s3.service.ts`
- **API Flow**: Follow `files.controller.ts` → `files.service.ts` → `s3.service.ts`

---

**Need help?** See full documentation in README.md or open an issue on GitHub.

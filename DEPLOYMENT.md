# Deployment Guide - SoundCapsule Storage

## Quick Start (Development)

1. **Clone and setup environment:**
```bash
git clone <repository-url>
cd soundcapsule-storage
cp .env.example .env
```

2. **Update `.env` file with your values:**
```env
DATABASE_URL="mysql://user:password@localhost:3306/soundcapsule_storage"
S3_BUCKET=your-bucket-name
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
```

3. **Install dependencies:**
```bash
npm install
```

4. **Generate Prisma Client:**
```bash
npm run prisma:generate
```

5. **Run database migrations:**
```bash
npm run prisma:migrate
```

6. **Start development server:**
```bash
npm run start:dev
```

The service will be available at http://localhost:4002

## Docker Deployment

### Build and Run

```bash
# Build the image
docker build -t soundcapsule-storage .

# Run with docker-compose (includes MySQL + Traefik)
docker-compose up -d

# View logs
docker-compose logs -f storage

# Stop services
docker-compose down
```

The service will be available at http://storage.localhost via Traefik.

### Environment Variables for Docker Compose

Create a `.env` file in the project root with your S3 credentials:

```env
S3_BUCKET=soundcapsule-audio
S3_REGION=us-east-1
S3_ENDPOINT=
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
```

## Production Deployment

### Prerequisites

1. **Database:** MySQL 8.0 instance
2. **Storage:** AWS S3 bucket or DigitalOcean Space
3. **Auth Service:** Running auth.soundcapsule.com with JWKS endpoint

### Steps

1. **Database Migration:**
```bash
# Set DATABASE_URL environment variable
export DATABASE_URL="mysql://user:pass@host:3306/db_name"

# Run migrations
npm run prisma:deploy
```

2. **Build application:**
```bash
npm run build
```

3. **Start production server:**
```bash
NODE_ENV=production npm run start:prod
```

### AWS S3 Setup

1. **Create S3 Bucket:**
   - Name: `soundcapsule-audio`
   - Region: `us-east-1` (or your preferred region)
   - Block all public access: ✅ Enabled
   - Enable versioning: Optional

2. **Create IAM User:**
   - Create user with programmatic access
   - Attach policy (see IAM Policy below)
   - Save Access Key ID and Secret Access Key

3. **IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:HeadObject"
      ],
      "Resource": "arn:aws:s3:::soundcapsule-audio/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::soundcapsule-audio"
    }
  ]
}
```

4. **CORS Configuration (Optional):**
If you need browser-based uploads:
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT"],
    "AllowedOrigins": ["https://soundcapsule.com"],
    "ExposeHeaders": ["ETag"]
  }
]
```

### DigitalOcean Spaces Setup

1. **Create Space:**
   - Name: `soundcapsule-audio`
   - Region: `nyc3` (or preferred)
   - CDN: Optional

2. **Generate Access Keys:**
   - Go to API → Spaces Keys
   - Create new key pair

3. **Environment Variables:**
```env
S3_BUCKET=soundcapsule-audio
S3_REGION=nyc3
S3_ENDPOINT=https://nyc3.digitaloceanspaces.com
AWS_ACCESS_KEY_ID=your_spaces_key
AWS_SECRET_ACCESS_KEY=your_spaces_secret
```

## Health Check

```bash
# Check if service is running
curl http://localhost:4002/

# Test authentication (requires valid JWT)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:4002/v1/files/upload-url \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "test.m4a",
    "contentType": "audio/m4a",
    "durationSeconds": 60
  }'
```

## Monitoring

### Database Queries
```bash
# Open Prisma Studio
npm run prisma:studio
```

### Logs
```bash
# Docker
docker-compose logs -f storage

# PM2 (if using)
pm2 logs soundcapsule-storage
```

## Troubleshooting

### JWT Authentication Fails
- Verify JWKS_URI is accessible
- Check JWT_ISSUER and JWT_AUDIENCE match your auth service
- Ensure auth.soundcapsule.com is serving JWKS at /.well-known/jwks.json

### S3 Upload Fails
- Verify AWS credentials are correct
- Check IAM policy has required permissions
- For DigitalOcean Spaces, ensure S3_ENDPOINT is set
- Test credentials with AWS CLI: `aws s3 ls s3://your-bucket --profile your-profile`

### Database Connection Issues
- Verify DATABASE_URL format: `mysql://USER:PASSWORD@HOST:PORT/DATABASE`
- Check MySQL is running and accessible
- Ensure database exists: `CREATE DATABASE soundcapsule_storage;`
- Run migrations: `npm run prisma:deploy`

### Port Already in Use
```bash
# Change PORT in .env file
PORT=4003

# Or kill process on port 4002 (Windows)
netstat -ano | findstr :4002
taskkill /PID <process_id> /F
```

## Scaling Considerations

### Horizontal Scaling
- Service is stateless - can run multiple instances behind load balancer
- Use connection pooling for database (Prisma handles this)
- Consider CDN for S3 playback URLs

### Database Optimization
- Add indexes to FileAudit table for common queries
- Archive old audit logs periodically
- Use read replicas for analytics queries

### S3 Optimization
- Enable S3 Transfer Acceleration for faster uploads
- Use CloudFront for playback URLs (global CDN)
- Consider lifecycle policies for old files

## Security Checklist

- [ ] Environment variables stored securely (not in code)
- [ ] Database uses strong password
- [ ] S3 bucket has no public access
- [ ] IAM user has minimal required permissions
- [ ] JWT authentication properly configured
- [ ] HTTPS enabled in production (via reverse proxy)
- [ ] CORS configured for allowed origins only
- [ ] Rate limiting enabled (consider adding)
- [ ] Logs don't contain sensitive data
- [ ] Docker containers run as non-root user ✅

## Backup Strategy

### Database
```bash
# Backup
mysqldump -u user -p soundcapsule_storage > backup.sql

# Restore
mysql -u user -p soundcapsule_storage < backup.sql
```

### S3
- Enable versioning in S3 bucket
- Set up S3 lifecycle rules for archiving
- Consider cross-region replication for critical data

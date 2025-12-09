# 🚀 Deployment Checklist for SoundCapsule Storage

Use this checklist to ensure your deployment is ready for production.

## ✅ Pre-Deployment Checklist

### 📋 Configuration

- [ ] Copy `.env.example` to `.env`
- [ ] Set `DATABASE_URL` with production MySQL credentials
- [ ] Set `S3_BUCKET` name
- [ ] Set `S3_REGION` (or for DigitalOcean Spaces)
- [ ] Set `S3_ENDPOINT` (if using DigitalOcean Spaces)
- [ ] Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- [ ] Set `JWKS_URI` to your auth service
- [ ] Set `JWT_ISSUER` to match your auth service
- [ ] Set `JWT_AUDIENCE` to match your auth service
- [ ] Review `UPLOAD_URL_EXPIRES_IN` (default: 900 seconds)
- [ ] Review `MAX_PLAYBACK_HOURS` (default: 168 hours)

### 🗄️ Database Setup

- [ ] MySQL 8.0 server is running
- [ ] Database `soundcapsule_storage` created
- [ ] User has appropriate permissions (CREATE, SELECT, INSERT, UPDATE, DELETE)
- [ ] Run: `npm run prisma:generate`
- [ ] Run: `npm run prisma:deploy` (production migrations)
- [ ] Verify FileAudit table created with indexes

### 🪣 S3/Spaces Setup

- [ ] Bucket/Space created
- [ ] Bucket is PRIVATE (no public access)
- [ ] IAM user/access key created
- [ ] IAM policy applied with PutObject, GetObject, HeadObject permissions
- [ ] Test credentials with AWS CLI or API call
- [ ] (Optional) CORS configured for browser uploads
- [ ] (Optional) Lifecycle rules configured for old files

### 🔐 Authentication Setup

- [ ] Auth service (auth.soundcapsule.com) is running
- [ ] JWKS endpoint accessible: `https://auth.soundcapsule.com/.well-known/jwks.json`
- [ ] JWT tokens include `sub` (user ID) claim
- [ ] JWT tokens have correct `iss` (issuer)
- [ ] JWT tokens have correct `aud` (audience)
- [ ] Tokens signed with RS256 algorithm

### 🔧 Application Build

- [ ] Run: `npm install`
- [ ] Run: `npm run build`
- [ ] Build completes without errors
- [ ] Check `dist/` folder created

### 🐳 Docker (if deploying with Docker)

- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] Review `docker-compose.yml` settings
- [ ] Update environment variables in compose file
- [ ] Test build: `docker build -t soundcapsule-storage .`
- [ ] Image builds successfully

## 🚀 Deployment Steps

### Option 1: Docker Compose Deployment

```bash
# 1. Build and start services
docker-compose up -d

# 2. Check logs
docker-compose logs -f storage

# 3. Verify health
curl http://localhost:4002/

# 4. Test with JWT token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4002/v1/files/upload-url \
  -H "Content-Type: application/json" \
  -d '{"fileName":"test.m4a","contentType":"audio/m4a","durationSeconds":60}'
```

### Option 2: Direct Node.js Deployment

```bash
# 1. Install dependencies
npm install --production

# 2. Build application
npm run build

# 3. Run migrations
npm run prisma:deploy

# 4. Start service
NODE_ENV=production npm run start:prod
```

### Option 3: PM2 Deployment

```bash
# 1. Install PM2
npm install -g pm2

# 2. Start with PM2
pm2 start dist/main.js --name soundcapsule-storage

# 3. Save PM2 config
pm2 save

# 4. Set up auto-start
pm2 startup
```

## ✅ Post-Deployment Checklist

### 🧪 Functional Testing

- [ ] Service starts without errors
- [ ] Port 4002 is accessible
- [ ] Database connection successful (check logs)
- [ ] S3 connection successful

#### Test Upload Flow:
```bash
# 1. Request upload URL
TOKEN="your_jwt_token"
RESPONSE=$(curl -s -X POST http://localhost:4002/v1/files/upload-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fileName":"test.m4a","contentType":"audio/m4a","durationSeconds":60}')

# 2. Verify response contains uploadUrl and fileKey
echo $RESPONSE | jq .

# 3. Extract upload URL and test upload (optional)
UPLOAD_URL=$(echo $RESPONSE | jq -r .uploadUrl)
# Create a test file or use existing
curl -X PUT "$UPLOAD_URL" -H "Content-Type: audio/m4a" --upload-file test.m4a
```

#### Test Playback Flow:
```bash
# 1. Get file key from upload response
FILE_KEY=$(echo $RESPONSE | jq -r .fileKey)

# 2. Request playback URL
curl -X GET "http://localhost:4002/v1/files/playback-url/$FILE_KEY" \
  -H "Authorization: Bearer $TOKEN"

# 3. Verify response contains playbackUrl
```

#### Test Metadata:
```bash
# Get metadata
curl -X GET "http://localhost:4002/v1/files/$FILE_KEY/metadata" \
  -H "Authorization: Bearer $TOKEN"
```

- [ ] Upload URL generated successfully
- [ ] File uploaded to S3 successfully
- [ ] Playback URL generated successfully
- [ ] File downloadable from playback URL
- [ ] Metadata endpoint returns file info
- [ ] Audit entries created in database

### 🔒 Security Testing

- [ ] Requests without JWT token return 401
- [ ] Expired JWT tokens rejected
- [ ] Invalid JWT tokens rejected
- [ ] JWKS fetching works correctly
- [ ] Upload URLs expire after 15 minutes
- [ ] Playback URLs expire after configured time
- [ ] Invalid content types rejected
- [ ] File names sanitized (no path traversal)

### 📊 Database Verification

```sql
-- Check audit entries
SELECT * FROM file_audits ORDER BY createdAt DESC LIMIT 10;

-- Count entries by action
SELECT action, COUNT(*) FROM file_audits GROUP BY action;

-- Check indexes exist
SHOW INDEX FROM file_audits;
```

- [ ] FileAudit table accessible
- [ ] Audit entries being created
- [ ] Indexes present (userId, fileKey, createdAt)

### 🌐 Network & Connectivity

- [ ] Service accessible from expected networks
- [ ] Firewall rules configured (if applicable)
- [ ] Load balancer health check passing (if applicable)
- [ ] SSL/TLS certificate valid (if using HTTPS)
- [ ] CORS headers correct (if needed)

### 📈 Monitoring Setup

- [ ] Application logs accessible
- [ ] Error logging working
- [ ] Database connection pool monitoring
- [ ] Consider adding: APM (DataDog, New Relic, etc.)
- [ ] Consider adding: Error tracking (Sentry)
- [ ] Consider adding: Metrics (Prometheus)

### 🔄 Backup & Recovery

- [ ] Database backup strategy in place
- [ ] S3 versioning enabled (optional)
- [ ] Backup restoration tested
- [ ] Disaster recovery plan documented

## 🛡️ Production Hardening

### Security

- [ ] Change default passwords
- [ ] Use strong, unique secrets
- [ ] Enable HTTPS (via reverse proxy)
- [ ] Implement rate limiting (consider @nestjs/throttler)
- [ ] Set up WAF if using cloud provider
- [ ] Regular security updates scheduled
- [ ] Audit logs retained appropriately

### Performance

- [ ] Database connection pooling configured (✅ Prisma default)
- [ ] Database query performance reviewed
- [ ] Consider caching JWKS responses
- [ ] Consider CDN for playback URLs
- [ ] Set appropriate timeout values

### Reliability

- [ ] Health check endpoint (consider adding)
- [ ] Graceful shutdown configured (✅ implemented)
- [ ] Auto-restart on crash (PM2 or Docker restart policy)
- [ ] Resource limits set (Docker or system)
- [ ] Logging to persistent storage

## 📝 Documentation

- [ ] Update internal wiki/docs with deployment info
- [ ] Document environment variables
- [ ] Document backup procedures
- [ ] Document rollback procedures
- [ ] Create runbook for common issues
- [ ] Share API documentation with consumers

## 🚨 Incident Response

- [ ] On-call rotation established
- [ ] Alerting configured
- [ ] Incident response plan created
- [ ] Emergency contacts documented
- [ ] Rollback procedure tested

## 📊 Success Metrics

After deployment, monitor these metrics:

- [ ] Uptime > 99.9%
- [ ] API response time < 200ms (p95)
- [ ] Error rate < 0.1%
- [ ] Upload success rate > 99%
- [ ] Database connection pool healthy
- [ ] No memory leaks over 24 hours

## 🎉 Go-Live Checklist

- [ ] All above checklists completed
- [ ] Stakeholders notified
- [ ] Support team briefed
- [ ] Monitoring dashboards created
- [ ] Documentation published
- [ ] Go/No-Go meeting completed

---

## 🆘 Rollback Plan

If something goes wrong:

1. **Immediate actions:**
   ```bash
   # Stop the service
   docker-compose down
   # OR
   pm2 stop soundcapsule-storage
   ```

2. **Revert to previous version:**
   ```bash
   git checkout <previous-tag>
   npm install
   npm run build
   npm run start:prod
   ```

3. **Database rollback (if needed):**
   ```bash
   # Prisma doesn't support automatic rollbacks
   # You'll need to create a down migration manually
   ```

4. **Notify stakeholders**

5. **Investigate root cause**

---

## 📞 Support Contacts

- **Technical Lead:** [Name/Email]
- **DevOps:** [Name/Email]
- **Database Admin:** [Name/Email]
- **On-Call:** [Phone/Pager]

---

**Last Updated:** December 8, 2025  
**Version:** 1.0.0

# soundcapsule-storage

Storage container for SoundCapsule - Generates temporary signed URLs for direct-to-S3 audio uploads and secure playback.

## Features

- **Secure Upload URLs**: Generate pre-signed S3 URLs for direct audio file uploads
- **Playback URLs**: Create temporary signed URLs for secure audio playback
- **JWT Authentication**: Token validation via JWKS from auth.soundcapsule.com
- **Audit Logging**: Track all upload and playback URL requests in MySQL
- **S3 Compatible**: Works with AWS S3 and DigitalOcean Spaces
- **Production Ready**: Multi-stage Docker build, health checks, Traefik integration

## Tech Stack

- NestJS 11 + TypeScript
- MySQL 8.0 + Prisma ORM
- AWS SDK v3 (S3)
- JWT + JWKS-RSA authentication
- Docker + Docker Compose
- Traefik reverse proxy

## Getting Started

### Prerequisites

- Node.js 20+
- Docker & Docker Compose
- MySQL 8.0
- S3-compatible storage (AWS S3 or DigitalOcean Spaces)

### Installation

1. Clone the repository
2. Copy environment variables:

```bash
cp .env.example .env
```

3. Update `.env` with your configuration
4. Install dependencies:

```bash
npm install
```

5. Generate Prisma Client:

```bash
npm run prisma:generate
```

6. Run migrations:

```bash
npm run prisma:migrate
```

7. Start the application:

```bash
npm run start:dev
```

### Docker Deployment

```bash
docker-compose up -d
```

The service will be available at `http://storage.localhost` via Traefik.

## API Endpoints

All endpoints require JWT Bearer token authentication.

### POST /v1/files/upload-url

Generate a pre-signed URL for uploading audio files.

**Request:**
```json
{
  "fileName": "my-audio.m4a",
  "contentType": "audio/m4a",
  "durationSeconds": 180
}
```

**Response:**
```json
{
  "uploadUrl": "https://s3.amazonaws.com/...",
  "fileKey": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Upload the file:**
```bash
curl -X PUT "${uploadUrl}" \
  -H "Content-Type: audio/m4a" \
  --upload-file my-audio.m4a
```

### GET /v1/files/playback-url/:fileKey

Get a signed URL for playing back an audio file.

**Query Parameters:**
- `expiresHours` (optional): URL expiration in hours (1-168, default: 24)

**Response:**
```json
{
  "playbackUrl": "https://s3.amazonaws.com/...?signature=..."
}
```

### GET /v1/files/:fileKey/metadata

Get metadata about an uploaded file.

**Response:**
```json
{
  "fileKey": "550e8400-e29b-41d4-a716-446655440000",
  "size": 2458624,
  "contentType": "audio/m4a",
  "uploadedAt": "2024-03-15T10:30:00.000Z",
  "durationSeconds": 180,
  "fileName": "my-audio.m4a"
}
```

## AWS IAM Policy

Required IAM policy for S3 access:

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

## DigitalOcean Spaces Configuration

For DigitalOcean Spaces, set these environment variables:

```env
S3_BUCKET=your-space-name
S3_REGION=nyc3
S3_ENDPOINT=https://nyc3.digitaloceanspaces.com
AWS_ACCESS_KEY_ID=your_spaces_key
AWS_SECRET_ACCESS_KEY=your_spaces_secret
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 4002 |
| `DATABASE_URL` | MySQL connection string | - |
| `JWKS_URI` | JWKS endpoint for token validation | https://auth.soundcapsule.com/.well-known/jwks.json |
| `JWT_ISSUER` | Expected JWT issuer | https://auth.soundcapsule.com |
| `JWT_AUDIENCE` | Expected JWT audience | soundcapsule |
| `S3_BUCKET` | S3 bucket name | - |
| `S3_REGION` | S3 region | us-east-1 |
| `S3_ENDPOINT` | S3 endpoint (for non-AWS) | - |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | - |
| `UPLOAD_URL_EXPIRES_IN` | Upload URL expiration (seconds) | 900 |
| `MAX_PLAYBACK_HOURS` | Max playback URL expiration (hours) | 168 |

## Project Structure

```
soundcapsule-storage/
├── prisma/
│   ├── migrations/
│   └── schema.prisma
├── src/
│   ├── auth/
│   │   ├── decorators/
│   │   ├── guards/
│   │   ├── strategies/
│   │   └── auth.module.ts
│   ├── files/
│   │   ├── dto/
│   │   ├── files.controller.ts
│   │   ├── files.service.ts
│   │   ├── files.module.ts
│   │   └── s3.service.ts
│   ├── prisma/
│   │   ├── prisma.service.ts
│   │   └── prisma.module.ts
│   ├── app.module.ts
│   └── main.ts
├── .env.example
├── docker-compose.yml
├── Dockerfile
├── nest-cli.json
├── package.json
├── README.md
└── tsconfig.json
```

## Development

```bash
# Development mode
npm run start:dev

# Build
npm run build

# Production mode
npm run start:prod

# Run tests
npm test

# Prisma Studio (DB GUI)
npm run prisma:studio
```

## License

See [LICENSE.md](LICENSE.md)

## Support

For issues and questions, please open a GitHub issue.
Storage container for SoundCapsule
ok. let's publish
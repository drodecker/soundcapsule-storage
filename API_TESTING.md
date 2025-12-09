# API Testing Guide

This guide shows how to test the SoundCapsule Storage API endpoints using cURL or similar tools.

## Prerequisites

You need a valid JWT token from the auth.soundcapsule.com service. The token should:
- Have the correct issuer: `https://auth.soundcapsule.com`
- Have the correct audience: `soundcapsule`
- Be signed with RS256 algorithm
- Include a `sub` claim with the user ID

For testing purposes, you can use the auth service to get a token, or generate one locally if you have the private key.

## Base URL

- Development: `http://localhost:4002`
- Docker: `http://storage.localhost`
- Production: `https://storage.soundcapsule.com`

## Authentication

All requests require a Bearer token in the Authorization header:

```bash
Authorization: Bearer YOUR_JWT_TOKEN
```

## Endpoints

### 1. Create Upload URL

Generate a pre-signed S3 URL for uploading an audio file.

**Endpoint:** `POST /v1/files/upload-url`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "fileName": "my-recording.m4a",
  "contentType": "audio/m4a",
  "durationSeconds": 180
}
```

**Valid Content Types:**
- `audio/m4a`
- `audio/wav`
- `audio/mp4`

**cURL Example:**
```bash
curl -X POST http://localhost:4002/v1/files/upload-url \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording.m4a",
    "contentType": "audio/m4a",
    "durationSeconds": 180
  }'
```

**Success Response (200 OK):**
```json
{
  "uploadUrl": "https://s3.amazonaws.com/soundcapsule-audio/550e8400-e29b-41d4-a716-446655440000?X-Amz-Algorithm=AWS4-HMAC-SHA256&...",
  "fileKey": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Error Responses:**
```json
// 401 Unauthorized - No/Invalid token
{
  "statusCode": 401,
  "message": "Unauthorized"
}

// 400 Bad Request - Invalid input
{
  "statusCode": 400,
  "message": [
    "contentType must be one of: audio/m4a, audio/wav, audio/mp4"
  ],
  "error": "Bad Request"
}
```

---

### 2. Upload File to S3

After getting the upload URL, use it to upload your file directly to S3.

**Important:** This is a direct S3 request, NOT to your API.

**cURL Example:**
```bash
curl -X PUT "https://s3.amazonaws.com/soundcapsule-audio/..." \
  -H "Content-Type: audio/m4a" \
  --upload-file ./my-recording.m4a
```

**Success Response:** 200 OK (empty body)

---

### 3. Get Playback URL

Generate a pre-signed S3 URL for playing back an uploaded file.

**Endpoint:** `GET /v1/files/playback-url/:fileKey`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
```

**Query Parameters:**
- `expiresHours` (optional): Number of hours until URL expires (1-168, default: 24)

**cURL Example:**
```bash
# Default expiration (24 hours)
curl -X GET http://localhost:4002/v1/files/playback-url/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Custom expiration (48 hours)
curl -X GET "http://localhost:4002/v1/files/playback-url/550e8400-e29b-41d4-a716-446655440000?expiresHours=48" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Success Response (200 OK):**
```json
{
  "playbackUrl": "https://s3.amazonaws.com/soundcapsule-audio/550e8400-e29b-41d4-a716-446655440000?X-Amz-Algorithm=AWS4-HMAC-SHA256&..."
}
```

**Error Responses:**
```json
// 404 Not Found - File doesn't exist
{
  "statusCode": 404,
  "message": "File with key 550e8400-e29b-41d4-a716-446655440000 not found",
  "error": "Not Found"
}

// 401 Unauthorized
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

---

### 4. Get File Metadata

Retrieve metadata about an uploaded file.

**Endpoint:** `GET /v1/files/:fileKey/metadata`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
```

**cURL Example:**
```bash
curl -X GET http://localhost:4002/v1/files/550e8400-e29b-41d4-a716-446655440000/metadata \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Success Response (200 OK):**
```json
{
  "fileKey": "550e8400-e29b-41d4-a716-446655440000",
  "size": 2458624,
  "contentType": "audio/m4a",
  "uploadedAt": "2024-03-15T10:30:00.000Z",
  "durationSeconds": 180,
  "fileName": "my-recording.m4a"
}
```

**Error Responses:**
```json
// 404 Not Found
{
  "statusCode": 404,
  "message": "File with key 550e8400-e29b-41d4-a716-446655440000 not found",
  "error": "Not Found"
}
```

---

## Complete Workflow Example

Here's a complete example of uploading and then playing back a file:

```bash
# 1. Get JWT token (from your auth service)
export TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# 2. Request upload URL
curl -X POST http://localhost:4002/v1/files/upload-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording.m4a",
    "contentType": "audio/m4a",
    "durationSeconds": 180
  }' | jq .

# Response:
# {
#   "uploadUrl": "https://s3.amazonaws.com/...",
#   "fileKey": "550e8400-e29b-41d4-a716-446655440000"
# }

# 3. Upload file to S3
export UPLOAD_URL="https://s3.amazonaws.com/soundcapsule-audio/..."
curl -X PUT "$UPLOAD_URL" \
  -H "Content-Type: audio/m4a" \
  --upload-file ./my-recording.m4a

# 4. Get playback URL
export FILE_KEY="550e8400-e29b-41d4-a716-446655440000"
curl -X GET "http://localhost:4002/v1/files/playback-url/$FILE_KEY" \
  -H "Authorization: Bearer $TOKEN" | jq .

# Response:
# {
#   "playbackUrl": "https://s3.amazonaws.com/..."
# }

# 5. Download/play the file
export PLAYBACK_URL="https://s3.amazonaws.com/soundcapsule-audio/..."
curl -X GET "$PLAYBACK_URL" -o downloaded-file.m4a
```

---

## Postman Collection

You can import this collection into Postman for easier testing:

```json
{
  "info": {
    "name": "SoundCapsule Storage API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:4002"
    },
    {
      "key": "token",
      "value": "YOUR_JWT_TOKEN"
    }
  ],
  "item": [
    {
      "name": "Create Upload URL",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"fileName\": \"test.m4a\",\n  \"contentType\": \"audio/m4a\",\n  \"durationSeconds\": 180\n}",
          "options": {
            "raw": {
              "language": "json"
            }
          }
        },
        "url": {
          "raw": "{{baseUrl}}/v1/files/upload-url",
          "host": ["{{baseUrl}}"],
          "path": ["v1", "files", "upload-url"]
        }
      }
    },
    {
      "name": "Get Playback URL",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{token}}"
          }
        ],
        "url": {
          "raw": "{{baseUrl}}/v1/files/playback-url/:fileKey?expiresHours=24",
          "host": ["{{baseUrl}}"],
          "path": ["v1", "files", "playback-url", ":fileKey"],
          "query": [
            {
              "key": "expiresHours",
              "value": "24"
            }
          ],
          "variable": [
            {
              "key": "fileKey",
              "value": "YOUR_FILE_KEY"
            }
          ]
        }
      }
    },
    {
      "name": "Get File Metadata",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{token}}"
          }
        ],
        "url": {
          "raw": "{{baseUrl}}/v1/files/:fileKey/metadata",
          "host": ["{{baseUrl}}"],
          "path": ["v1", "files", ":fileKey", "metadata"],
          "variable": [
            {
              "key": "fileKey",
              "value": "YOUR_FILE_KEY"
            }
          ]
        }
      }
    }
  ]
}
```

---

## Testing Without Valid JWT

For development/testing, you can temporarily disable authentication:

1. Comment out the `@UseGuards(JwtAuthGuard)` decorator in `files.controller.ts`
2. Rebuild the application
3. Test without Authorization header

**⚠️ WARNING:** Never deploy to production with authentication disabled!

---

## Common Issues

### 401 Unauthorized
- Token is expired
- Token issuer/audience doesn't match
- JWKS endpoint is not accessible
- Token is malformed

### 400 Bad Request
- Invalid content type (must be audio/m4a, audio/wav, or audio/mp4)
- Missing required fields
- Duration exceeds maximum (7200 seconds)
- Invalid fileName (contains special characters)

### 404 Not Found
- File doesn't exist in S3
- Incorrect fileKey
- File was deleted from S3

### 403 Forbidden (S3 Upload)
- Upload URL expired (15 minutes)
- Content-Type header doesn't match requested type
- Trying to upload to wrong URL

---

## Rate Limiting

Currently, there's no rate limiting implemented. Consider adding it in production using `@nestjs/throttler`:

```bash
npm install @nestjs/throttler
```

Example configuration:
- Upload URL requests: 10 per minute per user
- Playback URL requests: 100 per minute per user

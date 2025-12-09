import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('/ (GET) - should return 404 for root path', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(404);
  });

  it('/v1/files/upload-url (POST) - should return 401 without auth', () => {
    return request(app.getHttpServer())
      .post('/v1/files/upload-url')
      .send({
        fileName: 'test.m4a',
        contentType: 'audio/m4a',
        durationSeconds: 60,
      })
      .expect(401);
  });

  it('/v1/files/playback-url/:fileKey (GET) - should return 401 without auth', () => {
    return request(app.getHttpServer())
      .get('/v1/files/playback-url/test-key')
      .expect(401);
  });
});

import { Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { S3Service } from './s3.service';
import { CreateUploadUrlDto } from './dto/upload-url.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class FilesService {
  constructor(
    private prisma: PrismaService,
    private s3Service: S3Service,
    private configService: ConfigService,
  ) {}

  async createUploadUrl(dto: CreateUploadUrlDto, userId: string) {
    const fileKey = uuidv4();
    const expiresIn = this.configService.get<number>('UPLOAD_URL_EXPIRES_IN', 900);

    const uploadUrl = await this.s3Service.generateUploadUrl(
      fileKey,
      dto.contentType,
      expiresIn,
    );

    // Log to audit trail
    await this.prisma.fileAudit.create({
      data: {
        userId,
        fileKey,
        action: 'upload_url_requested',
        fileName: dto.fileName,
        contentType: dto.contentType,
        durationSeconds: dto.durationSeconds,
      },
    });

    return {
      uploadUrl,
      fileKey,
    };
  }

  async getPlaybackUrl(fileKey: string, expiresHours: number, userId: string) {
    const maxHours = this.configService.get<number>('MAX_PLAYBACK_HOURS', 168);
    const actualHours = Math.min(expiresHours, maxHours);
    const expiresIn = actualHours * 3600;

    // Verify file exists
    const metadata = await this.s3Service.getFileMetadata(fileKey);
    if (!metadata) {
      throw new NotFoundException(`File with key ${fileKey} not found`);
    }

    const playbackUrl = await this.s3Service.generatePlaybackUrl(fileKey, expiresIn);

    // Log to audit trail
    await this.prisma.fileAudit.create({
      data: {
        userId,
        fileKey,
        action: 'playback_url_requested',
        metadata: {
          expiresHours: actualHours,
        },
      },
    });

    return {
      playbackUrl,
    };
  }

  async getFileMetadata(fileKey: string) {
    const metadata = await this.s3Service.getFileMetadata(fileKey);
    
    if (!metadata) {
      throw new NotFoundException(`File with key ${fileKey} not found`);
    }

    // Get audit info for additional context
    const auditEntry = await this.prisma.fileAudit.findFirst({
      where: {
        fileKey,
        action: 'upload_url_requested',
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    return {
      fileKey,
      size: metadata.size,
      contentType: metadata.contentType,
      uploadedAt: metadata.lastModified,
      durationSeconds: auditEntry?.durationSeconds,
      fileName: auditEntry?.fileName,
    };
  }
}

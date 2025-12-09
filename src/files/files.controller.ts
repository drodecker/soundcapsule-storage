import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FilesService } from './files.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, CurrentUserData } from '../auth/decorators/current-user.decorator';
import { CreateUploadUrlDto } from './dto/upload-url.dto';
import { GetPlaybackUrlDto } from './dto/playback-url.dto';

@Controller('v1/files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('upload-url')
  @HttpCode(HttpStatus.OK)
  async createUploadUrl(
    @Body() dto: CreateUploadUrlDto,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.filesService.createUploadUrl(dto, user.userId);
  }

  @Get('playback-url/:fileKey')
  async getPlaybackUrl(
    @Param('fileKey') fileKey: string,
    @Query() query: GetPlaybackUrlDto,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.filesService.getPlaybackUrl(
      fileKey,
      query.expiresHours || 24,
      user.userId,
    );
  }

  @Get(':fileKey/metadata')
  async getFileMetadata(@Param('fileKey') fileKey: string) {
    return this.filesService.getFileMetadata(fileKey);
  }
}

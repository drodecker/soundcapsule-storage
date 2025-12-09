import { IsString, IsEnum, IsInt, Min, Max, Matches } from 'class-validator';

export enum AudioContentType {
  M4A = 'audio/m4a',
  WAV = 'audio/wav',
  MP4 = 'audio/mp4',
}

export class CreateUploadUrlDto {
  @IsString()
  @Matches(/^[a-zA-Z0-9._-]+$/, {
    message: 'fileName must contain only alphanumeric characters, dots, hyphens, and underscores',
  })
  fileName: string;

  @IsEnum(AudioContentType, {
    message: 'contentType must be one of: audio/m4a, audio/wav, audio/mp4',
  })
  contentType: AudioContentType;

  @IsInt()
  @Min(1)
  @Max(7200) // Max 2 hours
  durationSeconds: number;
}

import { IsOptional, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class GetPlaybackUrlDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(168) // Max 7 days
  @Type(() => Number)
  expiresHours?: number = 24;
}

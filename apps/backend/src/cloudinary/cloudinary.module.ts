import { Module, OnModuleInit, Logger } from '@nestjs/common';
import { CloudinaryService } from './cloudinary.service';
import { v2 as cloudinary } from 'cloudinary';

@Module({
  providers: [CloudinaryService],
  exports: [CloudinaryService],
})
export class CloudinaryModule implements OnModuleInit {
  private readonly logger = new Logger(CloudinaryModule.name);

  onModuleInit() {
    const cloudinaryUrl = process.env.CLOUDINARY_URL;
    if (!cloudinaryUrl) {
      this.logger.warn('⚠️  CLOUDINARY_URL tidak ditemukan! Upload video tidak akan berfungsi.');
      return;
    }

    // Parse CLOUDINARY_URL: cloudinary://api_key:api_secret@cloud_name
    try {
      const url = new URL(cloudinaryUrl);
      cloudinary.config({
        cloud_name: url.hostname,
        api_key: url.username,
        api_secret: url.password,
        secure: true,
      });
      this.logger.log(`✅ Cloudinary terhubung ke cloud: ${url.hostname}`);
    } catch (e) {
      this.logger.error('❌ Gagal parsing CLOUDINARY_URL! Pastikan formatnya benar: cloudinary://key:secret@cloud_name');
    }
  }
}

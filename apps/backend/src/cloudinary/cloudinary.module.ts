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
      this.logger.warn('⚠️  CLOUDINARY_URL tidak ditemukan di environment! Upload video tidak akan berfungsi.');
      return;
    }

    // Cara yang benar: biarkan SDK Cloudinary membaca CLOUDINARY_URL secara native
    // cloudinary.config(true) memaksa SDK untuk membaca ulang ENV vars
    cloudinary.config(true);

    const config = cloudinary.config();
    if (config.cloud_name) {
      this.logger.log(`✅ Cloudinary terhubung ke cloud: ${config.cloud_name} (key: ${config.api_key})`);
    } else {
      this.logger.error('❌ Cloudinary gagal terkonfigurasi! Periksa format CLOUDINARY_URL di Railway Variables.');
    }
  }
}

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.setGlobalPrefix('api');
  
  const portString = process.env.PORT || '3000';
  const port = parseInt(portString, 10);
  
  logger.log(`🚀 Akan mencoba membuka gerbang di 0.0.0.0 port ${port}...`);
  await app.listen(port, '0.0.0.0');
  logger.log(`✅ Server resmi terbuka dan siap menerima koneksi HTTP di port ${port}!`);
}
bootstrap();

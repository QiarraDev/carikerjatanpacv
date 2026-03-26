import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  console.log('--- Backend is listening on 0.0.0.0:3000 ---');
  await app.listen(3000, '0.0.0.0');
}
bootstrap();

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.setGlobalPrefix('api');
  const port = process.env.PORT || 3000;
  console.log(`--- Backend is listening on 0.0.0.0:${port}/api ---`);
  await app.listen(port, '0.0.0.0');
}
bootstrap();

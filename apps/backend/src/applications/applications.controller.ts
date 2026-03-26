import { Controller, Post, Get, Body, Param } from '@nestjs/common';
import { ApplicationsService } from './applications.service';

@Controller('applications')
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Post()
  async create(@Body() body: any) {
    return this.applicationsService.create(body.user_id, body.job_id, body.video_url);
  }

  @Get('user/:id')
  async findByUser(@Param('id') userId: string) {
    return this.applicationsService.findByUser(userId);
  }
}

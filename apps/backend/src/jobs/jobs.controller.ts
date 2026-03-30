import { Controller, Post, Get, Body, Param, UseGuards, Req } from '@nestjs/common';
import { JobsService } from './jobs.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  async create(@Body() body: any, @Req() req: any) {
    // 🔥 Attach recruiterId from JWT
    const recruiterId = req.user.userId;
    return this.jobsService.create({ ...body, recruiter_id: recruiterId });
  }

  @Get()
  async findAll() {
    return this.jobsService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }

  @Get('match/:userId')
  async matchJobs(@Param('userId') userId: string) {
    return this.jobsService.getMatchingJobs(userId);
  }
}

import { Controller, Get, Param, Patch, Put, Body } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @Put(':id/video')
  async updateVideo(@Param('id') id: string, @Body('video_url') videoUrl: string) {
    return this.usersService.update(id, { video_url: videoUrl });
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateData: any) {
    return this.usersService.update(id, updateData);
  }
}

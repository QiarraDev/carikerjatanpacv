import { Controller, Get, Patch, Put, Body, UseGuards, Req, Param } from '@nestjs/common';
import { UsersService } from './users.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('profile')
  async getProfile(@Req() req: any) {
    return this.usersService.findById(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Put('video')
  async updateVideo(@Req() req: any, @Body('video_url') videoUrl: string) {
    return this.usersService.update(req.user.userId, { video_url: videoUrl });
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('profile')
  async update(@Req() req: any, @Body() updateData: any) {
    return this.usersService.update(req.user.userId, updateData);
  }

  @Get('candidates')
  async getCandidates() {
    return this.usersService.getCandidates();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}

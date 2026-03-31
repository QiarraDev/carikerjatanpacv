import { Controller, Get, Patch, Put, Post, Body, UseGuards, Req, Param, UploadedFile, UseInterceptors, BadRequestException } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UsersService } from './users.service';
import { CloudinaryService } from '../cloudinary/cloudinary.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('profile')
  async getProfile(@Req() req: any) {
    return this.usersService.findById(req.user.userId);
  }

  @Post('upload-video/:userId')
  @UseInterceptors(FileInterceptor('video'))
  async uploadPitchVideo(
    @Param('userId') userId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('Beri file video!');
    const uploadResult = await this.cloudinaryService.uploadVideo(file) as any;
    return this.usersService.update(userId, { video_url: uploadResult.secure_url });
  }

  @Post('video')
  async saveVideo(@Body('user_id') userId: string, @Body('video_url') videoUrl: string) {
    return this.usersService.update(userId, { video_url: videoUrl });
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

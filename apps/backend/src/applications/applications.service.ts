import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Application } from './entities/application.schema';

@Injectable()
export class ApplicationsService {
  constructor(@InjectModel(Application.name) private applicationModel: Model<Application>) {}

  async create(user_id: string, job_id: string, video_url: string) {
    const newApp = new this.applicationModel({
      user_id,
      job_id,
      video_url,
      status: 'applied',
    });
    return newApp.save();
  }

  async findByUser(user_id: string) {
    return this.applicationModel.find({ user_id }).populate('job_id').exec();
  }
}

import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Job } from './entities/job.schema';

@Injectable()
export class JobsService {
  constructor(@InjectModel(Job.name) private jobModel: Model<Job>) {}

  async create(jobData: any): Promise<Job> {
    const newJob = new this.jobModel(jobData);
    return newJob.save();
  }

  async findAll(): Promise<Job[]> {
    return this.jobModel.find().sort({ createdAt: -1 }).exec();
  }

  async findOne(id: string): Promise<Job | null> {
    return this.jobModel.findById(id).exec();
  }
}

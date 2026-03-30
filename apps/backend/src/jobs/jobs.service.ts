import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Job } from './entities/job.schema';
import { UsersService } from '../users/users.service';

@Injectable()
export class JobsService {
  constructor(
    @InjectModel(Job.name) private jobModel: Model<Job>,
    private usersService: UsersService,
  ) {}

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

  async getMatchingJobs(userId: string): Promise<any[]> {
    const user = await this.usersService.findById(userId);
    if (!user) throw new NotFoundException('User not found');

    const jobs = await this.jobModel.find().exec();
    const userSkills = user.skills || [];

    const result = jobs.map((job) => {
      const jobSkills = job.required_skills || [];
      if (jobSkills.length === 0) return { ...job.toObject(), match: 0 };

      const matchedSkills = userSkills.filter((skill) =>
        jobSkills.some((s) => s.toLowerCase() === skill.toLowerCase()),
      );

      const match = matchedSkills.length / jobSkills.length;
      return { ...job.toObject(), match: match };
    });

    return result.sort((a, b) => b.match - a.match);
  }
}

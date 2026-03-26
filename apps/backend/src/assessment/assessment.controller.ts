import { Controller, Get, Param } from '@nestjs/common';
import { AssessmentService } from './assessment.service';

@Controller('assessment')
export class AssessmentController {
  constructor(private readonly assessmentService: AssessmentService) {}

  @Get(':job_id')
  async getQuestions(@Param('job_id') jobId: string) {
    return this.assessmentService.getQuestions(jobId);
  }
}

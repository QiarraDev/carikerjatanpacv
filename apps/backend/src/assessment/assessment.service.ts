import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Assessment } from './entities/assessment.schema';

@Injectable()
export class AssessmentService {
  constructor(@InjectModel(Assessment.name) private assessmentModel: Model<Assessment>) {}

  async getQuestions(job_id: string) {
    // Cari bank soal berdasarkan job_id (atau general jika tidak ada)
    const bank = await this.assessmentModel.findOne({ job_id }).exec();
    return bank ? bank.questions : this._getDummyQuestions();
  }

  private _getDummyQuestions() {
    return [
      {
        question_text: 'Apa bahasa pemrograman utama Flutter?',
        options: ['Java', 'Swift', 'Dart', 'Kotlin'],
        correct_answer: 2, // Dart
      },
      {
        question_text: 'Apa fungsi dari Widget "Stateless" di Flutter?',
        options: ['Menyimpan data state', 'UI yang tidak berubah', 'Koneksi ke Database', 'Animasi kompleks'],
        correct_answer: 1, // UI yang tidak berubah
      }
    ];
  }
}

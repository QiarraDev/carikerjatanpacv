import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Question {
  @Prop({ required: true })
  q: string;

  @Prop([String])
  options: string[];

  @Prop({ required: true })
  answer_idx: number;
}

@Schema({ timestamps: true })
export class Assessment extends Document {
  @Prop({ required: true, unique: true })
  skill: string;

  @Prop({ type: [Question], default: [] })
  questions: Question[];
}

export const AssessmentSchema = SchemaFactory.createForClass(Assessment);

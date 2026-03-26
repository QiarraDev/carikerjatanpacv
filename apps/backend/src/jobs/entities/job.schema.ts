import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class Job extends Document {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  company: string;

  @Prop({ required: true })
  description: string;

  @Prop([String])
  required_skills: string[];

  @Prop({ default: 70 })
  min_score: number;
}

export const JobSchema = SchemaFactory.createForClass(Job);

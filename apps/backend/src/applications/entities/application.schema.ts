import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Application extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user_id: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Job', required: true })
  job_id: Types.ObjectId;

  @Prop({ default: 'applied' })
  status: string; // applied, reviewed, accepted, rejected
}

export const ApplicationSchema = SchemaFactory.createForClass(Application);

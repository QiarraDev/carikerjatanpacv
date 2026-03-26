import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class User extends Document {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password_hash: string;

  @Prop()
  video_url: string;

  @Prop([String])
  skills: string[];

  @Prop({ type: Object, default: {} })
  test_scores: Map<string, number>;
}

export const UserSchema = SchemaFactory.createForClass(User);

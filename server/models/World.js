import mongoose from 'mongoose'
import idValidator from 'mongoose-id-validator'

const Schema = mongoose.Schema

const WorldSchema = new Schema({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  currentVersion: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: 'worldDoc',
  },
})

WorldSchema.plugin(idValidator)

export default WorldSchema

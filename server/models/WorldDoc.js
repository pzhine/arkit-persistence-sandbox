import mongoose from 'mongoose'

const Schema = mongoose.Schema

const WorldDocSchema = new Schema({
  lastModified: {
    type: Date,
    required: true,
  },
  notes: {
    type: String,
  },
  worldMapBinary: {
    type: Buffer,
  },
})

export default WorldDocSchema

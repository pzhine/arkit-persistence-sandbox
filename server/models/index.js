import mongoose from 'mongoose'

import WorldSchema from './World'
import WorldDocSchema from './WorldDoc'

export const World =
  mongoose.models.World || mongoose.model('world', WorldSchema)
export const WorldDoc =
  mongoose.models.WorldDoc || mongoose.model('worldDoc', WorldDocSchema)

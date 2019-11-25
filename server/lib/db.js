import mongoose from 'mongoose'
import dotenv from 'dotenv'

dotenv.config()

const dbURI = process.env.MONGO_URI
console.log('dbURI', dbURI)

const dB = mongoose

export const connectDB = async () => {
  try {
    await dB.connect(dbURI, {
      useNewUrlParser: true,
      useCreateIndex: true,
      useFindAndModify: false,
    })
    console.log('MongoDB Connected...')
  } catch (err) {
    console.error(err.message)
    // Exit process with failure
    process.exit(1)
  }
}

export const closeDB = async () => {
  await dB.disconnect()
  console.log('database connections closed')
}

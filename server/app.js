import ApiError from './lib/ApiError'

const express = require('express')
const cors = require('cors')
const { connectDB } = require('./lib/db')

let app = null

module.exports = async () => {
  if (app) {
    return app
  }

  app = express()

  // Connect Database
  await connectDB()

  // Init Middleware
  app.use(cors())
  app.use(express.json({ extended: false }))

  // Define Routes
  app.use('/api/worlds', require('./api/worlds'))
  app.use('/api/world-docs', require('./api/worldDocs'))

  app.get('/', (req, res) => {
    res.status(200).send('Hello World!')
  })

  // global error middleware
  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, next) => {
    if (err instanceof ApiError) {
      return res.status(err.status).json({ error: err })
    }
    console.error('ERR', err.message)
    return res.json({ error: { message: err.message } }).status(500)
  })

  return app
}

import express from 'express'
import StreamBuffers from 'stream-buffers'
import { WorldDoc } from '../models'
import ApiError from '../lib/ApiError'
import wrap from '../lib/guardedAsync'

const router = express.Router()

const withWorldDoc = wrap(async (req, res, next) => {
  const worldDoc = await WorldDoc.findOne({ _id: req.params.id })
  if (!worldDoc) {
    return next(
      new ApiError(`WorldDoc not found with _id ${req.params.id}`, 404)
    )
  }
  req.worldDoc = worldDoc
  return next()
})

// GET
router.get(
  '/',
  wrap(async (req, res) => {
    const worlds = await WorldDoc.find({}, '-worldMapBinary')
    res.json(worlds).status(200)
  })
)

router.get(
  '/:id',
  wrap(async (req, res, next) => {
    const worldDoc = await WorldDoc.findOne(
      { _id: req.params.id },
      '-worldMapBinary'
    )
    if (!worldDoc) {
      return next(
        new ApiError(`WorldDoc not found with _id ${req.params.id}`, 404)
      )
    }
    return res.json({ worldDoc }).status(200)
  })
)

router.get('/:id/world-map', withWorldDoc, (req, res) => {
  return res.send(req.worldDoc.worldMapBinary).status(200)
})

// POST

router.post(
  '/',
  wrap(async (req, res) => {
    const { _id, lastModified, notes } = req.body
    if (!_id) {
      throw new ApiError('_id is required', 400)
    }
    let worldDoc = await WorldDoc.findOne({ _id })
    // if world doesn't exist, create one
    if (!worldDoc) {
      worldDoc = new WorldDoc()
    }
    Object.assign(worldDoc, { _id, lastModified, notes })
    res.json(await worldDoc.save()).status(200)
  })
)

router.post(
  '/:id/world-map',
  withWorldDoc,
  wrap(async (req, res, next) => {
    console.log('world-map')
    const ms = new StreamBuffers.WritableStreamBuffer()
    req.on('end', async () => {
      const bytesReceived = ms.size()
      req.worldDoc.worldMapBinary = ms.getContents()
      try {
        await req.worldDoc.save()
        return res.json({ bytesReceived }).status(200)
      } catch (err) {
        return next(err)
      }
    })
    ms.on('error', err => {
      next(err)
    })
    req.pipe(ms)
    return true
  })
)

module.exports = router

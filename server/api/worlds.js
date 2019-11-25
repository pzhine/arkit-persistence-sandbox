import express from 'express'
import { World } from '../models'
import wrap from '../lib/guardedAsync'

const router = express.Router()

router.get(
  '/',
  wrap(async (req, res) => {
    const worlds = await World.find({})
    res.json(worlds).status(200)
  })
)

router.post(
  '/',
  wrap(async (req, res) => {
    const { _id, name, currentVersion } = req.body
    let world = await World.findOne({ _id })
    // if world doesn't exist, create one
    if (!world) {
      world = new World()
    }
    Object.assign(world, { _id, name, currentVersion })
    res.json(await world.save()).status(200)
  })
)

module.exports = router

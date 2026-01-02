import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// load .env from repo root (one level up from backend)
dotenv.config({ path: path.resolve(__dirname, '../.env') })

console.log('Resolved .env path:', path.resolve(__dirname, '../.env'))
console.log('process.env.MONGO_URI ->', process.env.MONGO_URI)
console.log('process.env.PORT ->', process.env.PORT)

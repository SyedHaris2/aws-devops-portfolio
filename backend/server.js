import express from "express";
import Redis from "ioredis";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

// Connect to Redis (ioredis will retry by default)
const redis = new Redis({
  host: process.env.REDIS_HOST || "redis",
  port: process.env.REDIS_PORT ? Number(process.env.REDIS_PORT) : 6379,
});

redis.on("error", err => console.error("Redis error:", err));
redis.on("connect", () => console.log("Connected to Redis"));

// Tasks list key
const TASKS_KEY = "tasks";

// Simple health route
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// Get all tasks
app.get("/tasks", async (req, res) => {
  try {
    const tasksJSON = await redis.get(TASKS_KEY);
    const tasks = tasksJSON ? JSON.parse(tasksJSON) : [];
    res.json(tasks);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch tasks" });
  }
});

// Add a new task
app.post("/tasks", async (req, res) => {
  try {
    const { title } = req.body;
    if (!title) return res.status(400).json({ error: "Title is required" });

    const tasksJSON = await redis.get(TASKS_KEY);
    const tasks = tasksJSON ? JSON.parse(tasksJSON) : [];

    const newTask = { _id: Date.now().toString(), title };
    tasks.push(newTask);

    await redis.set(TASKS_KEY, JSON.stringify(tasks));
    res.json(newTask);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add task" });
  }
});

// Redis test routes
app.post("/set", async (req, res) => {
  const { key, value } = req.body;
  await redis.set(key, value);
  res.send(`Set ${key} = ${value}`);
});

app.get("/get/:key", async (req, res) => {
  const value = await redis.get(req.params.key);
  res.send(value || "Key not found");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend running on ${PORT}`));

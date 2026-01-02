import { useState, useEffect } from "react";
import axios from "axios";

const API_BASE = import.meta.env.VITE_API_URL || "http://backend:5000";

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");

  useEffect(() => {
    axios.get(`${API_BASE}/tasks`).then(res => setTasks(res.data)).catch(() => setTasks([]));
  }, []);

  const addTask = async () => {
    if (!title) return;
    const res = await axios.post(`${API_BASE}/tasks`, { title });
    setTasks(prev => [...prev, res.data]);
    setTitle("");
  };

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center p-10">
      <h1 className="text-2xl font-bold mb-4">Cloud Task Manager</h1>
      <div className="flex mb-4">
        <input
          className="border p-2"
          placeholder="New Task"
          value={title}
          onChange={e => setTitle(e.target.value)}
        />
        <button onClick={addTask} className="bg-blue-600 text-white px-4">Add</button>
      </div>
      <ul className="bg-white shadow rounded p-4 w-1/2">
        {tasks.map(t => <li key={t._id} className="border-b py-2">{t.title}</li>)}
      </ul>
      #
    </div>
  );
}

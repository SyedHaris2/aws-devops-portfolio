import  { useState, useContext } from 'react';
import TaskContext from '../../context/TaskContext';
// import TokenContext from '../../context/TokenContext';
import instance from "../../Axios/axios.js";  // Fixed: Import instance (env baseURL, no hardcoded localhost)

import "./createTask.css";

function CreateTask() {
  const { dispatch } = useContext(TaskContext);
//   const { userToken } = useContext(TokenContext);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState('');  // Added for error display

  const handleAdd = async (e) => {
    e.preventDefault();
    if (!title.trim() || !description.trim()) {
      setError('Title and description required');
      return;
    }

    try {
      const res = await instance.post("/task/addTask", { title, description });
      console.log('Task created:', res.data);
      
      // Dispatch with task data from response
      dispatch({
        type: "ADD_TASK",
        title: res.data.task.title,
        description: res.data.task.description
      });
      setTitle("");
      setDescription("");
      setError('');
    } catch (error) {
      console.error('Create task error:', error.response?.data || error.message);
      setError(error.response?.data?.message || 'Failed to create task');
    }
  };

  return (
    <div className="addContainer md:w-1/3 md:mx-auto mx-3 mt-3 flex justify-center">
      <div className='w-11/12'>
        <form onSubmit={handleAdd}>
          {error && (
            <div className="text-red-500 p-2 mb-2 rounded bg-red-100">
              {error}
            </div>
          )}
          <div>
            <label htmlFor="title">Title</label>
            <input
              type="text"
              name="title"
              id="title"
              value={title}
              required
              onChange={(e) => setTitle(e.target.value)}
              className='bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500'
            />
          </div>
          <div className='my-3'>
            <label htmlFor="description">Description</label>
            <textarea
              rows={5}
              name="description"
              id="description"
              value={description}
              required
              onChange={(e) => setDescription(e.target.value)}
              style={{ resize: "none" }}
              className='bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500'
            />
          </div>
          <div className='flex justify-center'>
            <button
              type='submit'
              className='bg-blue-700 rounded-md text-white px-5 py-1'
            >
              Add
            </button>
          </div>
        </form>
        <div className="toast bg-green-600 text-white p-3 rounded-xl shadow-2xl text-center absolute bottom-4 left-1/2 -translate-x-1/2" id='toast'>
          <p>This is test</p>
        </div>
      </div>
    </div>
  );
}

export default CreateTask;
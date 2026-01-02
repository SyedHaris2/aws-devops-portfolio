// import './App.css';
// import { useEffect, useReducer } from 'react';
// import { BrowserRouter, Route, Routes } from 'react-router-dom';
// import Active from './components/Active';
// import Completed from './components/Completed';
// import AllTask from './components/AllTask';
// import Layout from './components/Layout';
// import TaskContext from './context/TaskContext';
// import TokenContext from './context/TokenContext';
// import taskReducer from './reducer/taskReducer';
// import tokenReducer from './reducer/tokenReducer';
// import userReducer from './reducer/userReducer';
// import Header from './components/Header/Header';
// import Login from './components/Login';
// import Register from './components/Register';
// import ForgotPassword from './components/forgotPassword/ForgotPassword';
// import ResetPassword from './components/forgotPassword/ResetPassword';
// import axios from './Axios/axios.js';
// function App() {
//   const token = JSON.parse(localStorage.getItem("authToken"));
//   const [tasks, dispatch] = useReducer(taskReducer, [])
//   const [userToken, tokenDispatch] = useReducer(tokenReducer, token)
//   const [user, userDispatch] = useReducer(userReducer, {})
//   useEffect(() => {
//     console.log("App.js");
//     const fetchUser = async () => {
//       try {
//         console.log("fetchUser");
//         const res = await axios.get("/user/getUser",{
//           headers: {
//             Authorization: `Bearer ${userToken}`
//           }
//         })
//         //tokenDispatch({type: "SET_TOKEN", payload: res.token})
//         console.log("res.data: ", res.data);
//         userDispatch({type: "SET_USER", payload:res.data.user})
//       } catch (error) {
//         console.log(error);
//       }
//     }
//     if (userToken) {
//       fetchUser()
//     }
//   },[userToken])
//   useEffect(() => {
//     const fetchTasks = async () => {
//       try {
//         console.log("fetchTasks");
//         const res = await axios.get("/task/getTask", {
//           headers: {
//             Authorization: `Bearer ${userToken}`
//           }
//         })
//         dispatch({ type: "SET_TASK", payload: res.data })
//       } catch (error) {
//         console.log(error);
//       }
//     }
//     if (userToken) {
//       fetchTasks()
//     }
//   },[userToken])
//   return (
//     <BrowserRouter>
//       <TokenContext.Provider value={{userToken, tokenDispatch, user, userDispatch}}>
//         <TaskContext.Provider value={{ tasks, dispatch }}>
//           <Routes>
//             <Route path="/" element={<Header />}>
//               <Route path='/' element={token ? <Layout /> : <Login />}>
//                 <Route index element={<AllTask />} />
//                 <Route path="active" element={<Active />} />
//                 <Route path="completed" element={<Completed />} />
//               </Route>
//               <Route path="/login" element={<Login />} />
//               <Route path="/register" element={<Register />} />
//               <Route path="/forgotPassword" element={<ForgotPassword />} />
//               <Route path="/resetPassword" element={<ResetPassword />} />
//             </Route>
//           </Routes>
//         </TaskContext.Provider>
//       </TokenContext.Provider>

//     </BrowserRouter>
//   );
// }

// export default App;

import './App.css';
import { useEffect, useReducer } from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import Active from './components/Active';
import Completed from './components/Completed';
import AllTask from './components/AllTask';
import Layout from './components/Layout';
import TaskContext from './context/TaskContext';
import TokenContext from './context/TokenContext';
import taskReducer from './reducer/taskReducer';
import tokenReducer from './reducer/tokenReducer';
import userReducer from './reducer/userReducer';
import Header from './components/Header/Header';
import Login from './components/Login';
import Register from './components/Register';
import ForgotPassword from './components/forgotPassword/ForgotPassword';
import ResetPassword from './components/forgotPassword/ResetPassword';
import instance from './Axios/axios.js';  // Import instance (not axios)

function App() {
  // Read token from localStorage. Token may be stored as raw string (JWT) or JSON-stringified.
  let token = null;
  try {
    const raw = localStorage.getItem('authToken');
    if (raw) {
      try {
        token = JSON.parse(raw);
      } catch (e) {
        // not JSON, use raw string (likely a JWT)
        token = raw;
      }
    }
  } catch (e) {
    token = null;
  }
  const [tasks, dispatch] = useReducer(taskReducer, []);
  const [userToken, tokenDispatch] = useReducer(tokenReducer, token);
  const [user, userDispatch] = useReducer(userReducer, {});

  useEffect(() => {
    console.log("App.js");
    const fetchUser = async () => {
      try {
        console.log("fetchUser");
        // backend route: GET /api/user/getuser
        const res = await instance.get("/user/getuser");
        console.log("res.data: ", res.data);
        userDispatch({ type: "SET_USER", payload: res.data.user });
      } catch (error) {
        console.log("fetchUser error:", error);
      }
    };
    if (userToken) {
      fetchUser();
    }
  }, [userToken]);

  useEffect(() => {
    const fetchTasks = async () => {
      try {
  console.log("fetchTasks");
  // backend route: GET /api/task/getTask
  const res = await instance.get("/task/getTask");
  dispatch({ type: "SET_TASK", payload: res.data });
      } catch (error) {
        console.log("fetchTasks error:", error);
      }
    };
    if (userToken) {
      fetchTasks();
    }
  }, [userToken]);

  return (
    <BrowserRouter>
      <TokenContext.Provider value={{ userToken, tokenDispatch, user, userDispatch }}>
        <TaskContext.Provider value={{ tasks, dispatch }}>
          <Routes>
            <Route path="/" element={<Header />}>
              <Route path='/' element={userToken ? <Layout /> : <Login />}>
                <Route index element={<AllTask />} />
                <Route path="active" element={<Active />} />
                <Route path="completed" element={<Completed />} />
              </Route>
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              <Route path="/forgotPassword" element={<ForgotPassword />} />
              <Route path="/resetPassword" element={<ResetPassword />} />
            </Route>
          </Routes>
        </TaskContext.Provider>
      </TokenContext.Provider>
    </BrowserRouter>
  );
}

export default App;
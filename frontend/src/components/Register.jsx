import React, { useState, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import instance from "../Axios/axios.js";
import TokenContext from '../context/TokenContext.js';

function Register() {
  const [formData, setFormData] = useState({ 
    firstName: '', 
    lastName: '', 
    email: '', 
    password: '' 
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { userToken, tokenDispatch, userDispatch } = useContext(TokenContext);
  const navigate = useNavigate();

  // If logged in, redirect early
  if (userToken) {
    navigate('/');
    return null;
  }

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value.trim() });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    console.log('Register body sending:', formData); // Debug

    // Frontend validation
    if (!formData.firstName.trim() || !formData.lastName.trim() || !formData.email.trim() || !formData.password.trim()) {
      setError('Please enter all fields');
      setLoading(false);
      return;
    }
    if (!formData.email.includes('@') || !formData.email.includes('.')) {
      setError('Please enter a valid email');
      setLoading(false);
      return;
    }
    if (formData.password.length < 6) {
      setError('Password must be at least 6 characters');
      setLoading(false);
      return;
    }

    try {
      const result = await instance.post("/user/register", {
        firstName: formData.firstName,
        lastName: formData.lastName,
        email: formData.email,
        password: formData.password
      });
      
      console.log('Register response:', result.data); // Debug
      
      if (result.data.token) {
        tokenDispatch({ type: "SET_TOKEN", payload: result.data.token });
      }
      if (result.data.user) {
        userDispatch({ type: "SET_USER", payload: result.data.user });
      }
      
      localStorage.setItem("authToken", result.data.token);
      alert('Registered successfully!');
      navigate('/');
    } catch (error) {
      console.error('Register error:', error.response?.data || error.message); // Debug
      setError(error.response?.data?.message || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <section className="login-container">
        <div className="px-6 h-full text-gray-800">
          <div className="flex xl:justify-center lg:justify-between justify-center items-center flex-wrap h-full g-6">
            <div className="grow-0 shrink-1 md:shrink-0 basis-auto xl:w-6/12 lg:w-6/12 md:w-9/12 mb-12 md:mb-0">
              <img src="https://mdbcdn.b-cdn.net/img/Photos/new-templates/bootstrap-login-form/draw2.webp" className="w-full" alt="Sample" />
            </div>
            <div className="xl:ml-20 xl:w-5/12 lg:w-5/12 md:w-8/12 mb-12 md:mb-0">
              <form onSubmit={handleSubmit}>
                <h2 className="text-2xl font-bold mb-6">Create an Account</h2>
                
                <div>
                  {error && (
                    <div className="text-center border-2 border-red-600 p-2 mb-4 rounded-md bg-red-200 shadow-2xl">
                      {error}
                    </div>
                  )}
                </div>

                <div className="mb-4">
                  <input
                    type="text"
                    name='firstName'
                    value={formData.firstName}
                    onChange={handleChange}
                    className="form-control block w-full px-4 py-2 text-xl font-normal text-gray-700 bg-white bg-clip-padding border border-solid border-gray-300 rounded transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none"
                    id="firstNameInput"
                    placeholder="First Name"
                    required
                  />
                </div>

                <div className="mb-4">
                  <input
                    type="text"
                    name='lastName'
                    value={formData.lastName}
                    onChange={handleChange}
                    className="form-control block w-full px-4 py-2 text-xl font-normal text-gray-700 bg-white bg-clip-padding border border-solid border-gray-300 rounded transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none"
                    id="lastNameInput"
                    placeholder="Last Name"
                    required
                  />
                </div>

                <div className="mb-4">
                  <input
                    type="email"
                    name='email'
                    value={formData.email}
                    onChange={handleChange}
                    className="form-control block w-full px-4 py-2 text-xl font-normal text-gray-700 bg-white bg-clip-padding border border-solid border-gray-300 rounded transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none"
                    id="emailInput"
                    placeholder="Email address"
                    required
                  />
                </div>

                <div className="mb-6">
                  <input
                    type="password"
                    name='password'
                    value={formData.password}
                    onChange={handleChange}
                    className="form-control block w-full px-4 py-2 text-xl font-normal text-gray-700 bg-white bg-clip-padding border border-solid border-gray-300 rounded transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none"
                    id="passInput"
                    placeholder="Password (min 6 characters)"
                    required
                  />
                </div>

                <div className="text-center lg:text-left">
                  <button
                    type="submit"
                    disabled={loading}
                    className="inline-block px-7 py-3 bg-blue-600 text-white font-medium text-sm leading-snug uppercase rounded shadow-md hover:bg-blue-700 hover:shadow-lg focus:bg-blue-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-blue-800 active:shadow-lg transition duration-150 ease-in-out disabled:opacity-50 disabled:cursor-not-allowed">
                    {loading ? 'Registering...' : 'Register'}
                  </button>
                  <p className="text-sm font-semibold mt-2 pt-1 mb-0">
                    Already have an account?
                    <Link
                      to={"/login"}
                      className="text-blue-600 hover:text-blue-700 focus:text-blue-700 transition duration-200 ease-in-out ml-5"
                    >Login</Link>
                  </p>
                </div>
              </form>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

export default Register;
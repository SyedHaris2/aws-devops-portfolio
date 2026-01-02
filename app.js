// app.js - Modernized Version

const express = require('express');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');
// Use the modern, maintained sanitizer package
const sanitize = require('sanitize-html'); 
const app = express();
const port = 8000;

// --- In-Memory Data Store (Modernized Anti-Pattern) ---
// Using an object with IDs is better than an array for CRUD operations
let todolist = {};
let todoId = 0;

app.set('view cache', false);

// --- Middleware Configuration ---
app.use(bodyParser.urlencoded({
    extended: false
}));

app.use((req, res, next) => {
  res.set('Cache-Control', 'no-store');
  next();
});


// Configure method-override: required for using PUT/DELETE in HTML forms
app.use(methodOverride((req, res) => {
    if (req.body && typeof req.body === 'object' && '_method' in req.body) {
        const method = req.body._method;
        delete req.body._method;
        return method;
    }
    return null;
}));

// Set EJS as the template engine
app.set('view engine', 'ejs');

// --- Sanitization Helper Function ---
// This configuration strips all HTML tags, allowing only plain text
const sanitizeInput = (text) => {
    return sanitize(text, { allowedTags: [], allowedAttributes: {} }).trim();
};

// --- Route Handlers ---

// Get all todo items
app.get('/todo', (req, res) => {
    // Convert the todo object values back into an array of {id, item} objects for EJS rendering
    const todoArray = Object.keys(todolist).map(key => ({
        id: key,
        item: todolist[key]
    }));
    
    res.render('todo', {
        todolist: todoArray,
    });
});

// Adding an item to the to do list
app.post('/todo/add', (req, res) => {
    const newTodoText = req.body.newtodo;
    const cleanTodo = sanitizeInput(newTodoText);

    if (cleanTodo !== '') {
        todoId++;
        todolist[todoId] = cleanTodo;
    }
    res.redirect('/todo');
});

// Deletes an item from the to do list (Now using DELETE method)
app.delete('/todo/delete/:id', (req, res) => {
    const idToDelete = req.params.id;
    
    if (todolist[idToDelete]) {
        delete todolist[idToDelete];
    }
    res.redirect('/todo');
});

// Get a single todo item and render edit page
app.get('/todo/edit/:id', (req, res) => {
    const todoIdx = req.params.id; // This is the unique ID
    const todo = todolist[todoIdx];
    
    if (todo) {
        res.render('edititem', {
            todoIdx,
            todo,
        });
    } else {
        res.redirect('/todo');
    }
});

app.get('/version', (req, res) => {
  res.send("Version: " + new Date());
});


// Edit item in the todo list (using PUT)
app.put('/todo/edit/:id', (req, res) => {
    const todoIdx = req.params.id;
    const editTodoText = req.body.editTodo;
    const cleanEditTodo = sanitizeInput(editTodoText);

    if (todolist[todoIdx] && cleanEditTodo !== '') {
        todolist[todoIdx] = cleanEditTodo;
    }
    res.redirect('/todo');
});

/* Fallback redirect for unhandled routes */
app.use((req, res, next) => {
    res.redirect('/todo');
});

app.listen(port, () => {
    console.log(`Todolist running on http://0.0.0.0:${port}`);
});

module.exports = app;
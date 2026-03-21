const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

const userRoutes = require('./routes/userRoutes');

//Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

//Routes
app.use('/api/users', userRoutes);

module.exports = app;
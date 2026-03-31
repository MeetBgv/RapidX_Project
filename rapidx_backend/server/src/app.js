const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

const userRoutes = require('./routes/userRoutes');
const hubRoutes = require('./routes/hubRoutes');

//Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

//Routes
app.use('/api/users', userRoutes);
app.use('/api/hubs', hubRoutes);

module.exports = app;
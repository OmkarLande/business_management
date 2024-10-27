const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const businessRoutes = require('./routes/businessRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes') // Import inventory routes

const app = express();
const port = process.env.PORT || 3000;

// Connect to the database
db.connector();

// Middleware
app.use(cors());
app.use(express.json()); // To parse JSON bodies
app.use(express.urlencoded({ extended: true })); // To parse URL-encoded bodies
app.use(bodyParser.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/business', businessRoutes); // Add inventory route
app.use('/api/inventory', inventoryRoutes);

// Root route
app.get('/', (req, res) => {
    res.send('Hello World!');
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

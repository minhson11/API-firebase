const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const customersRoutes = require('./routes/customers');
const menuItemsRoutes = require('./routes/menu_items');
const reservationsRoutes = require('./routes/reservations');
const tablesRoutes = require('./routes/tables');

app.use('/api/customers', customersRoutes);
app.use('/api/menu-items', menuItemsRoutes);
app.use('/api/reservations', reservationsRoutes);
app.use('/api/tables', tablesRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Restaurant Reservation System API - Student ID: 1771020599',
    version: '2.0.0',
    database: 'db_exam_1771020599',
    endpoints: {
      customers: '/api/customers',
      menu_items: '/api/menu-items',
      reservations: '/api/reservations',
      tables: '/api/tables'
    },
    features: [
      'Customer registration and login',
      'Menu management with categories',
      'Table reservation system',
      'Loyalty points system',
      'Payment processing',
      'Table management'
    ]
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    database: 'db_exam_1771020599',
    version: '2.0.0'
  });
});

// API Documentation
app.get('/api/docs', (req, res) => {
  res.json({
    title: 'Restaurant Reservation System API Documentation',
    version: '2.0.0',
    student_id: '1771020599',
    endpoints: {
      customers: {
        'GET /api/customers': 'Get all customers',
        'GET /api/customers/:id': 'Get customer by ID',
        'POST /api/customers/register': 'Register new customer',
        'POST /api/customers/login': 'Customer login',
        'PUT /api/customers/:id': 'Update customer info',
        'PATCH /api/customers/:id/loyalty-points': 'Update loyalty points'
      },
      menu_items: {
        'GET /api/menu-items': 'Get all menu items (with filters)',
        'GET /api/menu-items/category/:category': 'Get items by category',
        'GET /api/menu-items/:id': 'Get menu item by ID',
        'POST /api/menu-items': 'Create new menu item',
        'PUT /api/menu-items/:id': 'Update menu item',
        'PATCH /api/menu-items/:id/rating': 'Update item rating',
        'GET /api/menu-items/stats/by-category': 'Get menu statistics'
      },
      reservations: {
        'GET /api/reservations': 'Get all reservations (with filters)',
        'GET /api/reservations/:id': 'Get reservation details',
        'POST /api/reservations': 'Create new reservation',
        'PATCH /api/reservations/:id/status': 'Update reservation status',
        'PATCH /api/reservations/:id/payment': 'Update payment info',
        'POST /api/reservations/:id/items': 'Add items to reservation',
        'GET /api/reservations/stats/summary': 'Get reservation statistics'
      },
      tables: {
        'GET /api/tables': 'Get all tables',
        'GET /api/tables/available': 'Get available tables',
        'GET /api/tables/:id': 'Get table by ID',
        'POST /api/tables': 'Create new table',
        'PUT /api/tables/:id': 'Update table',
        'PATCH /api/tables/:id/availability': 'Update table availability',
        'DELETE /api/tables/:id': 'Delete table',
        'GET /api/tables/stats/summary': 'Get table statistics'
      }
    },
    categories: ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'],
    reservation_statuses: ['pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show'],
    payment_methods: ['cash', 'card', 'online'],
    payment_statuses: ['pending', 'paid', 'refunded']
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `Cannot ${req.method} ${req.originalUrl}`,
    available_endpoints: [
      'GET /',
      'GET /health',
      'GET /api/docs',
      'GET /api/customers',
      'GET /api/menu-items',
      'GET /api/reservations',
      'GET /api/tables'
    ]
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Restaurant Reservation System API`);
  console.log(`📍 Server running on port ${PORT}`);
  console.log(`🌐 API Documentation: http://localhost:${PORT}/api/docs`);
  console.log(`💾 Database: db_exam_1771020599`);
  console.log(`👤 Student ID: 1771020599`);
});
const mysql = require('mysql2');
require('dotenv').config();

// Tạm thời vô hiệu hóa database connection để test
const connection = null;
console.log('Database connection temporarily disabled for testing');

module.exports = connection;
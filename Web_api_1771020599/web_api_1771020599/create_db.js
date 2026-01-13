const mysql = require('mysql2');
require('dotenv').config();

// Kết nối không cần database để tạo database
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD || ''
});

connection.connect((err) => {
  if (err) {
    console.error('Connection failed:', err);
    return;
  }
  
  console.log('Connected to MySQL server');
  
  // Tạo database
  connection.query('CREATE DATABASE IF NOT EXISTS db_exam_1771020311', (err, result) => {
    if (err) {
      console.error('Error creating database:', err);
      return;
    }
    console.log('Database db_exam_1771020311 created or already exists');
    connection.end();
  });
});
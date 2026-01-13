const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Lấy tất cả danh mục
router.get('/', (req, res) => {
  const query = 'SELECT * FROM categories ORDER BY name';
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    res.json({
      success: true,
      data: results
    });
  });
});

// Lấy danh mục theo ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM categories WHERE id = ?';
  
  db.query(query, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.json({
      success: true,
      data: results[0]
    });
  });
});

// Tạo danh mục mới
router.post('/', (req, res) => {
  const { name, description, image_url } = req.body;
  
  if (!name) {
    return res.status(400).json({ error: 'Category name is required' });
  }
  
  const query = 'INSERT INTO categories (name, description, image_url) VALUES (?, ?, ?)';
  
  db.query(query, [name, description, image_url], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    res.status(201).json({
      success: true,
      message: 'Category created successfully',
      data: { id: results.insertId, name, description, image_url }
    });
  });
});

module.exports = router;
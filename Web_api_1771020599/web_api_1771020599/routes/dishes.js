const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Lấy tất cả món ăn
router.get('/', (req, res) => {
  const { category_id } = req.query;
  
  let query = `
    SELECT d.*, c.name as category_name 
    FROM dishes d 
    LEFT JOIN categories c ON d.category_id = c.id 
    WHERE d.is_available = TRUE
  `;
  let params = [];
  
  if (category_id) {
    query += ' AND d.category_id = ?';
    params.push(category_id);
  }
  
  query += ' ORDER BY d.name';
  
  db.query(query, params, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    res.json({
      success: true,
      data: results
    });
  });
});

// Lấy món ăn theo ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const query = `
    SELECT d.*, c.name as category_name 
    FROM dishes d 
    LEFT JOIN categories c ON d.category_id = c.id 
    WHERE d.id = ?
  `;
  
  db.query(query, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'Dish not found' });
    }
    
    res.json({
      success: true,
      data: results[0]
    });
  });
});

// Tạo món ăn mới
router.post('/', (req, res) => {
  const { name, description, price, category_id, image_url } = req.body;
  
  if (!name || !price) {
    return res.status(400).json({ error: 'Name and price are required' });
  }
  
  const query = 'INSERT INTO dishes (name, description, price, category_id, image_url) VALUES (?, ?, ?, ?, ?)';
  
  db.query(query, [name, description, price, category_id, image_url], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    res.status(201).json({
      success: true,
      message: 'Dish created successfully',
      data: { id: results.insertId, name, description, price, category_id, image_url }
    });
  });
});

// Cập nhật món ăn
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { name, description, price, category_id, image_url, is_available } = req.body;
  
  const query = `
    UPDATE dishes 
    SET name = ?, description = ?, price = ?, category_id = ?, image_url = ?, is_available = ?
    WHERE id = ?
  `;
  
  db.query(query, [name, description, price, category_id, image_url, is_available, id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Dish not found' });
    }
    
    res.json({
      success: true,
      message: 'Dish updated successfully'
    });
  });
});

module.exports = router;
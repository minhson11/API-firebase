const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Lấy tất cả bàn
router.get('/', (req, res) => {
  const { is_available, capacity } = req.query;
  
  let query = 'SELECT * FROM tables WHERE 1=1';
  let params = [];
  
  if (is_available !== undefined) {
    query += ' AND is_available = ?';
    params.push(is_available === 'true');
  }
  
  if (capacity) {
    query += ' AND capacity >= ?';
    params.push(capacity);
  }
  
  query += ' ORDER BY table_number';
  
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

// Lấy bàn trống theo thời gian và số người
router.get('/available', (req, res) => {
  const { date, time, guests } = req.query;
  
  if (!date || !time || !guests) {
    return res.status(400).json({ 
      error: 'Date, time and number of guests are required' 
    });
  }
  
  const datetime = `${date} ${time}`;
  
  // Tìm bàn trống (không có reservation trong khoảng thời gian đó)
  const query = `
    SELECT t.* 
    FROM tables t
    WHERE t.capacity >= ? 
    AND t.is_available = TRUE
    AND t.table_number NOT IN (
      SELECT DISTINCT r.table_number 
      FROM reservations r 
      WHERE r.table_number IS NOT NULL
      AND r.status IN ('confirmed', 'seated')
      AND DATE(r.reservation_date) = ?
      AND ABS(TIMESTAMPDIFF(HOUR, r.reservation_date, ?)) < 3
    )
    ORDER BY t.capacity, t.table_number
  `;
  
  db.query(query, [guests, date, datetime], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    res.json({
      success: true,
      data: results
    });
  });
});

// Lấy bàn theo ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM tables WHERE id = ?';
  
  db.query(query, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'Table not found' });
    }
    
    res.json({
      success: true,
      data: results[0]
    });
  });
});

// Tạo bàn mới
router.post('/', (req, res) => {
  const { table_number, capacity } = req.body;
  
  if (!table_number || !capacity) {
    return res.status(400).json({ error: 'Table number and capacity are required' });
  }
  
  const query = 'INSERT INTO tables (table_number, capacity) VALUES (?, ?)';
  
  db.query(query, [table_number, capacity], (err, results) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Table number already exists' });
      }
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    res.status(201).json({
      success: true,
      message: 'Table created successfully',
      data: { 
        id: results.insertId, 
        table_number, 
        capacity 
      }
    });
  });
});

// Cập nhật bàn
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { table_number, capacity, is_available } = req.body;
  
  const query = 'UPDATE tables SET table_number = ?, capacity = ?, is_available = ? WHERE id = ?';
  
  db.query(query, [table_number, capacity, is_available, id], (err, results) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Table number already exists' });
      }
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Table not found' });
    }
    
    res.json({
      success: true,
      message: 'Table updated successfully'
    });
  });
});

// Cập nhật trạng thái bàn
router.patch('/:id/availability', (req, res) => {
  const { id } = req.params;
  const { is_available } = req.body;
  
  if (is_available === undefined) {
    return res.status(400).json({ error: 'is_available is required' });
  }
  
  const query = 'UPDATE tables SET is_available = ? WHERE id = ?';
  
  db.query(query, [is_available, id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Table not found' });
    }
    
    res.json({
      success: true,
      message: 'Table availability updated successfully'
    });
  });
});

// Xóa bàn
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  
  // Kiểm tra xem bàn có đang được sử dụng không
  const checkQuery = `
    SELECT COUNT(*) as count 
    FROM reservations r 
    JOIN tables t ON r.table_number = t.table_number 
    WHERE t.id = ? AND r.status IN ('confirmed', 'seated')
  `;
  
  db.query(checkQuery, [id], (err, checkResults) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (checkResults[0].count > 0) {
      return res.status(400).json({ 
        error: 'Cannot delete table with active reservations' 
      });
    }
    
    const deleteQuery = 'DELETE FROM tables WHERE id = ?';
    
    db.query(deleteQuery, [id], (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err.message });
      }
      
      if (results.affectedRows === 0) {
        return res.status(404).json({ error: 'Table not found' });
      }
      
      res.json({
        success: true,
        message: 'Table deleted successfully'
      });
    });
  });
});

// Lấy thống kê bàn
router.get('/stats/summary', (req, res) => {
  const query = `
    SELECT 
      COUNT(*) as total_tables,
      COUNT(CASE WHEN is_available = TRUE THEN 1 END) as available_tables,
      COUNT(CASE WHEN is_available = FALSE THEN 1 END) as occupied_tables,
      SUM(capacity) as total_capacity,
      AVG(capacity) as avg_capacity
    FROM tables
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    res.json({
      success: true,
      data: results[0]
    });
  });
});

module.exports = router;
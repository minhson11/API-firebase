const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Lấy tất cả đơn hàng
router.get('/', (req, res) => {
  const query = `
    SELECT o.*, c.name as customer_name, c.phone as customer_phone
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.id
    ORDER BY o.order_date DESC
  `;
  
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

// Lấy chi tiết đơn hàng
router.get('/:id', (req, res) => {
  const { id } = req.params;
  
  // Lấy thông tin đơn hàng
  const orderQuery = `
    SELECT o.*, c.name as customer_name, c.phone as customer_phone, c.email as customer_email
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.id
    WHERE o.id = ?
  `;
  
  db.query(orderQuery, [id], (err, orderResults) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (orderResults.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    // Lấy chi tiết món ăn trong đơn hàng
    const itemsQuery = `
      SELECT oi.*, d.name as dish_name, d.image_url as dish_image
      FROM order_items oi
      LEFT JOIN dishes d ON oi.dish_id = d.id
      WHERE oi.order_id = ?
    `;
    
    db.query(itemsQuery, [id], (err, itemsResults) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err.message });
      }
      
      const order = orderResults[0];
      order.items = itemsResults;
      
      res.json({
        success: true,
        data: order
      });
    });
  });
});

// Tạo đơn hàng mới
router.post('/', (req, res) => {
  const { customer_id, items, delivery_address, notes } = req.body;
  
  if (!customer_id || !items || items.length === 0) {
    return res.status(400).json({ error: 'Customer ID and items are required' });
  }
  
  // Tính tổng tiền
  let total_amount = 0;
  items.forEach(item => {
    total_amount += item.quantity * item.unit_price;
  });
  
  // Tạo đơn hàng
  const orderQuery = 'INSERT INTO orders (customer_id, total_amount, delivery_address, notes) VALUES (?, ?, ?, ?)';
  
  db.query(orderQuery, [customer_id, total_amount, delivery_address, notes], (err, orderResult) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    const orderId = orderResult.insertId;
    
    // Thêm chi tiết đơn hàng
    const itemsQuery = 'INSERT INTO order_items (order_id, dish_id, quantity, unit_price, subtotal) VALUES ?';
    const itemsData = items.map(item => [
      orderId,
      item.dish_id,
      item.quantity,
      item.unit_price,
      item.quantity * item.unit_price
    ]);
    
    db.query(itemsQuery, [itemsData], (err, itemsResult) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err.message });
      }
      
      res.status(201).json({
        success: true,
        message: 'Order created successfully',
        data: { id: orderId, total_amount }
      });
    });
  });
});

// Cập nhật trạng thái đơn hàng
router.patch('/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  
  const query = 'UPDATE orders SET status = ? WHERE id = ?';
  
  db.query(query, [status, id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    res.json({
      success: true,
      message: 'Order status updated successfully'
    });
  });
});

module.exports = router;
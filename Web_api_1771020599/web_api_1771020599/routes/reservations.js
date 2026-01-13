const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Lấy tất cả reservations
router.get('/', (req, res) => {
  const { status, customer_id, date } = req.query;
  
  let query = `
    SELECT r.*, c.full_name as customer_name, c.phone_number as customer_phone, c.email as customer_email
    FROM reservations r
    LEFT JOIN customers c ON r.customer_id = c.id
    WHERE 1=1
  `;
  let params = [];
  
  if (status) {
    query += ' AND r.status = ?';
    params.push(status);
  }
  
  if (customer_id) {
    query += ' AND r.customer_id = ?';
    params.push(customer_id);
  }
  
  if (date) {
    query += ' AND DATE(r.reservation_date) = ?';
    params.push(date);
  }
  
  query += ' ORDER BY r.reservation_date DESC';
  
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

// Lấy chi tiết reservation
router.get('/:id', (req, res) => {
  const { id } = req.params;
  
  // Lấy thông tin reservation
  const reservationQuery = `
    SELECT r.*, c.full_name as customer_name, c.phone_number as customer_phone, 
           c.email as customer_email, c.loyalty_points as customer_loyalty_points
    FROM reservations r
    LEFT JOIN customers c ON r.customer_id = c.id
    WHERE r.id = ?
  `;
  
  db.query(reservationQuery, [id], (err, reservationResults) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (reservationResults.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    
    // Lấy chi tiết items trong reservation
    const itemsQuery = `
      SELECT ri.*, mi.name as item_name, mi.category, mi.image_url as item_image
      FROM reservation_items ri
      LEFT JOIN menu_items mi ON ri.menu_item_id = mi.id
      WHERE ri.reservation_id = ?
    `;
    
    db.query(itemsQuery, [id], (err, itemsResults) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err.message });
      }
      
      const reservation = reservationResults[0];
      reservation.items = itemsResults;
      
      res.json({
        success: true,
        data: reservation
      });
    });
  });
});

// Tạo reservation mới
router.post('/', (req, res) => {
  const { 
    customer_id, 
    reservation_date, 
    number_of_guests, 
    special_requests, 
    items 
  } = req.body;
  
  if (!customer_id || !reservation_date || !number_of_guests) {
    return res.status(400).json({ 
      error: 'Customer ID, reservation date and number of guests are required' 
    });
  }
  
  // Tạo reservation number
  const now = new Date();
  const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '');
  const timeStr = now.getTime().toString().slice(-4);
  const reservation_number = `RSV${dateStr}${timeStr}`;
  
  // Tính subtotal nếu có items
  let subtotal = 0;
  if (items && items.length > 0) {
    subtotal = items.reduce((sum, item) => sum + (item.quantity * item.price), 0);
  }
  
  // Tạo reservation
  const reservationQuery = `
    INSERT INTO reservations 
    (customer_id, reservation_number, reservation_date, number_of_guests, special_requests, subtotal) 
    VALUES (?, ?, ?, ?, ?, ?)
  `;
  
  db.query(reservationQuery, [
    customer_id, 
    reservation_number, 
    reservation_date, 
    number_of_guests, 
    special_requests, 
    subtotal
  ], (err, reservationResult) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    const reservationId = reservationResult.insertId;
    
    // Thêm items nếu có
    if (items && items.length > 0) {
      const itemsQuery = 'INSERT INTO reservation_items (reservation_id, menu_item_id, quantity, price) VALUES ?';
      const itemsData = items.map(item => [
        reservationId,
        item.menu_item_id,
        item.quantity,
        item.price
      ]);
      
      db.query(itemsQuery, [itemsData], (err, itemsResult) => {
        if (err) {
          return res.status(500).json({ error: 'Database error', details: err.message });
        }
        
        res.status(201).json({
          success: true,
          message: 'Reservation created successfully',
          data: { 
            id: reservationId, 
            reservation_number, 
            subtotal,
            service_charge: subtotal * 0.10,
            total: subtotal + (subtotal * 0.10)
          }
        });
      });
    } else {
      res.status(201).json({
        success: true,
        message: 'Reservation created successfully',
        data: { 
          id: reservationId, 
          reservation_number, 
          subtotal: 0 
        }
      });
    }
  });
});

// Cập nhật trạng thái reservation
router.patch('/:id/status', (req, res) => {
  const { id } = req.params;
  const { status, table_number } = req.body;
  
  const validStatuses = ['pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  
  let query = 'UPDATE reservations SET status = ?';
  let params = [status];
  
  // Nếu confirm thì cần phân bàn
  if (status === 'confirmed' && table_number) {
    query += ', table_number = ?';
    params.push(table_number);
  }
  
  query += ' WHERE id = ?';
  params.push(id);
  
  db.query(query, params, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    
    res.json({
      success: true,
      message: 'Reservation status updated successfully'
    });
  });
});

// Cập nhật payment
router.patch('/:id/payment', (req, res) => {
  const { id } = req.params;
  const { payment_method, payment_status, discount } = req.body;
  
  const validPaymentMethods = ['cash', 'card', 'online'];
  const validPaymentStatuses = ['pending', 'paid', 'refunded'];
  
  if (payment_method && !validPaymentMethods.includes(payment_method)) {
    return res.status(400).json({ error: 'Invalid payment method' });
  }
  
  if (payment_status && !validPaymentStatuses.includes(payment_status)) {
    return res.status(400).json({ error: 'Invalid payment status' });
  }
  
  let query = 'UPDATE reservations SET';
  let params = [];
  let updates = [];
  
  if (payment_method) {
    updates.push(' payment_method = ?');
    params.push(payment_method);
  }
  
  if (payment_status) {
    updates.push(' payment_status = ?');
    params.push(payment_status);
  }
  
  if (discount !== undefined) {
    updates.push(' discount = ?');
    params.push(discount);
  }
  
  query += updates.join(',') + ' WHERE id = ?';
  params.push(id);
  
  db.query(query, params, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    
    // Nếu thanh toán thành công, cập nhật loyalty points
    if (payment_status === 'paid') {
      const loyaltyQuery = `
        UPDATE customers c
        JOIN reservations r ON c.id = r.customer_id
        SET c.loyalty_points = c.loyalty_points + FLOOR(r.total * 0.01)
        WHERE r.id = ?
      `;
      
      db.query(loyaltyQuery, [id], (err, loyaltyResult) => {
        if (err) {
          console.error('Error updating loyalty points:', err);
        }
      });
    }
    
    res.json({
      success: true,
      message: 'Payment information updated successfully'
    });
  });
});

// Thêm items vào reservation
router.post('/:id/items', (req, res) => {
  const { id } = req.params;
  const { items } = req.body;
  
  if (!items || items.length === 0) {
    return res.status(400).json({ error: 'Items are required' });
  }
  
  const itemsQuery = 'INSERT INTO reservation_items (reservation_id, menu_item_id, quantity, price) VALUES ?';
  const itemsData = items.map(item => [
    id,
    item.menu_item_id,
    item.quantity,
    item.price
  ]);
  
  db.query(itemsQuery, [itemsData], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    // Cập nhật subtotal
    const updateQuery = `
      UPDATE reservations 
      SET subtotal = (
        SELECT SUM(quantity * price) 
        FROM reservation_items 
        WHERE reservation_id = ?
      )
      WHERE id = ?
    `;
    
    db.query(updateQuery, [id, id], (err, updateResult) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err.message });
      }
      
      res.status(201).json({
        success: true,
        message: 'Items added to reservation successfully'
      });
    });
  });
});

// Lấy thống kê reservations
router.get('/stats/summary', (req, res) => {
  const { date } = req.query;
  
  let query = `
    SELECT 
      status,
      COUNT(*) as count,
      SUM(total) as total_revenue
    FROM reservations
  `;
  let params = [];
  
  if (date) {
    query += ' WHERE DATE(reservation_date) = ?';
    params.push(date);
  }
  
  query += ' GROUP BY status';
  
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

module.exports = router;
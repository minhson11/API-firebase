const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { mockUsers } = require('../mock_data');

// Lấy tất cả khách hàng
router.get('/', (req, res) => {
  res.json({
    success: true,
    data: mockUsers.map(user => {
      const { password, ...userWithoutPassword } = user;
      return userWithoutPassword;
    })
  });
});

// Lấy khách hàng theo ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const user = mockUsers.find(u => u.id == id && u.is_active);
  
  if (!user) {
    return res.status(404).json({ error: 'Customer not found' });
  }
  
  const { password, ...userWithoutPassword } = user;
  res.json({
    success: true,
    data: userWithoutPassword
  });
});

// Đăng ký khách hàng mới
router.post('/register', async (req, res) => {
  const { email, password, full_name, phone_number, address } = req.body;
  
  if (!email || !password || !full_name) {
    return res.status(400).json({ error: 'Email, password and full_name are required' });
  }
  
  // Kiểm tra email đã tồn tại
  if (mockUsers.find(u => u.email === email)) {
    return res.status(400).json({ error: 'Email already exists' });
  }
  
  try {
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const newUser = {
      id: mockUsers.length + 1,
      email,
      password: hashedPassword,
      full_name,
      phone_number,
      address,
      loyalty_points: 0,
      is_active: true,
      created_at: new Date()
    };
    
    mockUsers.push(newUser);
    
    const { password: _, ...userWithoutPassword } = newUser;
    
    res.status(201).json({
      success: true,
      message: 'Customer registered successfully',
      data: userWithoutPassword
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Đăng nhập
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  
  try {
    const user = mockUsers.find(u => u.email === email && u.is_active);
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const isValidPassword = await bcrypt.compare(password, user.password);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Không trả về password
    const { password: _, ...customerData } = user;
    
    res.json({
      success: true,
      message: 'Login successful',
      data: customerData
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Cập nhật thông tin khách hàng
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { full_name, phone_number, address } = req.body;
  
  const query = 'UPDATE customers SET full_name = ?, phone_number = ?, address = ? WHERE id = ? AND is_active = TRUE';
  
  db.query(query, [full_name, phone_number, address, id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }
    
    res.json({
      success: true,
      message: 'Customer updated successfully'
    });
  });
});

// Cập nhật loyalty points
router.patch('/:id/loyalty-points', (req, res) => {
  const { id } = req.params;
  const { points, operation } = req.body; // operation: 'add' or 'subtract'
  
  if (!points || !operation) {
    return res.status(400).json({ error: 'Points and operation are required' });
  }
  
  const operator = operation === 'add' ? '+' : '-';
  const query = `UPDATE customers SET loyalty_points = loyalty_points ${operator} ? WHERE id = ? AND is_active = TRUE`;
  
  db.query(query, [points, id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }
    
    res.json({
      success: true,
      message: `Loyalty points ${operation === 'add' ? 'added' : 'subtracted'} successfully`
    });
  });
});

module.exports = router;

// Cập nhật thông tin khách hàng
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { full_name, phone_number, address } = req.body;
  
  const userIndex = mockUsers.findIndex(u => u.id == id && u.is_active);
  
  if (userIndex === -1) {
    return res.status(404).json({ error: 'Customer not found' });
  }
  
  mockUsers[userIndex] = {
    ...mockUsers[userIndex],
    full_name: full_name || mockUsers[userIndex].full_name,
    phone_number: phone_number || mockUsers[userIndex].phone_number,
    address: address || mockUsers[userIndex].address
  };
  
  res.json({
    success: true,
    message: 'Customer updated successfully'
  });
});

// Cập nhật loyalty points
router.patch('/:id/loyalty-points', (req, res) => {
  const { id } = req.params;
  const { points, operation } = req.body; // operation: 'add' or 'subtract'
  
  if (!points || !operation) {
    return res.status(400).json({ error: 'Points and operation are required' });
  }
  
  const userIndex = mockUsers.findIndex(u => u.id == id && u.is_active);
  
  if (userIndex === -1) {
    return res.status(404).json({ error: 'Customer not found' });
  }
  
  if (operation === 'add') {
    mockUsers[userIndex].loyalty_points += points;
  } else if (operation === 'subtract') {
    mockUsers[userIndex].loyalty_points -= points;
  }
  
  res.json({
    success: true,
    message: `Loyalty points ${operation === 'add' ? 'added' : 'subtracted'} successfully`
  });
});

module.exports = router;
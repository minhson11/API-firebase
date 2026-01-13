const express = require('express');
const router = express.Router();
const { mockMenuItems } = require('../mock_data');

// Lấy tất cả menu items
router.get('/', (req, res) => {
  const { category, is_vegetarian, is_spicy, is_available } = req.query;
  
  let filteredItems = mockMenuItems.filter(item => {
    let matches = true;
    
    if (category) {
      matches = matches && item.category === category;
    }
    
    if (is_vegetarian !== undefined) {
      matches = matches && item.is_vegetarian === (is_vegetarian === 'true');
    }
    
    if (is_spicy !== undefined) {
      matches = matches && item.is_spicy === (is_spicy === 'true');
    }
    
    if (is_available !== undefined) {
      matches = matches && item.is_available === (is_available === 'true');
    } else {
      // Mặc định chỉ hiển thị món có sẵn
      matches = matches && item.is_available === true;
    }
    
    return matches;
  });
  
  // Sắp xếp theo category, name
  filteredItems.sort((a, b) => {
    if (a.category !== b.category) {
      return a.category.localeCompare(b.category);
    }
    return a.name.localeCompare(b.name);
  });
  
  res.json({
    success: true,
    data: filteredItems
  });
});

// Lấy menu items theo category
router.get('/category/:category', (req, res) => {
  const { category } = req.params;
  const validCategories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'];
  
  if (!validCategories.includes(category)) {
    return res.status(400).json({ error: 'Invalid category' });
  }
  
  const filteredItems = mockMenuItems.filter(item => 
    item.category === category && item.is_available === true
  ).sort((a, b) => a.name.localeCompare(b.name));
  
  res.json({
    success: true,
    data: filteredItems
  });
});

// Lấy menu item theo ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const item = mockMenuItems.find(item => item.id == id);
  
  if (!item) {
    return res.status(404).json({ error: 'Menu item not found' });
  }
  
  res.json({
    success: true,
    data: item
  });
});

// Tạo menu item mới
router.post('/', (req, res) => {
  const { 
    name, 
    description, 
    category, 
    price, 
    image_url, 
    preparation_time, 
    is_vegetarian, 
    is_spicy 
  } = req.body;
  
  const validCategories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'];
  
  if (!name || !category || !price) {
    return res.status(400).json({ error: 'Name, category and price are required' });
  }
  
  if (!validCategories.includes(category)) {
    return res.status(400).json({ error: 'Invalid category' });
  }
  
  const newItem = {
    id: mockMenuItems.length + 1,
    name,
    description,
    category,
    price,
    image_url,
    preparation_time,
    is_vegetarian: is_vegetarian || false,
    is_spicy: is_spicy || false,
    is_available: true,
    rating: 0.0,
    created_at: new Date(),
    updated_at: new Date()
  };
  
  mockMenuItems.push(newItem);
  
  res.status(201).json({
    success: true,
    message: 'Menu item created successfully',
    data: { 
      id: newItem.id, 
      name, 
      category, 
      price 
    }
  });
});

// Cập nhật menu item
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { 
    name, 
    description, 
    category, 
    price, 
    image_url, 
    preparation_time, 
    is_vegetarian, 
    is_spicy, 
    is_available 
  } = req.body;
  
  const validCategories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'];
  
  if (category && !validCategories.includes(category)) {
    return res.status(400).json({ error: 'Invalid category' });
  }
  
  const itemIndex = mockMenuItems.findIndex(item => item.id == id);
  
  if (itemIndex === -1) {
    return res.status(404).json({ error: 'Menu item not found' });
  }
  
  mockMenuItems[itemIndex] = {
    ...mockMenuItems[itemIndex],
    name: name || mockMenuItems[itemIndex].name,
    description: description || mockMenuItems[itemIndex].description,
    category: category || mockMenuItems[itemIndex].category,
    price: price || mockMenuItems[itemIndex].price,
    image_url: image_url || mockMenuItems[itemIndex].image_url,
    preparation_time: preparation_time || mockMenuItems[itemIndex].preparation_time,
    is_vegetarian: is_vegetarian !== undefined ? is_vegetarian : mockMenuItems[itemIndex].is_vegetarian,
    is_spicy: is_spicy !== undefined ? is_spicy : mockMenuItems[itemIndex].is_spicy,
    is_available: is_available !== undefined ? is_available : mockMenuItems[itemIndex].is_available,
    updated_at: new Date()
  };
  
  res.json({
    success: true,
    message: 'Menu item updated successfully'
  });
});

// Cập nhật rating
router.patch('/:id/rating', (req, res) => {
  const { id } = req.params;
  const { rating } = req.body;
  
  if (!rating || rating < 0 || rating > 5) {
    return res.status(400).json({ error: 'Rating must be between 0 and 5' });
  }
  
  const itemIndex = mockMenuItems.findIndex(item => item.id == id);
  
  if (itemIndex === -1) {
    return res.status(404).json({ error: 'Menu item not found' });
  }
  
  mockMenuItems[itemIndex].rating = rating;
  mockMenuItems[itemIndex].updated_at = new Date();
  
  res.json({
    success: true,
    message: 'Rating updated successfully'
  });
});

// Lấy thống kê menu theo category
router.get('/stats/by-category', (req, res) => {
  const categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'];
  
  const stats = categories.map(category => {
    const categoryItems = mockMenuItems.filter(item => item.category === category);
    const availableItems = categoryItems.filter(item => item.is_available);
    
    return {
      category,
      total_items: categoryItems.length,
      available_items: availableItems.length,
      avg_price: categoryItems.length > 0 ? 
        categoryItems.reduce((sum, item) => sum + item.price, 0) / categoryItems.length : 0,
      avg_rating: categoryItems.length > 0 ? 
        categoryItems.reduce((sum, item) => sum + item.rating, 0) / categoryItems.length : 0
    };
  });
  
  res.json({
    success: true,
    data: stats
  });
});

module.exports = router;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../models/menu_item_model.dart';
import '../models/reservation_model.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/menu_item_repository.dart';

class ReservationScreen extends StatefulWidget {
  final CustomerModel customer;

  const ReservationScreen({super.key, required this.customer});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationRepository _reservationRepository = ReservationRepository();
  final MenuItemRepository _menuItemRepository = MenuItemRepository();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _numberOfGuests = 2;
  final TextEditingController _specialRequestsController = TextEditingController();

  String? _currentReservationId;
  List<OrderItem> _orderItems = [];
  double _subtotal = 0;
  double _serviceCharge = 0;
  double _total = 0;

  bool _isCreatingReservation = false;
  bool _isAddingItem = false;

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createReservation() async {
    setState(() => _isCreatingReservation = true);

    try {
      DateTime reservationDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      String reservationId = await _reservationRepository.createReservation(
        widget.customer.customerId!,
        Timestamp.fromDate(reservationDateTime),
        _numberOfGuests,
        _specialRequestsController.text.isNotEmpty
            ? _specialRequestsController.text
            : null,
      );

      setState(() {
        _currentReservationId = reservationId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo đặt bàn thành công! Bây giờ hãy thêm món.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingReservation = false);
      }
    }
  }

  Future<void> _addItemToOrder(MenuItemModel item) async {
    if (_currentReservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tạo đặt bàn trước!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    if (!item.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} hiện đã hết!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isAddingItem = true);

    try {
      await _reservationRepository.addItemToReservation(
        _currentReservationId!,
        item.itemId!,
        1,
      );

      // Refresh order items
      await _refreshOrderItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${item.name} vào đơn!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingItem = false);
      }
    }
  }

  Future<void> _updateItemQuantity(String itemId, int newQuantity) async {
    try {
      await _reservationRepository.updateItemQuantity(
        _currentReservationId!,
        itemId,
        newQuantity,
      );
      await _refreshOrderItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshOrderItems() async {
    if (_currentReservationId == null) return;

    ReservationModel? reservation = await _reservationRepository.getReservationById(
      _currentReservationId!,
    );

    if (reservation != null && mounted) {
      setState(() {
        _orderItems = reservation.orderItems;
        _subtotal = reservation.subtotal;
        _serviceCharge = reservation.serviceCharge;
        _total = reservation.total;
      });
    }
  }

  Future<void> _confirmReservation() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một món!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    try {
      // Auto-assign table number
      String tableNumber = 'T${DateTime.now().millisecondsSinceEpoch % 100}';
      await _reservationRepository.confirmReservation(
        _currentReservationId!,
        tableNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt bàn đã được xác nhận! Bàn số: $tableNumber'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _currentReservationId = null;
          _orderItems = [];
          _subtotal = 0;
          _serviceCharge = 0;
          _total = 0;
          _specialRequestsController.clear();
          _numberOfGuests = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reservation form
          if (_currentReservationId == null) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin đặt bàn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date picker
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Color(0xFF3949AB)),
                      title: const Text('Ngày đặt'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: _selectDate,
                      trailing: const Icon(Icons.chevron_right),
                    ),

                    const Divider(),

                    // Time picker
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Color(0xFF3949AB)),
                      title: const Text('Giờ đặt'),
                      subtitle: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: _selectTime,
                      trailing: const Icon(Icons.chevron_right),
                    ),

                    const Divider(),

                    // Number of guests
                    ListTile(
                      leading: const Icon(Icons.people, color: Color(0xFF3949AB)),
                      title: const Text('Số khách'),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _numberOfGuests > 1
                                ? () => setState(() => _numberOfGuests--)
                                : null,
                          ),
                          Text(
                            '$_numberOfGuests',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _numberOfGuests < 20
                                ? () => setState(() => _numberOfGuests++)
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // Special requests
                    TextField(
                      controller: _specialRequestsController,
                      decoration: InputDecoration(
                        labelText: 'Yêu cầu đặc biệt (tùy chọn)',
                        hintText: 'VD: Bàn gần cửa sổ, tiệc sinh nhật...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // Create reservation button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isCreatingReservation ? null : _createReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3949AB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isCreatingReservation
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Tạo đặt bàn',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Show order info and menu to add items
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Đặt bàn đã tạo!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)} - ${_selectedTime.format(context)}',
                    ),
                    Text('Số khách: $_numberOfGuests'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order items
            if (_orderItems.isNotEmpty) ...[
              const Text(
                'Món đã chọn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orderItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    OrderItem item = _orderItems[index];
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Text(_currencyFormat.format(item.price)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _updateItemQuantity(
                              item.itemId,
                              item.quantity - 1,
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _updateItemQuantity(
                              item.itemId,
                              item.quantity + 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Totals
              Card(
                color: const Color(0xFF3949AB).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tạm tính:'),
                          Text(_currencyFormat.format(_subtotal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phí dịch vụ (10%):'),
                          Text(_currencyFormat.format(_serviceCharge)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(_total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF3949AB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận đặt bàn',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Menu to add items
            const Text(
              'Thêm món vào đơn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            StreamBuilder<List<MenuItemModel>>(
              stream: _menuItemRepository.getMenuItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<MenuItemModel> items = snapshot.data ?? [];
                List<MenuItemModel> availableItems =
                    items.where((item) => item.isAvailable).toList();

                if (availableItems.isEmpty) {
                  return const Center(
                    child: Text('Không có món nào'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    MenuItemModel item = availableItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3949AB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Color(0xFF3949AB),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          _currencyFormat.format(item.price),
                          style: const TextStyle(
                            color: Color(0xFF3949AB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: _isAddingItem
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(
                                  Icons.add_circle,
                                  color: Color(0xFF3949AB),
                                  size: 32,
                                ),
                          onPressed: _isAddingItem
                              ? null
                              : () => _addItemToOrder(item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

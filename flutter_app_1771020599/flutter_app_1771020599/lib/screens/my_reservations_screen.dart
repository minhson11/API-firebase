import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../models/reservation_model.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/customer_repository.dart';

class MyReservationsScreen extends StatefulWidget {
  final CustomerModel customer;

  const MyReservationsScreen({super.key, required this.customer});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationRepository _reservationRepository = ReservationRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'seated':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'seated':
        return 'Đang dùng bữa';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no_show':
        return 'Không đến';
      default:
        return status;
    }
  }

  void _showReservationDetail(ReservationModel reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 32,
                      color: const Color(0xFF3949AB),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chi tiết đặt bàn',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(reservation.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(reservation.status),
                              style: TextStyle(
                                color: _getStatusColor(reservation.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Info
                _buildInfoRow(
                  Icons.calendar_today,
                  'Ngày',
                  DateFormat('dd/MM/yyyy HH:mm').format(
                    reservation.reservationDate.toDate(),
                  ),
                ),
                _buildInfoRow(
                  Icons.people,
                  'Số khách',
                  '${reservation.numberOfGuests} người',
                ),
                if (reservation.tableNumber != null)
                  _buildInfoRow(
                    Icons.table_restaurant,
                    'Bàn số',
                    reservation.tableNumber!,
                  ),
                if (reservation.specialRequests != null &&
                    reservation.specialRequests!.isNotEmpty)
                  _buildInfoRow(
                    Icons.note,
                    'Yêu cầu đặc biệt',
                    reservation.specialRequests!,
                  ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Order items
                const Text(
                  'Món đã đặt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (reservation.orderItems.isEmpty)
                  const Text(
                    'Chưa có món nào',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...reservation.orderItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.itemName} x${item.quantity}',
                              ),
                            ),
                            Text(
                              _currencyFormat.format(item.subtotal),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Totals
                _buildTotalRow('Tạm tính', reservation.subtotal),
                _buildTotalRow('Phí dịch vụ (10%)', reservation.serviceCharge),
                if (reservation.discount > 0)
                  _buildTotalRow('Giảm giá', -reservation.discount, isDiscount: true),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(reservation.total),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3949AB),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Loyalty points info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Điểm tích lũy hiện có',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.customer.loyaltyPoints} điểm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment button (only for seated status)
                if (reservation.status == 'seated' &&
                    reservation.paymentStatus == 'pending')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _showPaymentDialog(reservation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Thanh toán',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                // Cancel button (only for pending status)
                if (reservation.status == 'pending')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _cancelReservation(reservation),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy đặt bàn',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isDiscount
                ? '- ${_currencyFormat.format(amount.abs())}'
                : _currencyFormat.format(amount),
            style: TextStyle(
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(ReservationModel reservation) {
    String selectedMethod = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chọn phương thức thanh toán'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReservationModel.paymentMethods.map((method) {
              String label;
              IconData icon;
              switch (method) {
                case 'cash':
                  label = 'Tiền mặt';
                  icon = Icons.money;
                  break;
                case 'card':
                  label = 'Thẻ';
                  icon = Icons.credit_card;
                  break;
                case 'online':
                  label = 'Chuyển khoản';
                  icon = Icons.phone_android;
                  break;
                default:
                  label = method;
                  icon = Icons.payment;
              }

              return RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
                value: method,
                groupValue: selectedMethod,
                onChanged: (value) {
                  setDialogState(() => selectedMethod = value!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processPayment(reservation, selectedMethod);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
              ),
              child: const Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(ReservationModel reservation, String paymentMethod) async {
    try {
      await _reservationRepository.payReservation(
        reservation.reservationId!,
        paymentMethod,
      );

      // Refresh customer data
      CustomerModel? updatedCustomer = await _customerRepository.getCustomerById(
        widget.customer.customerId!,
      );

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán thành công! Điểm tích lũy: ${updatedCustomer?.loyaltyPoints ?? 0}',
            ),
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
    }
  }

  Future<void> _cancelReservation(ReservationModel reservation) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc muốn hủy đặt bàn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy đặt bàn'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reservationRepository.cancelReservation(reservation.reservationId!);

        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy đặt bàn!'),
              backgroundColor: Colors.amber,
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReservationModel>>(
      stream: _reservationRepository.getReservationsByCustomerStream(
        widget.customer.customerId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
              ],
            ),
          );
        }

        List<ReservationModel> reservations = snapshot.data ?? [];

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có đặt bàn nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            ReservationModel reservation = reservations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _showReservationDetail(reservation),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: const Color(0xFF3949AB),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(
                                  reservation.reservationDate.toDate(),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(reservation.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(reservation.status),
                              style: TextStyle(
                                color: _getStatusColor(reservation.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${reservation.numberOfGuests} khách',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          if (reservation.tableNumber != null) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.table_restaurant, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Bàn ${reservation.tableNumber}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${reservation.orderItems.length} món',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            _currencyFormat.format(reservation.total),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF3949AB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

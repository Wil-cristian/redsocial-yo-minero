import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/shared/models/service_booking.dart';
import 'package:yominero/features/bookings/domain/booking_repository.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  final _bookingRepo = sl<BookingRepository>();
  late TabController _tabController;
  
  List<ServiceBooking> _myBookings = [];
  List<ServiceBooking> _providerBookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    
    try {
      final myBookings = await _bookingRepo.getMyBookings();
      final providerBookings = await _bookingRepo.getBookingsAsProvider();
      
      if (mounted) {
        setState(() {
          _myBookings = myBookings;
          _providerBookings = providerBookings;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmBooking(ServiceBooking booking) async {
    try {
      await _bookingRepo.confirmBooking(booking.id);
      _loadBookings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reserva confirmada exitosamente'),
            backgroundColor: AppColorsUnified.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(ServiceBooking booking) async {
    final reason = await _showCancelDialog();
    if (reason == null) return;
    
    try {
      await _bookingRepo.cancelBooking(booking.id, reason);
      _loadBookings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reserva cancelada'),
            backgroundColor: AppColorsUnified.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  Future<String?> _showCancelDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Motivo de cancelación',
            hintText: 'Opcional',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.error,
            ),
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: AppColorsUnified.gold,
        foregroundColor: AppColorsUnified.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColorsUnified.textPrimary,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          indicatorColor: AppColorsUnified.textPrimary,
          tabs: const [
            Tab(text: 'Como Cliente'),
            Tab(text: 'Como Proveedor'),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColorsUnified.gold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(_myBookings, isProvider: false),
                _buildBookingsList(_providerBookings, isProvider: true),
              ],
            ),
    );
  }

  Widget _buildBookingsList(List<ServiceBooking> bookings, {required bool isProvider}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColorsUnified.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes reservas',
              style: TextStyle(
                fontSize: 16,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColorsUnified.gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index], isProvider: isProvider);
        },
      ),
    );
  }

  Widget _buildBookingCard(ServiceBooking booking, {required bool isProvider}) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    // ignore: unused_local_variable
    final currentUserId = SupabaseAuthService.instance.currentUser?.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              children: [
                _buildStatusChip(booking.status),
                const Spacer(),
                Text(
                  dateFormat.format(booking.bookingDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Nombre del servicio
            Row(
              children: [
                Icon(Icons.miscellaneous_services, color: AppColorsUnified.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.serviceName ?? 'Servicio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Horario
            Row(
              children: [
                Icon(Icons.access_time, color: AppColorsUnified.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${booking.startTime.substring(0, 5)} - ${booking.endTime.substring(0, 5)} (${booking.durationHours}hrs)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Cliente o Proveedor info
            Row(
              children: [
                Icon(
                  isProvider ? Icons.person : Icons.business,
                  color: AppColorsUnified.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isProvider 
                      ? 'Cliente: ${booking.clientName ?? booking.clientUsername ?? 'N/A'}'
                      : 'Proveedor: ${booking.providerName ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
            
            // Ubicación
            if (booking.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColorsUnified.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Precio
            if (booking.totalPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, color: AppColorsUnified.gold, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '\$${booking.totalPrice!.toStringAsFixed(2)} ${booking.currency}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorsUnified.gold,
                    ),
                  ),
                ],
              ),
            ],
            
            // Notas
            if (booking.clientNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas del cliente:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.clientNotes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColorsUnified.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Acciones
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isProvider) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmBooking(booking),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsUnified.success,
                          side: BorderSide(color: AppColorsUnified.success),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(booking),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColorsUnified.error,
                        side: BorderSide(color: AppColorsUnified.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case BookingStatus.pending:
        backgroundColor = AppColorsUnified.warning.withOpacity(0.2);
        textColor = AppColorsUnified.warning;
        icon = Icons.pending;
        break;
      case BookingStatus.confirmed:
        backgroundColor = AppColorsUnified.success.withOpacity(0.2);
        textColor = AppColorsUnified.success;
        icon = Icons.check_circle;
        break;
      case BookingStatus.cancelled:
        backgroundColor = AppColorsUnified.error.withOpacity(0.2);
        textColor = AppColorsUnified.error;
        icon = Icons.cancel;
        break;
      case BookingStatus.completed:
        backgroundColor = AppColorsUnified.gold.withOpacity(0.2);
        textColor = AppColorsUnified.gold;
        icon = Icons.done_all;
        break;
      case BookingStatus.rejected:
        backgroundColor = AppColorsUnified.grey300;
        textColor = AppColorsUnified.textSecondary;
        icon = Icons.block;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

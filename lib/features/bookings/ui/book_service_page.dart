import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/shared/models/service_booking.dart';
import 'package:yominero/features/bookings/domain/booking_repository.dart';
import 'package:yominero/core/di/locator.dart';

class BookServicePage extends StatefulWidget {
  final Service service;

  const BookServicePage({super.key, required this.service});

  @override
  State<BookServicePage> createState() => _BookServicePageState();
}

class _BookServicePageState extends State<BookServicePage> {
  final _bookingRepo = sl<BookingRepository>();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TimeSlot> _availableSlots = [];
  TimeSlot? _selectedSlot;
  bool _loadingSlots = false;
  
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  
  double _durationHours = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAvailableSlots(_focusedDay);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() => _loadingSlots = true);
    
    try {
      final slots = await _bookingRepo.getAvailableSlots(
        serviceId: widget.service.id,
        bookingDate: date,
        slotDuration: _durationHours,
      );
      
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _selectedSlot = null;
          _loadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando disponibilidad: $e')),
        );
      }
    }
  }

  Future<void> _createBooking() async {
    if (_selectedDay == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y horario')),
      );
      return;
    }

    try {
      final totalPrice = widget.service.pricingFrom != null 
          ? widget.service.pricingFrom! * _durationHours
          : null;

      await _bookingRepo.createBooking(
        serviceId: widget.service.id,
        bookingDate: _selectedDay!,
        startTime: _selectedSlot!.startTime,
        endTime: _selectedSlot!.endTime,
        durationHours: _durationHours,
        clientNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        totalPrice: totalPrice,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColorsUnified.pureWhite),
                const SizedBox(width: 8),
                const Text('¡Reserva creada! Esperando confirmación del proveedor'),
              ],
            ),
            backgroundColor: AppColorsUnified.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      body: CustomScrollView(
        slivers: [
          // App Bar moderno
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColorsUnified.charcoal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsUnified.companyBlue,
                      AppColorsUnified.companyBlue.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(72, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: AppColorsUnified.gold),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.service.priceDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendario
                _buildCalendar(),
                
                // Duración
                _buildDurationSelector(),
                
                // Horarios disponibles
                _buildTimeSlots(),
                
                // Detalles adicionales
                _buildAdditionalDetails(),
                
                // Botón de reserva
                _buildBookButton(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColorsUnified.charcoal,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColorsUnified.companyBlue),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColorsUnified.companyBlue),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColorsUnified.companyBlue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColorsUnified.companyBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              todayTextStyle: TextStyle(color: AppColorsUnified.companyBlue, fontWeight: FontWeight.w600),
              defaultTextStyle: TextStyle(color: AppColorsUnified.charcoal),
              weekendTextStyle: TextStyle(color: AppColorsUnified.orange),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadAvailableSlots(selectedDay);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duración del servicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColorsUnified.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColorsUnified.companyBlue,
                    inactiveTrackColor: AppColorsUnified.grey200,
                    thumbColor: AppColorsUnified.companyBlue,
                    overlayColor: AppColorsUnified.companyBlue.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _durationHours,
                    min: 0.5,
                    max: 8.0,
                    divisions: 15,
                    onChanged: (value) {
                      setState(() => _durationHours = value);
                      if (_selectedDay != null) {
                        _loadAvailableSlots(_selectedDay!);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColorsUnified.companyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_durationHours.toStringAsFixed(1)} hrs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColorsUnified.companyBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimado:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              Text(
                widget.service.pricingFrom != null
                    ? '\$${(widget.service.pricingFrom! * _durationHours).toStringAsFixed(2)}'
                    : '\$0.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColorsUnified.charcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: AppColorsUnified.companyBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Horarios disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColorsUnified.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingSlots)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColorsUnified.companyBlue,
                ),
              ),
            )
          else if (_availableSlots.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: AppColorsUnified.grey400),
                    const SizedBox(height: 12),
                    Text(
                      'No hay horarios disponibles para este día',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColorsUnified.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.where((slot) => slot.isAvailable).map((slot) {
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColorsUnified.companyBlue
                          : AppColorsUnified.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColorsUnified.companyBlue
                            : AppColorsUnified.grey300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      slot.startTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected 
                            ? Colors.white
                            : AppColorsUnified.charcoal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles adicionales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColorsUnified.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Ubicación',
              hintText: 'Dirección donde se realizará el servicio',
              prefixIcon: Icon(Icons.location_on, color: AppColorsUnified.companyBlue),
              filled: true,
              fillColor: AppColorsUnified.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColorsUnified.companyBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notas para el proveedor',
              hintText: 'Información adicional sobre tu solicitud',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Icon(Icons.notes, color: AppColorsUnified.companyBlue),
              ),
              filled: true,
              fillColor: AppColorsUnified.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColorsUnified.companyBlue, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    final canBook = _selectedDay != null && _selectedSlot != null;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        color: canBook 
            ? AppColorsUnified.companyBlue
            : AppColorsUnified.grey300,
        borderRadius: BorderRadius.circular(16),
        elevation: canBook ? 4 : 0,
        child: InkWell(
          onTap: canBook ? _createBooking : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Confirmar Reserva',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

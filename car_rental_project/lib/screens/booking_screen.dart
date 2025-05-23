import 'package:car_rental_project/models/car_model.dart';
import 'package:car_rental_project/models/rental_model.dart';
import 'package:car_rental_project/paymob_manager/paymob_manager.dart';
import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/services/NotificationService.dart';
import 'package:car_rental_project/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0.0;
  bool isPaid = false;
  final _formKey = GlobalKey<FormState>();

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  Future<void> _pay() async {
    PaymobManager().getPaymentKey(_totalPrice, "EGP").then((String paymentKey) {
      launchUrl(Uri.parse(
          "https://accept.paymob.com/api/acceptance/iframes/895291?payment_token=$paymentKey"));
      // .then((_) {
      //   // // After successful payment, mark it as paid
      //   // setState(() {
      //   //   isPaid = true;  // Update isPaid to true after successful payment
      //   // });
      // }
      // );
    });
  }

  late List<DateTime> _bookedDates;
  void _debugPrintBookedDates() {
    debugPrint('=== Debug Booked Dates ===');
    for (int i = 0; i < _bookedDates.length; i += 2) {
      DateTime start = _bookedDates[i];
      DateTime? end = i + 1 < _bookedDates.length ? _bookedDates[i + 1] : null;
      debugPrint(
          'Range ${i ~/ 2}: ${start.toString()} to ${end?.toString() ?? 'N/A'}');
    }
  }

  @override
  void initState() {
    super.initState();
    _bookedDates = widget.car.bookedDates ?? [];
    if (_bookedDates.length % 2 != 0) {
      _bookedDates.removeLast();
    }
    _debugPrintBookedDates();
  }

  bool _isBooked(DateTime day) {
    final DateTime dateToCheck = DateTime(day.year, day.month, day.day);

    debugPrint('Checking if date is booked: $dateToCheck');

    if (_bookedDates.isEmpty) {
      debugPrint('No booked dates available');
      return false;
    }

    for (int i = 0; i < _bookedDates.length; i += 2) {
      DateTime start = DateTime(
        _bookedDates[i].year,
        _bookedDates[i].month,
        _bookedDates[i].day,
      );
      DateTime end = DateTime(
        _bookedDates[i + 1].year,
        _bookedDates[i + 1].month,
        _bookedDates[i + 1].day,
      );

      debugPrint('Comparing with range: $start to $end');

      if (dateToCheck.isAtSameMomentAs(start) ||
          dateToCheck.isAtSameMomentAs(end) ||
          (dateToCheck.isAfter(start) && dateToCheck.isBefore(end))) {
        debugPrint('Date $dateToCheck is booked');
        return true;
      }
    }

    debugPrint('Date $dateToCheck is not booked');
    return false;
  }

  Future<DateTime?> _showDatePickerDialog({
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? focusedDay,
  }) async {
    try {
      if (focusedDay == null || focusedDay.isBefore(firstDate)) {
        focusedDay = firstDate;
      } else if (focusedDay.isAfter(lastDate)) {
        focusedDay = lastDate;
      }

      return await showDialog<DateTime>(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: TableCalendar(
                firstDay: firstDate,
                lastDay: lastDate,
                focusedDay: focusedDay!,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.black87),
                  weekendTextStyle: TextStyle(color: Colors.black87),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  disabledTextStyle: TextStyle(color: Colors.grey),
                  disabledDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                enabledDayPredicate: (day) {
                  // Convert to start of day for consistent comparison
                  final today = DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day);
                  final checkDay = DateTime(day.year, day.month, day.day);

                  // Check if the day is within the available range AND not before today
                  return !checkDay.isBefore(today) &&
                      !checkDay.isBefore(widget.car.availableFrom!) &&
                      !checkDay.isAfter(widget.car.availableTo!);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    bool isToday = isSameDay(day, DateTime.now());
                    bool isBooked = _isBooked(day);

                    // Check if date is before today or outside available range
                    bool isDisabled = day.isBefore(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        )) ||
                        day.isBefore(widget.car.availableFrom!) ||
                        day.isAfter(widget.car.availableTo!);

                    // Handle outdated and disabled dates
                    if (isDisabled) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }

                    // Prioritize today's date
                    if (isToday) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }

                    // Handle booked and available dates
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isBooked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!_isBooked(selectedDay)) {
                    Navigator.pop(context, selectedDay);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This date is already booked!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error in showing date picker dialog: $e');
      return null;
    }
  }

  void _selectStartDate() async {
    debugPrint(
        'Selecting start date...'); // Log the start date selection process
    DateTime? pickedDate = await _showDatePickerDialog(
      firstDate: widget.car.availableFrom!,
      lastDate: widget.car.availableTo!,
      focusedDay: _startDate,
    );

    if (pickedDate != null && pickedDate != _startDate) {
      debugPrint('Picked start date: $pickedDate'); // Log the picked start date
      setState(() {
        _startDate = pickedDate;
        _endDate = null;
        _calculateTotalPrice();
      });
    }
  }

  void _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }

    debugPrint(
        'Selecting end date, start date: $_startDate'); // Log when selecting end date
    DateTime? pickedDate = await _showDatePickerDialog(
      firstDate: _startDate!,
      lastDate: widget.car.availableTo!,
      focusedDay: _endDate,
    );

    if (pickedDate != null && pickedDate.isAfter(_startDate!)) {
      debugPrint('Picked end date: $pickedDate'); // Log the picked end date
      setState(() {
        _endDate = pickedDate;
        _calculateTotalPrice();
      });
    }
  }

  void _calculateTotalPrice() {
    debugPrint('Calculating total price'); // Log when calculating price
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!).inDays + 1;
      debugPrint('Rental duration: $duration days'); // Log duration
      setState(() {
        _totalPrice = widget.car.price * duration;
        debugPrint('Total price: $_totalPrice'); // Log price calculation result
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete payment first.')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book a car.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }

    // Submit booking details and perform the necessary actions
    final sellerRef = widget.car.seller;
    final sellerId = sellerRef.id;

    if (sellerId == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot rent your own car.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final buyerRef =
        FirebaseFirestore.instance.collection('users').doc(user.id);
    final carRef =
        FirebaseFirestore.instance.collection('Cars').doc(widget.car.id);
    final rentalProvider = Provider.of<RentalProvider>(context, listen: false);

    try {
      await rentalProvider.addRental(
        RentalModel(
          car: carRef,
          buyerRef: buyerRef,
          startDate: _startDate!,
          endDate: _endDate!,
          totalPrice: _totalPrice,
        ),
      );

      DateTime notificationTime = _endDate!.subtract(Duration(hours: 1));
      await NotificationService.showImmediateNotification(widget.car.name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental booked successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Booking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          "Book",
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey[300] : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car details card
              Card(
                elevation: 5,
                color: isDarkMode ? Colors.grey[900] : Color(0XFF97B3AE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book: ${widget.car.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.white, // Changed from deepPurple
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.car_rental,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.white), // Changed from deepPurple
                          const SizedBox(width: 10),
                          Text(
                            '\$${widget.car.price}/day',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color:
                                  isDarkMode ? Colors.grey[300] : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Color legend
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.blueGrey, 'Today'),
                      _buildLegendItem(
                          const Color.fromARGB(255, 210, 48, 48), 'Booked'),
                      _buildLegendItem(Colors.green.shade400, 'Available'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Date selection and pricing
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Start Date Selection
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: _buildReadOnlyInputField('Start Date', _startDate,
                          icon: (Icons.calendar_today)),
                    ),
                    const SizedBox(height: 20),
                    // End Date Selection
                    GestureDetector(
                      onTap: _selectEndDate,
                      child: _buildReadOnlyInputField('End Date', _endDate,
                          icon: Icons.calendar_today),
                    ),
                    const SizedBox(height: 20),
                    // Total Price Display
                    Card(
                      color: isDarkMode ? Colors.grey[900] : Color(0XFF97B3AE),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.white, // Changed from deepPurple
                              ),
                            ),
                            Text(
                              _totalPrice > 0
                                  ? '\$${_totalPrice.toStringAsFixed(2)}'
                                  : 'Select dates',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.white, // Changed from deepPurple
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Confirm and Book Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.grey.shade800,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // "Pay" Button
                          ElevatedButton(
                            onPressed: () async {
                              if (isPaid) {
                                // If already paid, proceed with booking
                                await _submitBooking();
                              } else {
                                // If not paid, trigger the payment process
                                await _pay();
                                await Future.delayed(Duration(seconds: 15));
                                setState(() {
                                  isPaid = true;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.grey[300]
                                  : Color(0XFF97B3AE),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isPaid ? 'Confirmed Booking' : 'Pay Now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildReadOnlyInputField(String label, DateTime? date,
      {IconData? icon}) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        // When a date is selected, show it as the label
        labelText: date != null ? '$label: ${_dateFormat.format(date)}' : label,
        // If no date is selected, show hint
        hintText: date == null ? 'Select date' : null,
        prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        // Change label style when a date is selected
        labelStyle: TextStyle(
          color: date != null ? Colors.black : Colors.grey,
          fontSize: 16,
          fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

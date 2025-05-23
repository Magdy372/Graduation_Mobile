import 'package:car_rental_project/providers/rental_provider.dart';
import 'package:car_rental_project/screens/edit_profile_screen.dart';
import 'package:car_rental_project/screens/settings_screen.dart';
import 'package:car_rental_project/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_project/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/car_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return const Scaffold(
      body: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Delay the data fetching to happen after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }



  void _fetchUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.id ?? '';

    if (userId.isNotEmpty) {
      final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      
      // Fetch data
      rentalProvider.fetchRentalsByUser(userId);
      carProvider.getUserCars(userId);
    }
  }

  



  void showRatingDialog(BuildContext context, String carId, CarProvider carProvider) {
  double rating = 0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rate this car'),
        content: RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (newRating) {
            rating = newRating;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await carProvider.rateCar(carId, rating);
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

  // Rest of your existing code remains the same
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: isDarkMode? Colors.black:Colors.white,title: Text("Profile", style: GoogleFonts.poppins(color:isDarkMode? Colors.grey[300]:const Color(0XFF97B3AE)),)),
        body: const Center(child: Text("User not logged in")),
      );
    }
    return Scaffold(
      appBar: AppBar(
      backgroundColor: isDarkMode? Colors.black:Colors.white,
      title: Text(
        'Profile',
        style: GoogleFonts.poppins(
          color:isDarkMode? Colors.grey[300]:Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: isDarkMode? Colors.grey[300]:Colors.black),
          onPressed: () {
            // Handle edit action, e.g., navigate to edit profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          },
        ),
      ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(user.name, user.email),
          const SizedBox(height: 20),
          _buildUserInfo(user.phone ?? "", user.address ?? ""),
          const SizedBox(height: 20),
          _buildUserCars(),
          const SizedBox(height: 20),
          _buildRecentRentals(),
          const SizedBox(height: 20),

          const SizedBox(height: 20),
          // Cards Section
          // _buildCard(
          //   icon: Icons.discount_outlined,
          //   title: '100% off 1st Ride',
          //   subtitle: 'Discover luxury rides - Terms apply',
          // ),
          // _buildCard(
          //   icon: Icons.person_add_alt_1_outlined,
          //   title: 'Invite Friends',
          //   subtitle: 'Each of you gets 30% off your next ride',
          // ),
          // _buildCard(
          //   icon: Icons.security_outlined,
          //   title: 'Safety Checkup',
          //   subtitle: 'Boost your safety profile',
          //   progress: 0.5,
          // ),
          const SizedBox(height: 20), // Added spacing before the payment method
          // _buildPaymentMethodOption(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),

    );
  }

  // Profile header with user photo, name, and email
  Widget _buildProfileHeader(String name, String email) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Icon(
            Icons.account_circle, // Profile icon
            size: 120, // Icon size
            color:isDarkMode? Colors.grey[300]:const Color(0XFF97B3AE) // Icon color
          ),
          const SizedBox(height: 10),
          Text(
            name, // Use the passed name
            style:  GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDarkMode? Colors.grey[300]:Colors.black,
            ),
          ),
          Text(
            email, // Use the passed email
            style:  GoogleFonts.poppins(
              fontSize: 16,
              color:isDarkMode? Colors.grey[300]:Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String phone, String address) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDarkMode? Colors.grey[900]:Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "User Information",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode? Colors.grey[300]:Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "Phone Number",
                  style: GoogleFonts.poppins(color: isDarkMode? Colors.grey[300]:Colors.black),
                ),
                Text(
                  phone.isNotEmpty ? phone : "N/A",
                  style:  GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode? Colors.grey[300]:Colors.black,
                  ),
                ),
              ],
            ),
             Divider(color: isDarkMode? Colors.grey[300]:const Color(0XFF97B3AE)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "Address",
                  style: GoogleFonts.poppins(color:isDarkMode? Colors.grey[300]:Colors.black),
                ),
                Flexible(
                  child: Text(
                    address.isNotEmpty ? address : "N/A",
                    textAlign: TextAlign.end,
                    style:  GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode? Colors.grey[300]:Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCars() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Consumer<CarProvider>(
    builder: (context, carProvider, child) {
      final userCars = carProvider.carsbysuser;

      if (userCars.isEmpty) {
        return const Center(child: Text("You have no cars uploaded."));
      }

      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Cars",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Display cars owned by the user
              for (var car in userCars)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Car brand and name
                      Text(
                        "${car.brand.toString().split('.').last} - ${car.name}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDarkMode ? Colors.grey[300] : Colors.black,
                        ),
                      ),
                      // Car availability status and delete button
                      FutureBuilder<bool>(
                        future: carProvider.isCarInRental(car.id), // Check if car is rented
                        builder: (context, snapshot) {
                          final isBooked = snapshot.data ?? false;

                          return Row(
                            children: [
                              Text(
                                isBooked ? "Booked" : "Available",
                                style: GoogleFonts.poppins(
                                  color: isBooked ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10), // Spacing between status and delete button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red, // Red color for delete icon
                                ),
                                onPressed: () async {
                                  if (isBooked) {
                                    // If car is booked, show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("You cannot delete the car as it is booked."),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  } else {
                                    // Show a confirmation dialog before deleting
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Delete Car"),
                                        content: const Text("Are you sure you want to delete this car?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    // If user confirms deletion, delete the car
                                    if (confirmDelete == true) {
                                      await carProvider.deleteCar(car.id);

                                      // Show a SnackBar with an Undo action
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Car deleted"),
                                          action: SnackBarAction(
                                            label: "Undo",
                                            onPressed: () async {
                                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                                              final user = userProvider.currentUser;
                                              await carProvider.restoreCar(user!);
                                            },
                                          ),
                                          duration: const Duration(seconds: 5), // SnackBar duration
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      );
    },
  );
}
// Recent Rentals Display
Widget _buildRecentRentals() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Consumer<RentalProvider>(
    builder: (context, rentalProvider, child) {
      final recentRentals = rentalProvider.rentalsForUser;

      if (recentRentals.isEmpty) {
        return const Center(child: Text("No recent rentals found."));
      }

      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recent Rentals",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              for (var rental in recentRentals)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Car Name',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: isDarkMode ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final carName = rental.id != null
                                  ? rentalProvider.carNames[rental.id]
                                  : null;
                              debugPrint('Rental ${rental.id}: Car name: $carName'); // Debug print
                              return Text(
                                carName ?? 'Unknown Car',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: isDarkMode ? Colors.grey[300] : Colors.black,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Label and rental duration
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Number of Days', // Label for the number of days
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: isDarkMode ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                          Text(
                            "${rental.endDate.difference(rental.startDate).inDays} days", // Display the number of days
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: isDarkMode ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Rating and Remove buttons
                      Row(
                        children: [
                          // Rate Button
                          IconButton(
                            icon: const Icon(Icons.star_border),
                            onPressed: () {
                              final carId = rental.car.id; // Get the carId directly from the rental
                              showRatingDialog(
                                context,
                                carId,
                                Provider.of<CarProvider>(context, listen: false),
                              );
                            },
                          ),
                          // Remove Button
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              // Show a confirmation dialog before deleting
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Rental"),
                                  content: const Text("Are you sure you want to delete this rental?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              // If user confirms deletion, delete the rental
                              if (confirmDelete == true) {
                                await rentalProvider.deleteRental(rental.id!);

                                // Show a SnackBar with an Undo action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Rental deleted"),
                                    action: SnackBarAction(
                                      label: "Undo",
                                      onPressed: () async {
                                        // Restore the rental (if needed)
                                        // Note: You may need to implement a restoreRental method in the provider
                                      },
                                    ),
                                    duration: const Duration(seconds: 5), // SnackBar duration
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

  // Helper function to create settings options
  // Widget _buildSettingsOption(
  //     String title, IconData icon, BuildContext context) {
  //   return ListTile(
  //     leading: Icon(icon, color: Colors.black),
  //     title: Text(title, style: const GoogleFonts.poppins(color: Colors.black)),
  //     onTap: () {
  //       // Handle navigation or actions
  //     },
  //   );
  // }

  // Payment method option at the end
  // Widget _buildPaymentMethodOption(BuildContext context) {
  //   return Card(
  //     elevation: 5,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     color: Colors.white,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: ListTile(
  //         leading: const Icon(Icons.payment, color: Colors.black),
  //         title: const Text('Payment Methods',
  //             style: GoogleFonts.poppins(color: Colors.black)),
  //         onTap: () {
  //           // Handle payment methods navigation
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Card Widget for the new Cards Section
  // Widget _buildCard(
  //     {required IconData icon,
  //     required String title,
  //     required String subtitle,
  //     double progress = 0.0}) {
  //   return Card(
  //     elevation: 5,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     color: Colors.white,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(icon, color: Colors.blue[800], size: 28),
  //               const SizedBox(width: 10),
  //               Text(
  //                 title,
  //                 style: const GoogleFonts.poppins(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 10),
  //           Text(subtitle, style: const GoogleFonts.poppins(color: Colors.black54)),
  //           if (progress > 0.0) const SizedBox(height: 10),
  //           if (progress > 0.0) LinearProgressIndicator(value: progress),
  //         ],
  //       ),
  //     ),
  //   );
  // }


      // Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : const Color(0XFF97B3AE),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: GNav(
            color: isDarkMode ? Colors.grey[300] : Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.white.withOpacity(0.30),
            padding: const EdgeInsets.all(12),
            gap: 5,
            selectedIndex:
                2, // Set the default selected index to 1 (Notifications tab)
            onTabChange: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                  break;
              }
            },
            tabs: const [
              GButton(icon: Icons.home),
              GButton(icon: Icons.notifications),
              GButton(icon: Icons.person),
              GButton(icon: Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
}
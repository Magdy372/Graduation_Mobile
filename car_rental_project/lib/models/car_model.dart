import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  String id;
  final String name;
  final Brand brand;
  final double price;
  final String image;
   double rating;
  final double horsepower;
  final double acceleration;
  final double tankCapacity;
  final int topSpeed;
  final String description;
  final BodyType bodyType;
  final TransmissionType transmissionType;
  final List<Feature> features;
   DocumentReference seller;
   final double latitude; // Added field
  final double longitude;
  double? distance;
  bool isBooked;
  DateTime? availableFrom;
  DateTime? availableTo;
  List<DateTime> bookedDates;
  List<double> ratings; // Add this line

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
    required this.bodyType,
    required this.transmissionType,
    required this.horsepower,
    required this.acceleration,
    required this.tankCapacity,
    required this.topSpeed,
    required this.features,
    required this.seller,
     required this.latitude, // Initialize latitude
    required this.longitude,
    this.distance,
    this.isBooked = false,
    this.availableFrom,
    this.availableTo,
    this.bookedDates = const [],
    this.ratings = const [], // Add this line
  });

    static String? validateCarData({
    required String name,
    required String price,
    required String horsepower,
    required String acceleration,
    required String tankCapacity,
    required String topSpeed,
    required BodyType? bodyType,
    required TransmissionType? transmissionType,
    required List<Feature> features,
    required String description,
    required DateTime? availableFrom,
    required DateTime? availableTo,
    required String latitude,
    required String longitude,
    required String? imageFile,
  }) {
   // if (imageFile.isEmpty) return 'Car image is required';
    if (name.isEmpty) return 'Car name is required';
    if (price.isEmpty) return 'Price is required';
    if (horsepower.isEmpty) return 'Horsepower is required';
    if (acceleration.isEmpty) return 'Acceleration is required';
    if (tankCapacity.isEmpty) return 'Tank capacity is required';
    if (topSpeed.isEmpty) return 'Top speed is required';
    if (bodyType == null) return 'Body type is required';
    if (transmissionType == null) return 'Transmission type is required';
    if (features.isEmpty) return 'At least one feature is required';
    if (description.isEmpty) return 'Description is required';
    if (latitude.isEmpty) return 'Location is required';
    if (longitude.isEmpty) return 'Location is required';
    if (imageFile==null) return 'Car image is required';

     if (availableFrom == null) return 'Available from date is required';
  if (availableTo == null) return 'Available to date is required';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day); // Remove time part

  // Check if availableFrom is today or later
  if (availableFrom.isBefore(today)) {
    return 'Available from date must be today or later';
  }

  // Check if availableTo is after availableFrom
  if (availableTo.isBefore(availableFrom) || availableTo.isAtSameMomentAs(availableFrom)) {
    return 'Available to date must be after available from date';
  }

    return null; // Return null if all validations pass
  }

  // Validation function to check if the price is a valid number
  static String? validatePrice(String price) {
    if (price.isEmpty) return 'Price is required';
    if (double.tryParse(price) == null) return 'Invalid price format';
    return null;
  }

  // Validation function to check if the horsepower is a valid number
  static String? validateHorsepower(String horsepower) {
    if (horsepower.isEmpty) return 'Horsepower is required';
    if (double.tryParse(horsepower) == null) return 'Invalid horsepower format';
    return null;
  }

  // Validation function to check if the acceleration is a valid number
  static String? validateAcceleration(String acceleration) {
    if (acceleration.isEmpty) return 'Acceleration is required';
    if (double.tryParse(acceleration) == null) return 'Invalid acceleration format';
    return null;
  }

  // Validation function to check if the tank capacity is a valid number
  static String? validateTankCapacity(String tankCapacity) {
    if (tankCapacity.isEmpty) return 'Tank capacity is required';
    if (double.tryParse(tankCapacity) == null) return 'Invalid tank capacity format';
    return null;
  }

  // Validation function to check if the top speed is a valid number
  static String? validateTopSpeed(String topSpeed) {
    if (topSpeed.isEmpty) return 'Top speed is required';
    if (int.tryParse(topSpeed) == null) return 'Invalid top speed format';
    return null;
  }

  // Validation function to check if the latitude and longitude are valid numbers
  static String? validateLocation(String latitude, String longitude) {
    if (latitude.isEmpty) return 'Latitude is required';
    if (longitude.isEmpty) return 'Longitude is required';
    if (double.tryParse(latitude) == null) return 'Invalid latitude format';
    if (double.tryParse(longitude) == null) return 'Invalid longitude format';
    return null;
  }



  // Add this method to calculate the average rating
  double get averageRating {
    if (ratings.isEmpty) return 0.0; // Return 0 if there are no ratings
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  bool isDateBooked(DateTime date) {
    return bookedDates.any((bookedDate) => bookedDate.isAtSameMomentAs(date));
  }

  static String _enumToString(dynamic enumValue) =>
      enumValue.toString().split('.').last;

  static T _stringToEnum<T>(String enumString, List<T> enumValues) {
    return enumValues.firstWhere((e) => e.toString().split('.').last == enumString);
  }

  factory Car.fromMap(Map<String, dynamic> data, DocumentReference reference) {
  return Car(
    id: data['id'] ?? '',
    name: data['name'] ?? '',
    brand: _stringToEnum(data['brand'] ?? '', Brand.values),
    price: (data['price'] ?? 0).toDouble(),
    image: data['image'] ?? '',
    rating: (data['rating'] ?? 0).toDouble(), // Fetch the average rating
    description: data['description'] ?? '',
    bodyType: _stringToEnum(data['bodyType'] ?? '', BodyType.values),
    transmissionType: _stringToEnum(data['transmissionType'] ?? '', TransmissionType.values),
    horsepower: (data['horsepower'] ?? 0).toDouble(),
    acceleration: (data['acceleration'] ?? 0).toDouble(),
    tankCapacity: (data['tankCapacity'] ?? 0).toDouble(),
    topSpeed: (data['topSpeed'] ?? 0),
    features: (data['features'] ?? [])
        .map<Feature>((feature) => _stringToEnum(feature, Feature.values))
        .toList(),
    seller: data['seller'] as DocumentReference<Map<String, dynamic>>,
    isBooked: data['isBooked'] ?? false,
    availableFrom: (data['availableFrom'] != null)
        ? (data['availableFrom'] as Timestamp).toDate()
        : null,
    availableTo: (data['availableTo'] != null)
        ? (data['availableTo'] as Timestamp).toDate()
        : null,
    bookedDates: (data['bookedDates'] as List?)
            ?.map<DateTime>((timestamp) => (timestamp as Timestamp).toDate())
            .toList() ??
        [],
         latitude: (data['latitude'] ?? 0).toDouble(), // Map latitude
      longitude: (data['longitude'] ?? 0).toDouble(),
    ratings: (data['ratings'] as List<dynamic>?)?.cast<double>().toList() ?? [], // Fetch the ratings array
  );
}

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'brand': _enumToString(brand),
    'price': price,
    'image': image,
    'rating': rating, // Save the average rating
    'description': description,
    'bodyType': _enumToString(bodyType),
    'transmissionType': _enumToString(transmissionType),
    'horsepower': horsepower,
    'acceleration': acceleration,
    'tankCapacity': tankCapacity,
    'topSpeed': topSpeed,
    'features': features.map((feature) => _enumToString(feature)).toList(),
    'seller': seller,
    'isBooked': isBooked,
    'availableFrom':
        availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
    'availableTo': availableTo != null ? Timestamp.fromDate(availableTo!) : null,
    'bookedDates': bookedDates.map((date) => Timestamp.fromDate(date)).toList(),
    'ratings': ratings, // Save the ratings array
     'latitude': latitude, // Include latitude
      'longitude': longitude, // Include longitude
  };
}
}

enum Brand { BMW, Toyota, Honda, Tesla, MG, Mercedes, Ford, Audi, Hyundai }
enum BodyType {
  Sedan,
  Hatchback,
  Coupe,
  SUV,
  Crossover,
  Convertible,
  Wagon,
  Minivan,
  PickupTruck,
  SportsCar
}
enum TransmissionType { Manual, Automatic }
enum Feature { Bluetooth, Sensors, Navigation, Camera, Autopilot, Sunroof }
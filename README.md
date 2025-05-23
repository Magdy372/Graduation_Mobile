
# Car Rental App

This is a mobile app developed using Flutter, allowing users to browse, rent, and manage cars. It utilizes Firebase for authentication, data storage, and backend functionalities. The app is designed for Android-only users.

## Features

- **User Registration & Authentication**: Users can register and log in using Firebase Authentication.
- **Car Listings**: View available cars with details such as name, brand, price, image, and rating.
- **Car Rental**: Rent cars directly from the app and track rental information.
- **User Profile**: View and update user profile information such as name, email, address, and phone number.
- **Internet Connection Checker**: Displays an error screen when no internet connection is available.
- **Wishlist/Favorites**: Users can add cars to their favorites or wishlist for future rentals.
- **Search and Filter**: Allow users to search for cars based on price range, brand, or rating.
- **Car Details Page**: View detailed information about each car, including specifications and rental options.
- **Booking History**: Users can view their past car rental history.
- **Payment Integration**: Integration with a payment gateway like Stripe or PayPal for rentals.
- **Push Notifications**: Receive notifications about booking confirmations, special offers, and reminders.
- **Rating and Reviews**: Users can rate and leave reviews for cars after rentals.
- **Admin Panel**: Admins can manage car listings, users, and rental bookings.
- **Car Availability**: Check real-time availability of cars for rental.
- **Car Location**: Display the location of each car, either on a map or as an address.
- **Suggest Cars Based on Proximity**: Suggest cars based on the user's current location, showing cars that are nearest to them.
- **Dark Mode & Light Mode**: Users can switch between dark mode and light mode based on their preferences.

## Project Structure

- **Car Model**: 
  - Fields: `name`, `brand`, `price`, `image`, `rating`, `location`.
  - Methods: `fromMap()` (converts Firestore data to Car object), `toMap()` (converts Car object to Firestore data).
  - Includes an `enum` for listing car features.
  
- **UserModel**:
  - Fields: `id`, `name`, `email`, `role`, `address`, `phone`.
  - Methods: `fromJson()` (converts Firestore data to User object), `toJson()` (converts User object to Firestore data).

- **Firebase Integration**:
  - Firebase Authentication for user management.
  - Firebase Firestore for storing car and user data.
  
## Setup

1. Clone the repository:
    ```bash
    git clone https://github.com/Magdy372/Automotive.git
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Set up Firebase:
    - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
    - Enable Firebase Authentication and Firestore.
    - Download the `google-services.json` file and add it to the `android/app` directory.

4. Run the app on an Android device:
    ```bash
    flutter run
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

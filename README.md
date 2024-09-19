
# Stock Market App

This project is a Flutter application that allows users to view, buy, and sell stocks in real-time. The app integrates with Firebase for authentication and user data storage, and uses Bloc for state management.

**Important Note:** Project uses real-time stock informations therefore tickers are 'visible' when New York Stock Exchange is [open](https://www.tradinghours.com/markets/nyse). For testing purposes you will see 3 cryptocurrency to see real-time updates even when NYSE is close.

## Features

- Firebase Auth and Firestore (Cloud storage)
- Firebase atomic operations to prevent data race in case of concurrent logins
- View Stock Chart for Day, Week, Month, Year Slices
- Buy and Sell Stocks
- View Wallet Balance and assets worth
- Real-time stock price updates

## Screenshots

| Stock Market Loading                                         | Stock Market Loaded                                          | Stock Detail Screen                             |
|--------------------------------------------------------------|--------------------------------------------------------------|-------------------------------------------------|
| ![Stock List](/assets/screenshots/initial-stock-loading.png) | ![Stock Detail](/assets/screenshots/stock-market-screen.png) | ![Wallet](/assets/screenshots/stock-detail.png) |

| Wallet Loading                                        | Wallet Screen                                          | Buy/Sell Notification                               |
|-------------------------------------------------------|--------------------------------------------------------|-----------------------------------------------------|
| ![Stock List](/assets/screenshots/wallet-loading.png) | ![Stock Detail](/assets/screenshots/wallet-screen.png) | ![Wallet](/assets/screenshots/buy-notification.png) |


| Sign In                                       | Sign Up                                           | Forgot Password                                  |
|-----------------------------------------------|---------------------------------------------------|--------------------------------------------------|
| ![Stock List](/assets/screenshots/signin.png) | ![Stock Detail](/assets/screenshots/register.png) | ![Wallet](/assets/screenshots/forgot-screen.png) |

## Technologies Used

- [Flutter](https://flutter.dev/)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Bloc](https://bloclibrary.dev/#/)
- [FlChart](https://pub.dev/packages/fl_chart)

## Project Structure

```
lib
├── blocs
│   ├── auth_cubit.dart
│   ├── market_cubit.dart
│   ├── stock_detail_cubit.dart
│   └── user_cubit.dart
├── models
│   ├── asset_model.dart
│   ├── historical_data_model.dart
│   └── stock_model.dart
├── screens
│   ├── auth_gate.dart
│   ├── home_screen.dart
│   ├── stock_detail_screen.dart
│   ├── stocks_screen.dart
│   └── wallet_screen.dart
├── services
│   └── stock_service.dart
├── app.dart
├── constants.dart     
└── main.dart
```

## Getting Started

Below are the instructions to set up and run the project on iOS.

### Prerequisites

- Xcode (only available on macOS devices)
- Latest iOS SDK for running iOS Simulator on macOS
- [Flutter Version Manager](https://fvm.app/documentation/getting-started)

### Running the App

Follow these steps to run the Stock Market app:

1. Clone the repository:

    ```bash
    git clone git@github.com:cenk-idris/stock_market.git
    ```

2. Navigate to the project directory:

    ```bash
    cd stock_market
    ```

3. Add Firebase to the project. Follow the instructions [here](https://firebase.google.com/docs/flutter/setup?platform=ios) to set up Firebase for iOS.

4. Use the correct Flutter version:

    ```bash
    fvm use
    ```

5. Clean the project:

    ```bash
    fvm flutter clean
    ```

6. Get the project dependencies:

    ```bash
    fvm flutter pub get
    ```

7. Launch the iOS simulator:

    ```bash
    fvm flutter emulators --launch apple_ios_simulator
    ```

8. Run the app in debug mode:

    ```bash
    fvm flutter run --debug
    ```

9. You will be prompted to choose the target device/platform. Pick the Simulator's iOS instance you just launched.

10. Cross your fingers :)

## Usage

### Registration and Login

- Users can register and login with their email.

### Viewing Stocks

- After login, users can view a list of available stocks and their current prices in real-time.

### Stock Details

- Users can tap on a stock to view detailed information, including historical data presented in a chart.

### Buying & Selling Stocks

- Users can buy and sell stocks directly from the stock detail screen.
- After a successful transaction, users receive a confirmation message or error reason.

### Viewing Wallet

- Users can view their current balance and list of owned stocks in the wallet screen.
- The balance is displayed in a formatted currency style.

## Potential Improvements and Challenges

- **Bloc Architecture:** The current implementation of Blocs is tightly coupled and does not fully adhere to [best practices](https://bloclibrary.dev/architecture/#bloc-to-bloc-communication). Specifically, Bloc-to-Bloc communication should be managed through events to avoid tight coupling and enhance modularity.

- **Project Structure:** The current structure of the project is monolithic, making it less scalable and harder to maintain. Multiple responsibilities are being handled within the same Blocs, which violates the single responsibility principle. To improve this, Blocs should be refactored to have a single responsibility, leading to a more modular and maintainable architecture.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/) - Cloud Backend
- [Bloc](https://bloclibrary.dev/#/) - State management
- [FlChart](https://pub.dev/packages/fl_chart) - For stock charts
- [Polygon.io](https://polygon.io) - Rest API for historical data
- [Finnhub.io](https://finnhub.io/) - Rest and Websocket API for initial company stock details and real-time ticker for Stock/Cryptocurrency
- [Companies Logo](https://companieslogo.com) - Stock logos

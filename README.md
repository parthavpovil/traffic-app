<div align="center">
  <h1>TRAFFIX</h1>
  <img src="assets/traffic-logo.png" width="120" height="120" alt="Traffix Logo"/>
  <p><em>Decentralized Traffic Violation Reporting System</em></p>
</div>

---

## 📱 Overview

Traffix is a blockchain-powered mobile application built with Flutter that revolutionizes traffic violation reporting. It provides a secure, transparent platform for citizens to report violations and earn rewards for verified reports.

## ✨ Key Features

🔐 **Secure Authentication**
- Web3-based wallet authentication
- Decentralized identity management

📸 **Evidence Capture**
- Photo and video capture
- Automatic location tagging
- IPFS-based decentralized storage

⛓️ **Blockchain Integration**
- Smart contract-based reporting
- Transparent verification system
- Automated reward distribution

🗺️ **Location Services**
- Real-time GPS tracking
- Accurate location mapping
- Geolocation verification

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.6.0+
- **Blockchain**: Ethereum (Sepolia Testnet)
- **Smart Contract**: Solidity
- **Storage**: IPFS
- **Authentication**: Web3
- **Maps**: Flutter Map
- **Location**: Geolocator

## 🚀 Getting Started

### Prerequisites

✓ Flutter SDK (^3.6.0)
✓ Dart SDK
✓ Android Studio / Xcode
✓ Metamask Wallet
✓ Sepolia Testnet ETH

### Installation

1. Clone the repository
```bash
git clone https://github.com/parthavpovil/traffic-app.git
```

2. Install dependencies
```bash
cd traffix
flutter pub get
```

3. Update the configuration
- Add your IPFS API credentials in `lib/services/ipfs_service.dart`
- Update contract address in `lib/constants/contract_constants.dart`

4. Run the application
```bash
flutter run
```

### Smart Contract

The smart contract is deployed on Sepolia Testnet at:
`0xa5Cf9FfCfCEd2A711c77041C86F670560ab65081`

## Architecture

The application follows a service-based architecture with clear separation of concerns:

- **Services**: Contract, IPFS, and Wallet interactions
- **Screens**: UI components and user interaction
- **Constants**: Configuration and theme definitions
- **Utils**: Helper functions and utilities
- **Widgets**: Reusable UI components

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Parthav - [@parthav_](https://twitter.com/yourtwitter)

Project Link: [https://github.com/parthavpovil/traffic-app](https://github.com/yourusername/traffix)

## Acknowledgments

- Flutter Team
- Web3Dart
- IPFS
- OpenZeppelin
- Flutter Map

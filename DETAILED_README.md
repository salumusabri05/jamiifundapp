# JamiiFund Project Documentation

## Project Overview

JamiiFund is a modern crowdfunding mobile application built with Flutter and Supabase. The app enables users to create fundraising campaigns, contribute to causes, and verify their identity through a multi-step verification process. JamiiFund aims to provide a secure, transparent platform for community-based fundraising and charitable giving.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Technical Architecture](#technical-architecture)
  - [Data Models](#data-models)
  - [Services](#services)
  - [Screens](#screens)
  - [Widgets](#widgets)
- [User Flows](#user-flows)
  - [Verification Flow](#verification-flow)
  - [Campaign Creation Flow](#campaign-creation-flow)
  - [Donation Flow](#donation-flow)
- [Database Schema](#database-schema)
- [Authentication and Security](#authentication-and-security)
- [File Storage](#file-storage)
- [Getting Started](#getting-started)
- [Development Guidelines](#development-guidelines)

## Features

- **Authentication System**: Secure sign-up, login, and profile management
- **Unified Verification Process**: Multi-step KYC for individuals and organizations
- **Campaign Management**: Creation, editing, and tracking of fundraising campaigns
- **Donation Processing**: Multiple payment methods with secure transaction handling
- **Interactive Home Screen**: Video player and featured campaigns
- **Search & Discovery**: Find campaigns by category or keywords
- **User Profiles**: Personal/organizational profiles with verification status
- **Responsive UI**: Cross-platform design optimized for various device sizes

## Project Structure

```
jamiifund/
├── android/           # Android-specific configuration
├── assets/            # Static assets (images, videos)
├── ios/               # iOS-specific configuration
├── lib/               # Main Dart code
│   ├── models/        # Data models
│   ├── screens/       # UI screens
│   ├── services/      # Backend services
│   ├── theme/         # App styling
│   ├── utils/         # Helper utilities
│   ├── widgets/       # Reusable UI components
│   └── main.dart      # Application entry point
├── web/               # Web-specific assets
├── linux/             # Linux platform code
├── macos/             # macOS platform code
├── windows/           # Windows platform code
├── pubspec.yaml       # Dependencies and configuration
└── README.md          # Project documentation
```

## Technical Architecture

JamiiFund follows a service-based architecture pattern with clear separation of concerns between data models, business logic services, and UI components.

### Data Models

1. **UnifiedVerification**: Core model for both personal and organizational verification
   - Personal KYC data (name, ID, contact details)
   - Organization details
   - Verification status tracking
   - Document references

2. **VerificationMember**: Organizational member information
   - Personal details
   - Role in organization
   - Document references
   - Verification status

3. **Campaign**: Fundraising campaign data
   - Basic details (title, description)
   - Financial information (goal, current amount)
   - Status tracking and deadlines
   - Progress calculation methods

4. **UserProfile**: User account information
   - Personal/organizational details
   - Verification status
   - Contact information
   - Profile settings

5. **PaymentMethod**: Payment information
   - Payment type (mobile money, bank account)
   - Account details
   - User association

### Services

1. **UnifiedVerificationService**: Manages the verification process
   - Creating and updating verification requests
   - File uploads for verification documents
   - Member management for organizations
   - Status checking and updates

2. **CampaignService**: Handles campaign operations
   - Campaign creation and updates
   - Campaign listing and filtering
   - Stats calculation
   - Featured campaign management
   - Mock data generation for testing

3. **DonationService**: Processes and tracks donations
   - Creating donation records
   - Payment method handling
   - Campaign stats updates
   - Donation history tracking

4. **UserService**: Manages user data
   - Profile creation and updates
   - User settings management
   - Authentication state handling

5. **SupabaseService**: Centralized Supabase client
   - Connection initialization
   - Authentication helpers
   - Database operations
   - Storage operations

### Screens

1. **HomeScreen**: Main landing page
   - Featured campaigns display
   - Video player with promotional content
   - Navigation to other sections

2. **MultiStepVerificationScreen**: Comprehensive verification workflow
   - Personal KYC collection
   - Organization details (conditional)
   - Member management for organizations
   - Document uploads
   - Review and submission

3. **CampaignDetailsPage**: Campaign information display
   - Campaign details and media
   - Progress tracking
   - Donation button and history
   - Creator information

4. **DonationScreen**: Donation workflow
   - Amount selection
   - Payment method selection
   - Donor information collection
   - Anonymous donation option
   - Message input

5. **ProfileScreen**: User profile management
   - Personal/organizational information
   - Verification status
   - Created campaigns list
   - Donation history

### Widgets

1. **HomeVideoPlayer**: Video player with autoplay and visibility detection
2. **StatusBadge**: Visual indicator for verification and other statuses
3. **FileUploadWidget**: Document/image upload with preview
4. **InputField**: Styled form input with validation
5. **MemberCard**: Organization member information display and management
6. **ReviewCard**: Information review before submission
7. **AppDrawer**: Navigation drawer with app sections
8. **AppBottomNavBar**: Bottom navigation bar for main sections

## User Flows

### Verification Flow

1. **Start Verification**: User initiates verification from profile
2. **Personal KYC**:
   - Enter personal details (name, DOB, ID, contact)
   - Upload selfie and ID document
3. **Organization Details** (if applicable):
   - Enter organization information
   - Upload registration documents and logo
4. **Member Management** (if organization):
   - Add organization members with roles
   - Collect basic information for each member
5. **Review and Submit**:
   - Review all entered information
   - Submit for processing
6. **Verification Status**:
   - Track verification status in profile
   - Receive updates on completion

### Campaign Creation Flow

1. **Initiate Campaign**: User starts new campaign
2. **Enter Details**:
   - Title, description, category
   - Goal amount and end date
   - Upload campaign image
3. **Review and Submit**:
   - Preview campaign details
   - Submit for publication
4. **Campaign Management**:
   - Track campaign progress
   - Update details if needed
   - View donor information

### Donation Flow

1. **View Campaign**: User browses and selects campaign
2. **Initiate Donation**: Click "Donate Now" button
3. **Amount Selection**:
   - Choose from predefined amounts
   - Or enter custom amount
4. **Enter Information**:
   - Phone number for mobile payments
   - Optional name and email
   - Option for anonymous donation
   - Optional message of support
5. **Payment Method Selection**:
   - Choose from available methods:
     - M-Pesa
     - AirtelMoney
     - Halopesa
     - T-Pesa
     - Credit Card
     - Bank Transfer
6. **Payment Processing**:
   - Connect to payment gateway
   - Process transaction
   - Show confirmation or error
7. **Confirmation**:
   - Display success message
   - Return to campaign with updated progress

## Database Schema

### 'verifications' Table
- `id`: UUID (primary key)
- `user_id`: UUID (foreign key to auth.users)
- `status`: ENUM ('pending', 'submitted', 'completed')
- `full_name`: TEXT
- `date_of_birth`: TEXT
- `national_id`: TEXT
- `address`: TEXT
- `phone`: TEXT
- `email`: TEXT
- `selfie_url`: TEXT
- `id_document_url`: TEXT
- `bank_account`: TEXT
- `bank_name`: TEXT
- `is_organization`: BOOLEAN
- `organization_name`: TEXT
- `organization_reg_number`: TEXT
- `organization_address`: TEXT
- `organization_bank_account`: TEXT
- `organization_bank_name`: TEXT
- `organization_logo_url`: TEXT
- `organization_document_url`: TEXT
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP

### 'verification_members' Table
- `id`: UUID (primary key)
- `verification_id`: UUID (foreign key to verifications)
- `full_name`: TEXT
- `role`: TEXT
- `date_of_birth`: TEXT
- `national_id`: TEXT
- `email`: TEXT
- `phone`: TEXT
- `selfie_url`: TEXT
- `id_document_url`: TEXT
- `status`: ENUM ('pending', 'submitted', 'completed')

### 'campaigns' Table
- `id`: UUID (primary key)
- `created_at`: TIMESTAMP
- `title`: TEXT
- `description`: TEXT
- `category`: TEXT
- `goal_amount`: INTEGER
- `current_amount`: INTEGER
- `end_date`: TIMESTAMP
- `image_url`: TEXT
- `created_by`: UUID (foreign key to auth.users)
- `is_featured`: BOOLEAN
- `donor_count`: INTEGER
- `created_by_name`: TEXT
- `firebase_uid`: TEXT (legacy field)

### 'donations' Table
- `id`: UUID (primary key)
- `created_at`: TIMESTAMP
- `campaign_id`: UUID (foreign key to campaigns)
- `amount`: DECIMAL
- `donor_name`: TEXT
- `donor_email`: TEXT
- `message`: TEXT
- `anonymous`: BOOLEAN
- `payment_method`: TEXT

### 'profiles' Table
- `id`: UUID (primary key, matches auth.users.id)
- `updated_at`: TIMESTAMP
- `username`: TEXT
- `full_name`: TEXT
- `avatar_url`: TEXT
- `website`: TEXT
- `phone`: TEXT
- `address`: TEXT
- `city`: TEXT
- `region`: TEXT
- `postal_code`: TEXT
- `is_organization`: BOOLEAN
- `organization_name`: TEXT
- `organization_reg_number`: TEXT
- `organization_type`: TEXT
- `organization_description`: TEXT
- `bio`: TEXT
- `email`: TEXT
- `location`: TEXT
- `is_verified`: BOOLEAN
- `id_url`: TEXT

### 'payment_methods' Table
- `id`: UUID (primary key)
- `user_id`: UUID (foreign key to auth.users)
- `type`: TEXT ('mobile_money', 'bank', etc.)
- `account_number`: TEXT
- `account_name`: TEXT
- `created_at`: TIMESTAMP

## Authentication and Security

JamiiFund uses Supabase Authentication for secure user management:

- Email/password authentication
- Session handling and token refresh
- Password reset functionality
- Secure storage of credentials

Security measures include:

- Data validation on both client and server
- Secure file uploads with proper permissions
- Row-level security policies in Supabase
- Input sanitization and validation

## File Storage

Files are organized in Supabase Storage buckets:

- `avatars/`: User profile images
- `verification_documents/`: KYC and organization documents
  - Selfies, ID documents, organization registrations
- `campaign_images/`: Campaign-related media

Each file uses a unique naming convention with user/entity IDs to prevent collisions.

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- A Supabase account and project

### Setup

1. Clone the repository
   ```bash
   git clone https://github.com/your-username/jamiifund.git
   cd jamiifund
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Supabase
   - Create a `.env` file in the root directory
   - Add your Supabase URL and anonymous key:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Run the app
   ```bash
   flutter run
   ```

## Development Guidelines

### Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

### State Management

- Use StatefulWidget for local UI state
- Consider implementing a more robust state management solution like Provider for complex state

### Error Handling

- Use try-catch blocks for error handling
- Display user-friendly error messages
- Log errors for debugging

### Performance Considerations

- Minimize network requests
- Use pagination for long lists
- Optimize image loading and caching
- Be mindful of memory usage on low-end devices

### Testing

- Write unit tests for models and services
- Create widget tests for UI components
- Use integration tests for critical user flows

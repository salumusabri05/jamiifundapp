# JamiiFund

JamiiFund is a crowdfunding mobile application built with Flutter and Supabase that enables users to create and contribute to fundraising campaigns. The app features a multi-step verification system for both personal KYC and organization verification to ensure trust and transparency in the fundraising process.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Architecture](#architecture)
- [Models](#models)
- [Services](#services)
- [Screens](#screens)
- [Widgets](#widgets)
- [Authentication](#authentication)
- [Payment Processing](#payment-processing)
- [File Storage](#file-storage)
- [Database Schema](#database-schema)
- [Development Guidelines](#development-guidelines)
- [Contributing](#contributing)

## Features

- **User Authentication**: Secure login and registration with Supabase authentication
- **Unified Verification System**: Multi-step KYC process for both individuals and organizations
- **Campaign Management**: Create, view, and manage fundraising campaigns
- **Interactive Home Screen**: Features a video player and showcases featured campaigns
- **Donations**: Support campaigns with various payment methods
- **Profile Management**: User profile customization and verification status tracking
- **Responsive Design**: Compatible with various device sizes and orientations

## Project Structure

The project follows a modular architecture with the following directory structure:

- `lib/`: Main source code directory
  - `models/`: Data models for the application
  - `screens/`: UI screens for different app sections
  - `services/`: Backend services for API interactions
  - `widgets/`: Reusable UI components
  - `theme/`: App theming and styling
  - `utils/`: Helper functions and utilities
- `assets/`: Static assets like images and videos
  - `images/`: Image assets
  - `videos/`: Video assets for the home screen

## Setup and Installation

### Environment Configuration

JamiiFund uses environment variables to manage sensitive information like API keys. We've structured the environment variables to support different deployment environments (development, staging, production):

1. Create a `.env` file in the project root by copying from the `.env.template`:
   ```bash
   cp .env.template .env
   ```

2. Update the `.env` file with your actual values:
   ```
   # Payment Gateway Configurations
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
   STRIPE_SECRET_KEY=your_stripe_secret_key_here
   CLICKPESA_CLIENT_ID=your_clickpesa_client_id_here
   CLICKPESA_API_KEY=your_clickpesa_api_key_here
   
   # App Configurations
   APP_ENVIRONMENT=development  # Change to 'staging' or 'production' as needed
   ENABLE_DEBUG_LOGS=true       # Set to 'false' in production
   ```

3. For different environments:
   - **Development**: Set `APP_ENVIRONMENT=development` and `ENABLE_DEBUG_LOGS=true`
   - **Staging**: Set `APP_ENVIRONMENT=staging` and `ENABLE_DEBUG_LOGS=true`
   - **Production**: Set `APP_ENVIRONMENT=production` and `ENABLE_DEBUG_LOGS=false`

4. Never commit your actual `.env` file to the repository. The `.env` file is included in `.gitignore`.

5. For development, contact the project administrator to obtain the necessary API keys.

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- A Supabase account and project

### Getting Started

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
   - Create a `.env` file in the project root (or modify the existing configuration in the SupabaseService)
   - Add your Supabase URL and API key
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Run the app
   ```bash
   flutter run
   ```

## Architecture

JamiiFund follows a service-based architecture pattern:

1. **Models**: Data classes that define the structure of objects used throughout the app
2. **Services**: Handle API calls, data processing, and business logic
3. **Screens**: UI components that represent full pages in the app
4. **Widgets**: Reusable UI components used across multiple screens

## Models

### UnifiedVerification
Handles both personal KYC and organization verification data.
- Personal information (name, DOB, ID, etc.)
- Organization details (name, registration number, etc.)
- Member information for organizations
- Document/image URLs
- Verification status tracking

### VerificationMember
Stores information about organization members:
- Personal details (name, role, DOB, ID)
- Document URLs
- Status tracking

### Campaign
Represents a fundraising campaign with:
- Title, description, category
- Goal and current amounts
- End date and progress tracking
- Creator information
- Image URL

### UserProfile
User account information:
- Personal details
- Optional organization information
- Verification status
- Contact and location data

## Services

### UnifiedVerificationService
Handles verification-related operations:
- Creating/updating verification requests
- Uploading documents and images
- Managing organization members
- Checking verification status

### CampaignService
Manages campaign-related operations:
- Creating new campaigns
- Fetching campaign lists (all, featured, by category)
- Updating campaign details and progress
- Handling campaign images

### SupabaseService
Provides a centralized interface to the Supabase backend:
- Authentication
- Database operations
- Storage operations

### UserService
Handles user account operations:
- Profile creation and updates
- User data retrieval
- Account settings management

### DonationService
Manages donation operations:
- Processing donations
- Tracking donation history
- Updating campaign progress
- Integrating with payment gateways

### ClickPesaService
Handles mobile money payments through the ClickPesa API:
- Token generation and management
- Payment validation via preview endpoint
- USSD push payment initiation
- Payment status checking
- Structured response handling
- Token caching for performance optimization

## Screens

### MultiStepVerificationScreen
A comprehensive multi-step process for user verification:
- Step 1: Personal KYC (name, ID, documents)
- Step 2: Organization details (for organizations)
- Step 3: Member management (for organizations)
- Step 4: Review and submission

### HomeScreen
The main landing page featuring:
- Featured campaigns
- Promotional video
- Navigation to other sections

### ProfileScreen
User profile management:
- Personal information
- Verification status
- Created campaigns
- Donation history

### CampaignDetailsPage
Detailed view of a campaign:
- Campaign information and progress
- Donation options
- Creator details
- Updates and comments

### CreateCampaignScreen
Interface for creating new campaigns:

### PaymentProcessingScreen
Handles donation payment processing:
- Payment method selection
- USSD push payment initiation
- Payment status tracking
- Confirmation and receipt display
- Campaign details
- Funding goal and deadline
- Media upload
- Category selection

## Widgets

### FileUploadWidget
Handles document and image uploads with preview functionality.

### MemberCard
Displays and manages organization member information.

### StatusBadge
Shows verification status with appropriate styling.

### HomeVideoPlayer
Custom video player for the home screen with autoplay and visibility detection.

### InputField
Styled text input fields with validation.

### ReviewCard
Shows submitted information for review before final submission.

## Authentication

The app uses Supabase Authentication for user management:
- Email/password authentication
- Session management
- Password reset functionality
- User data synchronization with profiles

## Payment Processing

JamiiFund supports multiple payment methods to ensure donations can be made easily across different regions:

### Mobile Money Payments (ClickPesa)
- **USSD Push**: Sends a payment request directly to the user's mobile phone
- **Payment Preview**: Validates payment details before sending USSD push
- **Token-based Authentication**: Securely authenticates with the ClickPesa API using cached tokens
- **Status Tracking**: Monitors payment status from initiation through completion
- **Error Handling**: Robust error handling with structured response objects
- **Transaction Records**: Stores transaction IDs for verification and reconciliation

### Card Payments (Stripe)
- **Secure Processing**: Uses Stripe's secure payment processing
- **Multiple Card Types**: Supports major credit and debit cards
- **Tokenization**: Never stores sensitive card details

### Payment Flow
1. User selects payment method and enters details
2. System validates input and initiates payment request
3. Payment gateway processes the request
4. System verifies the payment status before recording the donation
5. User receives confirmation of successful payment

### Security Measures
- Environment variables for API credentials
- Token caching with automatic expiration
- No storage of sensitive payment details
- Verification of payment status before recording donations
- Unique transaction references for each payment

## File Storage

Files are stored in Supabase Storage with the following structure:
- `avatars/`: User profile images
- `verification/`: KYC documents organized by user ID
  - `selfies/`: User selfie images
  - `id_documents/`: Identity document images
  - `organization_docs/`: Organization registration documents
- `campaigns/`: Campaign-related images and media

## Database Schema

### 'verifications' Table
Stores unified verification data:
- User identification
- Personal KYC information
- Organization information (if applicable)
- Document URLs
- Status and timestamps

### 'verification_members' Table
Stores organization member data:
- Verification ID reference
- Personal information
- Document URLs
- Status

### 'campaigns' Table
Stores campaign information:
- Creator reference
- Campaign details
- Financial goals and progress
- Status and timestamps

### 'donations' Table
Tracks donations to campaigns:
- User reference (donor)
- Campaign reference
- Amount and timestamp
- Payment method information

### 'profiles' Table
Extended user information:
- Authentication ID reference
- Profile details
- Preferences and settings

## Development Guidelines

### Code Style
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic

### State Management
- Use StatefulWidget for local state
- Consider Provider or Riverpod for more complex state management

### Error Handling
- Use try-catch blocks for error handling
- Display user-friendly error messages
- Log errors for debugging purposes

### Testing
- Write unit tests for models and services
- Write widget tests for UI components
- Run tests before submitting pull requests

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Submit a pull request

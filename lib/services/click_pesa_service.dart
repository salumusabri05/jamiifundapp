import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' hide kDebugMode;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamiifund/config/environment_config.dart';

/// Response models for ClickPesa API
class ClickPesaTokenResponse {
  final bool success;
  final String? token;
  final String? message;

  ClickPesaTokenResponse({required this.success, this.token, this.message});

  factory ClickPesaTokenResponse.fromJson(Map<String, dynamic> json) {
    return ClickPesaTokenResponse(
      success: json['success'] ?? false,
      token: json['token'],
      message: json['message'],
    );
  }
}

class PaymentMethod {
  final String name;
  final String status;
  final double fee;
  final String message;

  PaymentMethod({
    required this.name,
    required this.status,
    required this.fee,
    required this.message,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      fee: (json['fee'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }
}

class SenderDetails {
  final String accountName;
  final String accountNumber;
  final String accountProvider;

  SenderDetails({
    required this.accountName,
    required this.accountNumber,
    required this.accountProvider,
  });

  factory SenderDetails.fromJson(Map<String, dynamic> json) {
    return SenderDetails(
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountProvider: json['accountProvider'] ?? '',
    );
  }
}

class PreviewResponse {
  final List<PaymentMethod> activeMethods;
  final SenderDetails? sender;

  PreviewResponse({required this.activeMethods, this.sender});

  factory PreviewResponse.fromJson(Map<String, dynamic> json) {
    return PreviewResponse(
      activeMethods:
          (json['activeMethods'] as List<dynamic>?)
              ?.map((method) => PaymentMethod.fromJson(method))
              .toList() ??
          [],
      sender: json['sender'] != null
          ? SenderDetails.fromJson(json['sender'])
          : null,
    );
  }
}

/// Custom exceptions for ClickPesa API
class ClickPesaException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ClickPesaException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() => 'ClickPesaException: $message';
}

/// A structured response from a payment API request
class PaymentResponse {
  /// Whether the request was successful
  final bool success;
  
  /// Human-readable message about the result
  final String message;
  
  /// Error code if any error occurred
  final String? errorCode;
  
  /// Payment provider's transaction ID
  final String? transactionId;
  
  /// The order reference used for the transaction
  final String? orderReference;
  
  /// Status of the payment (PENDING, COMPLETED, FAILED, etc.)
  final String status;
  
  /// Sender details if available (only from preview endpoint)
  final Map<String, dynamic>? senderDetails;
  
  /// Network provider details (e.g., Vodacom, Airtel, etc.)
  final String? networkProvider;
  
  /// The raw response data from the API
  final Map<String, dynamic>? rawResponse;
  
  const PaymentResponse({
    required this.success,
    required this.message,
    required this.status,
    this.errorCode,
    this.transactionId,
    this.orderReference,
    this.senderDetails,
    this.networkProvider,
    this.rawResponse,
  });
  
  /// Check if the payment is pending user action
  bool get isPending => status == 'PENDING' || status == 'INITIATED';
  
  /// Check if the payment has completed successfully
  bool get isCompleted => status == 'COMPLETED' || status == 'SUCCESS';
  
  /// Check if the payment has failed
  bool get isFailed => status == 'FAILED' || status == 'REJECTED';
  
  /// Get the name of the sender if available
  String? get senderName => senderDetails?['name'] as String?;
}

/// Service class for interacting with the ClickPesa payment gateway API
class ClickPesaService {
  // API endpoints
  static const String _baseUrl = 'https://api.clickpesa.com/third-parties';
  static const String _generateTokenEndpoint = '$_baseUrl/generate-token';
  static const String _previewUssdPushEndpoint = '$_baseUrl/payments/preview-ussd-push-request';
  static const String _initiateUssdPushEndpoint = '$_baseUrl/payments/initiate-ussd-push-request';
  static const String _paymentsEndpoint = '$_baseUrl/payments';
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  
  // Token cache keys
  static const String _tokenKey = 'clickpesa_token';
  static const String _tokenExpiryKey = 'clickpesa_token_expiry';
  
  // Create a static Dio instance for reuse
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    validateStatus: (status) {
      // Consider all responses as valid to handle in the catch block
      return true;
    },
  ))..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: true,
    error: true,
    logPrint: (obj) {
      // Only log in debug mode
      if (kDebugMode) {
        debugPrint('CLICKPESA API: $obj');
      }
    },
  ));

  // Token storage
  static String? _token;
  static DateTime? _tokenExpiry;

  /// Generates an authentication token for ClickPesa API
  /// 
  /// Makes a POST request to the ClickPesa token generation endpoint
  /// with the client-id and api-key headers. Returns the token string
  /// if successful.
  static Future<ClickPesaTokenResponse> generateToken() async {
    try {
      // Check if we have a valid cached token
      if (_token != null && _tokenExpiry != null && _tokenExpiry!.isAfter(DateTime.now())) {
        debugPrint('Using cached ClickPesa token');
        return ClickPesaTokenResponse(
          success: true,
          token: _token,
          message: 'Using cached token',
        );
      }
      
      // Get credentials from environment configuration
      final clientId = EnvironmentConfig.clickpesaClientId;
      final apiKey = EnvironmentConfig.clickpesaApiKey;
      
      // Ensure credentials are available
      if (clientId.isEmpty || apiKey.isEmpty) {
        throw ClickPesaException('ClickPesa credentials are not configured');
      }
      
      debugPrint('Generating new ClickPesa token with client ID: ${clientId.substring(0, 5)}...');
      debugPrint('API Key: ${apiKey.substring(0, 5)}...');
      
      // Prepare request
      final response = await _dio.post(
        _generateTokenEndpoint,
        options: Options(
          headers: {
            'client-id': clientId,
            'api-key': apiKey,
          },
        ),
      );
      
      debugPrint('Token response: ${response.data}');
      
      // Parse response
      final data = response.data;
      final tokenResponse = ClickPesaTokenResponse.fromJson(data);
      
      if (tokenResponse.success && tokenResponse.token != null) {
        // Cache the token (valid for 1 hour)
        _token = tokenResponse.token;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        
        // Also cache in shared preferences for persistence
        _saveTokenToPrefs(tokenResponse.token!);
        
        return tokenResponse;
      } else {
        throw ClickPesaException(
          tokenResponse.message ?? 'Token generation failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('Error generating ClickPesa token: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      
      // Handle specific error cases
      if (e.response?.statusCode == 401) {
        throw ClickPesaException(
          'Unauthorized: Invalid credentials',
          statusCode: e.response?.statusCode,
          errorCode: 'UNAUTHORIZED',
        );
      } else if (e.response?.statusCode == 403) {
        throw ClickPesaException(
          'Invalid or Expired API-Key',
          statusCode: e.response?.statusCode,
          errorCode: 'INVALID_API_KEY',
        );
      }
      
      throw ClickPesaException(
        'Failed to connect to ClickPesa API: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('Error generating ClickPesa token: $e');
      throw ClickPesaException('Token generation failed: ${e.toString()}');
    }
  }
  
  /// Save token to SharedPreferences for persistence across app restarts
  static Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_tokenExpiryKey, _tokenExpiry!.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving token to preferences: $e');
    }
  }
  
  /// Load token from SharedPreferences on app startup
  static Future<void> loadTokenFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final expiryTimestamp = prefs.getInt(_tokenExpiryKey);
      
      if (token != null && expiryTimestamp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        
        // Check if token is still valid (with a 5-minute buffer)
        if (expiry.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
          _token = token;
          _tokenExpiry = expiry;
          debugPrint('Loaded valid token from preferences');
        }
      }
    } catch (e) {
      debugPrint('Error loading token from preferences: $e');
    }
  }
  
  /// Generate a secure checksum for ClickPesa API requests
  /// 
  /// Formula: SHA256(amount + currency + orderReference + phoneNumber + secretKey)
  static String generateChecksum({
    required String amount,
    required String currency,
    required String orderReference,
    required String phoneNumber,
  }) {
    // Get the secret key from environment config
    final String secretKey = EnvironmentConfig.clickpesaSecretKey;
    
    // Log for debugging (remove in production)
    debugPrint('Generating checksum with secret key: ${secretKey.substring(0, 5)}...');
    
    final raw = '$amount$currency$orderReference$phoneNumber$secretKey';
    return sha256.convert(utf8.encode(raw)).toString();
  }
  
  /// Validate phone number format for Tanzania
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Tanzanian number
    if (cleanNumber.length == 10 && cleanNumber.startsWith('0')) {
      return true;
    } else if (cleanNumber.length == 12 && cleanNumber.startsWith('255')) {
      return true;
    }
    
    return false;
  }
  
  /// Format phone number to international format for Tanzania (255)
  static String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length == 10 && cleanNumber.startsWith('0')) {
      return '255${cleanNumber.substring(1)}';
    } else if (cleanNumber.length == 12 && cleanNumber.startsWith('255')) {
      return cleanNumber;
    }
    
    throw ClickPesaException('Invalid phone number format: $phoneNumber');
  }
  
  /// Preview a USSD Push payment request before initiating it
  /// 
  /// This allows checking if the payment details are valid before sending
  /// the actual USSD push to the customer's phone. Useful for validation.
  static Future<PaymentResponse> previewUssdPayment({
    required String phoneNumber,
    required String amount,
    String? orderReference,
    String currency = 'TZS',
    bool fetchSenderDetails = true,
  }) async {
    // Generate a unique order reference if not provided
    final paymentRef = orderReference ?? const Uuid().v4();
    
    // Validate phone number
    if (!isValidPhoneNumber(phoneNumber)) {
      return PaymentResponse(
        success: false,
        message: 'Invalid phone number format',
        errorCode: 'INVALID_PHONE',
        status: 'FAILED',
      );
    }
    
    final formattedPhone = formatPhoneNumber(phoneNumber);
    
    try {
      // Get authentication token
      final tokenResponse = await generateToken();
      if (!tokenResponse.success || tokenResponse.token == null) {
        return PaymentResponse(
          success: false,
          message: tokenResponse.message ?? 'Failed to generate token',
          errorCode: 'TOKEN_ERROR',
          status: 'FAILED',
        );
      }
      
      final token = tokenResponse.token!;
      
      // Generate checksum
      final checksum = generateChecksum(
        amount: amount,
        currency: currency,
        orderReference: paymentRef,
        phoneNumber: formattedPhone,
      );
      
      // Prepare request data
      final requestData = {
        'amount': amount,
        'currency': currency,
        'orderReference': paymentRef,
        'phoneNumber': formattedPhone,
        'fetchSenderDetails': fetchSenderDetails,
        'checksum': checksum,
      };
      
      debugPrint('Previewing USSD payment with data: $requestData');
      
      // Make API call
      final response = await _dio.post(
        _previewUssdPushEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      // Log response for debugging
      debugPrint('ClickPesa Preview Response: ${response.data}');
      
      final data = response.data;
      
      // Extract sender details and network provider if available
      Map<String, dynamic>? senderDetails;
      String? networkProvider;
      
      // Check if we have sender details in the response
      if (data['sender'] != null) {
        senderDetails = data['sender'] as Map<String, dynamic>;
        networkProvider = senderDetails['accountProvider'];
      }
      
      return PaymentResponse(
        success: true,
        message: 'Payment preview successful',
        status: 'PREVIEW',
        orderReference: paymentRef,
        senderDetails: senderDetails,
        networkProvider: networkProvider,
        rawResponse: data as Map<String, dynamic>?,
      );
      
    } on ClickPesaException catch (e) {
      debugPrint('ClickPesa exception in preview: ${e.message}');
      return PaymentResponse(
        success: false,
        message: e.message,
        errorCode: e.errorCode,
        status: 'FAILED',
        orderReference: paymentRef,
      );
    } on DioException catch (e) {
      debugPrint('DioError previewing USSD payment: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      
      final errorMessage = e.response?.data?['message'] ?? e.message;
      final errorCode = e.response?.data?['errorCode'] ?? 'DIO_ERROR';
      
      return PaymentResponse(
        success: false,
        message: 'Error processing payment preview: $errorMessage',
        errorCode: errorCode,
        status: 'FAILED',
        orderReference: paymentRef,
        rawResponse: e.response?.data as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('Error previewing USSD payment: $e');
      return PaymentResponse(
        success: false,
        message: 'Error processing payment preview: ${e.toString()}',
        errorCode: 'CLIENT_ERROR',
        status: 'FAILED',
        orderReference: paymentRef,
      );
    }
  }
  
  /// Initiates a USSD Push payment request
  /// 
  /// Uses the provided phone number and amount to create a payment
  /// request with ClickPesa. Generates a unique order reference for tracking.
  /// Returns a response only after getting confirmation from ClickPesa.
  static Future<PaymentResponse> initiateUssdPayment({
    required String phoneNumber,
    required String amount,
    String? orderReference,
    String currency = 'TZS',
    int retryCount = 0,
    Duration statusCheckDelay = const Duration(seconds: 3),
    int maxStatusChecks = 5,
  }) async {
    // Generate a unique order reference if not provided
    final paymentRef = orderReference ?? const Uuid().v4();
    
    // Validate phone number
    if (!isValidPhoneNumber(phoneNumber)) {
      return PaymentResponse(
        success: false,
        message: 'Invalid phone number format',
        errorCode: 'INVALID_PHONE',
        status: 'FAILED',
        orderReference: paymentRef,
      );
    }
    
    final formattedPhone = formatPhoneNumber(phoneNumber);
    
    try {
      // Get authentication token
      final tokenResponse = await generateToken();
      if (!tokenResponse.success || tokenResponse.token == null) {
        return PaymentResponse(
          success: false,
          message: tokenResponse.message ?? 'Failed to generate token',
          errorCode: 'TOKEN_ERROR',
          status: 'FAILED',
          orderReference: paymentRef,
        );
      }
      
      final token = tokenResponse.token!;
      
      // Generate checksum
      final checksum = generateChecksum(
        amount: amount,
        currency: currency,
        orderReference: paymentRef,
        phoneNumber: formattedPhone,
      );
      
      // Prepare request data
      final requestData = {
        'amount': amount,
        'currency': currency,
        'orderReference': paymentRef,
        'phoneNumber': formattedPhone,
        'checksum': checksum,
      };
      
      debugPrint('Initiating USSD payment with data:');
      debugPrint('Amount: $amount');
      debugPrint('Currency: $currency');
      debugPrint('Order Reference: $paymentRef');
      debugPrint('Phone Number: $formattedPhone');
      debugPrint('Checksum: ${checksum.substring(0, 10)}...');
      debugPrint('Using token: ${token.substring(0, 10)}...');
      
      // Make API call
      final response = await _dio.post(
        _initiateUssdPushEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      // Log response for debugging
      debugPrint('ClickPesa Initiate Response: ${response.data}');
      
      // Parse initial response
      final data = response.data;
      
      // Check if the payment initiation was successful
      if (data['id'] == null && data['success'] == false) {
        // Error case with specific message
        return PaymentResponse(
          success: false,
          message: data['message'] ?? 'Payment initiation failed',
          errorCode: data['errorCode'],
          status: 'FAILED',
          orderReference: paymentRef,
          rawResponse: data,
        );
      }
      
      // Payment initiated - now check for status to confirm
      // This ensures the success status only comes after receiving the ClickPesa response
      debugPrint('Payment initiated, now checking status to confirm completion...');
      
      // Wait for a moment before checking status
      await Future.delayed(statusCheckDelay);
      
      // Poll for status a few times to get the actual result
      for (int i = 0; i < maxStatusChecks; i++) {
        try {
          final statusResponse = await checkPaymentStatus(paymentRef);
          
          if (statusResponse.isCompleted) {
            // Payment completed successfully
            return PaymentResponse(
              success: true,
              message: 'Payment completed successfully',
              status: statusResponse.status,
              transactionId: statusResponse.transactionId,
              orderReference: paymentRef,
              networkProvider: statusResponse.networkProvider ?? data['channel'],
              rawResponse: statusResponse.rawResponse,
            );
          } else if (statusResponse.isFailed) {
            // Payment failed
            return PaymentResponse(
              success: false,
              message: statusResponse.message,
              errorCode: statusResponse.errorCode,
              status: statusResponse.status,
              orderReference: paymentRef,
              rawResponse: statusResponse.rawResponse,
            );
          } else if (statusResponse.isPending && i < maxStatusChecks - 1) {
            // Still pending, wait and try again
            await Future.delayed(statusCheckDelay);
            continue;
          }
          
          // Return the last status we got, even if still pending
          return statusResponse;
        } catch (e) {
          debugPrint('Error checking payment status during initiation: $e');
          // Continue to next attempt
          await Future.delayed(statusCheckDelay);
        }
      }
      
      // If we couldn't get a definitive status, return the initial response
      return PaymentResponse(
        success: true,
        message: 'Payment initiated, but final status is pending',
        status: data['status'] ?? 'PENDING',
        transactionId: data['id'],
        orderReference: paymentRef,
        networkProvider: data['channel'],
        rawResponse: data,
      );
      
    } on ClickPesaException catch (e) {
      debugPrint('ClickPesa exception in initiate: ${e.message}');
      return PaymentResponse(
        success: false,
        message: e.message,
        errorCode: e.errorCode,
        status: 'FAILED',
        orderReference: paymentRef,
      );
    } on DioException catch (e) {
      debugPrint('DioError initiating USSD payment: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      
      // Implement retry logic for transient 500 errors
      if (e.response?.statusCode == 500 && retryCount < _maxRetries) {
        debugPrint('Retrying payment initiation (attempt ${retryCount + 1}/$_maxRetries)...');
        await Future.delayed(_retryDelay);
        return initiateUssdPayment(
          phoneNumber: phoneNumber,
          amount: amount,
          orderReference: paymentRef,
          currency: currency,
          retryCount: retryCount + 1,
        );
      }
      
      final errorMessage = e.response?.data?['message'] ?? e.message;
      final errorCode = e.response?.data?['errorCode'] ?? 'DIO_ERROR';
      
      return PaymentResponse(
        success: false,
        message: 'Error processing payment: $errorMessage',
        errorCode: errorCode,
        status: 'FAILED',
        orderReference: paymentRef,
        rawResponse: e.response?.data as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('Error initiating USSD payment: $e');
      return PaymentResponse(
        success: false,
        message: 'Error processing payment: ${e.toString()}',
        errorCode: 'CLIENT_ERROR',
        status: 'FAILED',
        orderReference: paymentRef,
      );
    }
  }
  
  /// Checks the status of a payment using its order reference
  /// 
  /// This method can be used to verify if a pending payment has been completed
  static Future<PaymentResponse> checkPaymentStatus(String orderReference) async {
    try {
      // Get authentication token
      final tokenResponse = await generateToken();
      if (!tokenResponse.success || tokenResponse.token == null) {
        return PaymentResponse(
          success: false,
          message: tokenResponse.message ?? 'Failed to generate token',
          errorCode: 'TOKEN_ERROR',
          status: 'UNKNOWN',
          orderReference: orderReference,
        );
      }
      
      final token = tokenResponse.token!;
      
      debugPrint('Checking payment status for order reference: $orderReference');
      
      // Make API call
      final response = await _dio.get(
        '$_paymentsEndpoint/$orderReference',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      // Log response for debugging
      debugPrint('ClickPesa Status Response: ${response.data}');
      
      final data = response.data;
      
      if (data is List && data.isNotEmpty) {
        final statusData = data[0];
        
        return PaymentResponse(
          success: true,
          message: statusData['message'] ?? 'Status retrieved successfully',
          status: statusData['status'] ?? 'UNKNOWN',
          transactionId: statusData['id'],
          orderReference: orderReference,
          rawResponse: statusData,
        );
      } else {
        return PaymentResponse(
          success: false,
          message: 'No payment data found for order: $orderReference',
          status: 'UNKNOWN',
          orderReference: orderReference,
        );
      }
      
    } on ClickPesaException catch (e) {
      debugPrint('ClickPesa exception in status check: ${e.message}');
      return PaymentResponse(
        success: false,
        message: e.message,
        errorCode: e.errorCode,
        status: 'FAILED',
        orderReference: orderReference,
      );
    } on DioException catch (e) {
      debugPrint('DioError checking payment status: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      
      final errorMessage = e.response?.data?['message'] ?? e.message;
      final errorCode = e.response?.data?['errorCode'] ?? 'DIO_ERROR';
      
      return PaymentResponse(
        success: false,
        message: 'Error checking payment status: $errorMessage',
        errorCode: errorCode,
        status: 'UNKNOWN',
        orderReference: orderReference,
        rawResponse: e.response?.data as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      return PaymentResponse(
        success: false,
        message: 'Error checking payment status: ${e.toString()}',
        errorCode: 'CLIENT_ERROR',
        status: 'UNKNOWN',
        orderReference: orderReference,
      );
    }
  }
  
  /// Poll payment status until completion or timeout
  ///
  /// Continuously checks payment status until SUCCESS, FAILED, or timeout
  static Future<PaymentResponse> pollPaymentStatus(
    String orderReference, {
    Duration interval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final status = await checkPaymentStatus(orderReference);
        
        if (status.isCompleted || status.isFailed) {
          return status;
        }
        
        await Future.delayed(interval);
      } catch (e) {
        // Continue polling on errors
        debugPrint('Error during polling: $e');
        await Future.delayed(interval);
      }
    }
    
    return PaymentResponse(
      success: false,
      message: 'Payment status polling timeout',
      errorCode: 'POLLING_TIMEOUT',
      status: 'TIMEOUT',
      orderReference: orderReference,
    );
  }
  
  /// Clear the stored token (for logout or testing)
  static void clearToken() {
    _token = null;
    _tokenExpiry = null;
    
    // Also clear from SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_tokenKey);
      prefs.remove(_tokenExpiryKey);
    });
  }
  
  /// Simplified method to make a mobile money payment
  /// 
  /// This method encapsulates the entire payment process:
  /// 1. Validates the phone number
  /// 2. Initiates the USSD push payment
  /// 3. Returns the payment status after receiving confirmation from ClickPesa
  /// 
  /// Use this as the main entry point for payment processing.
  static Future<PaymentResponse> makePayment({
    required String phoneNumber,
    required String amount,
    String? orderReference,
    String currency = 'TZS',
    Duration timeout = const Duration(minutes: 2),
  }) async {
    try {
      // Step 1: Validate and format the phone number
      if (!isValidPhoneNumber(phoneNumber)) {
        return PaymentResponse(
          success: false,
          message: 'Invalid phone number format. Use format 07XXXXXXXX or 255XXXXXXXXX',
          errorCode: 'INVALID_PHONE',
          status: 'FAILED',
          orderReference: orderReference,
        );
      }
      
      final formattedPhone = formatPhoneNumber(phoneNumber);
      
      // Step 2: Initiate the payment with status check
      final response = await initiateUssdPayment(
        phoneNumber: formattedPhone,
        amount: amount,
        orderReference: orderReference,
        currency: currency,
      );
      
      // Step 3: If the payment is still pending, poll for completion
      if (response.isPending) {
        debugPrint('Payment initiated, polling for completion...');
        return await pollPaymentStatus(
          response.orderReference!,
          timeout: timeout,
        );
      }
      
      return response;
    } catch (e) {
      debugPrint('Error in makePayment: $e');
      return PaymentResponse(
        success: false,
        message: 'Payment processing error: ${e.toString()}',
        errorCode: 'PAYMENT_ERROR',
        status: 'FAILED',
        orderReference: orderReference,
      );
    }
  }
}

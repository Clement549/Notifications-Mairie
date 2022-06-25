
import 'package:flutter_course/stripe/pay-out.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAccountResponse {
  late String url;
  late bool success;

  CreateAccountResponse(String url, bool success) {
    this.url = url;
    this.success = success;
  }
}

class CheckoutSessionResponse {
  late Map<String, dynamic> session;

  CheckoutSessionResponse(Map<String, dynamic> session) {
    this.session = session;
  }
}

class StripeBackendService {
  static String apiBase = 'https://backend-stripe3.vercel.app/api/stripe';
  static String createAccountUrl =
      '${StripeBackendService.apiBase}/account?mobile=true';
  static String checkoutSessionUrl =
      '${StripeBackendService.apiBase}/checkout-session?mobile=true';
  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future<CreateAccountResponse> createSellerAccount() async {
    var url = Uri.parse(StripeBackendService.createAccountUrl);
    var response = await http.get(url, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return new CreateAccountResponse(body['url'], true);
  }

  static Future<CheckoutSessionResponse> payForProduct(
      Product product, String accountId) async {
    var url = StripeBackendService.checkoutSessionUrl +
        "&account_id=$accountId&amount=${product.price}&title=${product.title}&quantity=1&currency=${product.currency}";
    Uri parsedUrl = Uri.parse(url);
    var response =
    await http.get(parsedUrl, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return new CheckoutSessionResponse(body['session']);
  }
}
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_pay_app/presantation/utils/encrypt.dart';
import 'package:near_pay_app/presantation/utils/random_util.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';
import 'package:near_pay_app/service_locator.dart';

import 'package:shared_preferences/shared_preferences.dart';


// Singleton for keystore access methods in android/iOS
class Vault {
  static const String seedKey = 'fkalium_seed';
  static const String encryptionKey = 'fkalium_secret_phrase';
  static const String pinKey = 'fkalium_pin';
  static const String sessionKey = 'fencsess_key';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> legacy() async {
    return await sl.get<SharedPrefsUtil>().useLegacyStorage();
  }

  // Re-usable
  Future<String> _write(String key, String value) async {
    if (await legacy()) {
      await setEncrypted(key, value);
    } else {
      await secureStorage.write(key: key, value: value);
    }
    return value;
  }

  Future<String> _read(String key, {required String defaultValue}) async {
    if (await legacy()) {
      return await getEncrypted(key);
    }
    return await secureStorage.read(key: key) ?? defaultValue;
  }

  Future<void> deleteAll() async {
    if (await legacy()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(encryptionKey);
      await prefs.remove(seedKey);
      await prefs.remove(pinKey);
      await prefs.remove(sessionKey);
      return;
    }
    return await secureStorage.deleteAll();
  }

  // Specific keys
  Future<String> getSeed() async {
    return await _read(seedKey, defaultValue: '');
  }

  Future<String> setSeed(String seed) async {
    return await _write(seedKey, seed);
  }

  Future<void> deleteSeed() async {
    if (await legacy()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(seedKey);
    }
    return await secureStorage.delete(key: seedKey);
  }

  Future<String> getEncryptionPhrase() async {
    return await _read(encryptionKey, defaultValue: '');
  }

  Future<String> writeEncryptionPhrase(String secret) async {
    return await _write(encryptionKey, secret);
  }

  /// Used to keep the seed in-memory in the session without being plaintext
  Future<String> getSessionKey() async {
    String key = await _read(sessionKey, defaultValue: '');
    return key;
  }

  Future<String> updateSessionKey() async {
    String key = RandomUtil.generateEncryptionSecret(25);
    await writeSessionKey(key);
    return key;
  }

  Future<String> writeSessionKey(String key) async {
    return await _write(sessionKey, key);
  }

  Future<void> deleteEncryptionPhrase() async {
    if (await legacy()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(encryptionKey);
    }
    return await secureStorage.delete(key: encryptionKey);
  }

  Future<String> getPin() async {
    return await _read(pinKey, defaultValue: '');
  }

  Future<String> writePin(String pin) async {
    return await _write(pinKey, pin);
  }

  Future<void> deletePin() async {
    if (await legacy()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(pinKey);
    }
    return await secureStorage.delete(key: pinKey);
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String value) async {
    String secret = await getSecret();
    // Decrypt and return
    Salsa20Encryptor encrypter = Salsa20Encryptor(
        secret.substring(0, secret.length - 8),
        secret.substring(secret.length - 8));
    // Encrypt and save
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String> getEncrypted(String key) async {
    String secret = await getSecret();
    // Decrypt and return
    Salsa20Encryptor encrypter = Salsa20Encryptor(
        secret.substring(0, secret.length - 8),
        secret.substring(secret.length - 8));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? encrypted = prefs.get(key);
    return encrypter.decrypt(encrypted);
  }

  static const _channel = MethodChannel('fappchannel');

  Future<String> getSecret() async {
    return await _channel.invokeMethod('getSecret');
  }
}

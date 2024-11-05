import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';

final deviceInfoPlugin = DeviceInfoPlugin();

class DeviceInformation {
  static Future<AndroidDeviceInfo> getDeviceInformation() async {
    return await deviceInfoPlugin.androidInfo;
  }

  static Future<String> getIMEI() async {
    var deviceinfo = await getDeviceInformation();
    return encrypt("a6978f1cc61d4575", deviceinfo.fingerprint).base16.substring(0, 16);
  }

  static Encrypted encrypt(String keyString, String plainText) {
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(keyString.substring(0, 16));
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData;
  }
} 
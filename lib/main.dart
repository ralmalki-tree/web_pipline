import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer';

import 'package:encrypt/encrypt.dart' as en;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

import "package:pointycastle/pointycastle.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo2 22',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Encrypter encrypter = Encrypter();

    encryptFile(Uint8List file) async {
      final encryptTheFile = encrypter.encryptFile(file);
      debugPrint('The AES key => ${encrypter.keyToBase64}');
      print('\n------------------------------------------\n');

      final encryptedKey = await encrypter.encryptedKeyToRsa();
      debugPrint('The AES key encrypted to RSA => $encryptedKey');

      print('\n------------------------------------------\n');

      print(
          'The File content encrypted using the AES before encryption => $encryptTheFile');
    }

    _uploadFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        final Uint8List fileBeforeEncryption =
            Uint8List.fromList(result.files.first.bytes!);
        final encryptedFile = encryptFile(fileBeforeEncryption);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _uploadFile,
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}

class Encrypter {
  final en.Key key = en.Key.fromBase64(utils.CreateCryptoRandomString(32));

  en.Key get getKey => key;

  en.IV get iv =>
      en.IV(Uint8List.fromList(utf8.encode(key.base64).sublist(0, 16)));

  String get keyToBase64 => key.base64;

  Future<String> encryptedKeyToRsa() async {
    final publicPem = await rootBundle.loadString('keys/public.pem');

    final parser = en.RSAKeyParser();
    final RSAPublicKey publicKey = parser.parse(publicPem) as RSAPublicKey;

    final encrypter = en.Encrypter(
      en.RSA(
        publicKey: publicKey,
        encoding: en.RSAEncoding.OAEP,
        digest: en.RSADigest.SHA256,
      ),
    );
    return encrypter.encrypt(key.base64).base64;
  }

  en.Encrypter get encrypter =>
      en.Encrypter(en.AES(key, mode: en.AESMode.cfb64));

  String encryptFile(Uint8List content) {
    return encrypter.encryptBytes(content, iv: iv).base64;
  }
}

class utils {
  static final Random _random = Random.secure();

  static String CreateCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}



/*



 _testingKeys() {
      final key = encrypt.Key.fromSecureRandom(64);
      final iv = encrypt.IV.fromSecureRandom(16);

      print('key: ${key.base64}');
      print('iv: ${iv.base64}');
      final iv2 = encrypt
          .IV(Uint8List.fromList(utf8.encode(key.base64).sublist(0, 16)));
      print('IV from key: ${iv2.base64}');
    }

    _uploadFileAES() async {
      final key = encrypt.Key.fromSecureRandom(32);
      // final iv = encrypt.IV.fromSecureRandom(16);
      final iv = encrypt
          .IV(Uint8List.fromList(utf8.encode(key.base64).sublist(0, 16)));
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        final Uint8List beforeEnc =
            Uint8List.fromList(result.files.first.bytes!);

        final encrypter =
            encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

        final encrypted = encrypter.encryptBytes(
          beforeEnc,
          iv: iv,
        );
        print(encrypted.base64);
      } else {
        // User canceled the picker
      }
    }

    _uploadFileRSA() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        final Uint8List beforeEnc =
            Uint8List.fromList(result.files.first.bytes!);

        final publicPem = await rootBundle.loadString('keys/public.pem');
        final privPem = await rootBundle.loadString('keys/private.pem');

        final parser = encrypt.RSAKeyParser();
        final RSAPublicKey publicKey = parser.parse(publicPem) as RSAPublicKey;
        final RSAPrivateKey privKey = parser.parse(privPem) as RSAPrivateKey;

        encrypt.Encrypter encrypter;
        encrypter = encrypt.Encrypter(
          encrypt.RSA(
            publicKey: publicKey,
            privateKey: privKey,
            encoding: encrypt.RSAEncoding.OAEP,
            digest: encrypt.RSADigest.SHA256,
          ),
        );

        print(beforeEnc.lengthInBytes);
        final first = beforeEnc.sublist(0, 100);
        final encrypted = encrypter.encryptBytes(
          beforeEnc,
        );
        // print(encrypted.bytes);
        print(encrypted.bytes.lengthInBytes);
      } else {
        // User canceled the picker
      }
    }

    */
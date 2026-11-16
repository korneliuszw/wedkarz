import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

@JS()
extension type _KeyPair(JSObject _) implements JSObject {
  external web.CryptoKey get publicKey;
  external web.CryptoKey get privateKey;
}

class InspectionKey {
  InspectionKey(this.alias);
  final String alias;
  Future<_KeyPair>? _pair;

  Future<JSAny?> _result(web.IDBRequest request) {
    final result = Completer<JSAny?>();
    request.onsuccess = ((web.Event _) => result.complete(request.result)).toJS;
    request.onerror = ((web.Event _) => result.completeError(
      StateError('Inspection key storage unavailable'),
    )).toJS;
    return result.future;
  }

  Future<_KeyPair> _load() async {
    final open = web.window.indexedDB.open('parseta-inspection', 1);
    open.onupgradeneeded =
        ((web.Event _) => (open.result as web.IDBDatabase).createObjectStore(
          'keys',
        )).toJS;
    final db = (await _result(open)) as web.IDBDatabase;
    try {
      final old = await _result(
        db.transaction('keys'.toJS).objectStore('keys').get(alias.toJS),
      );
      if (old != null) return old as _KeyPair;
      final algorithm = {'name': 'ECDSA', 'namedCurve': 'P-256'}.jsify()!;
      final generated =
          (await web.window.crypto.subtle
                  .generateKey(
                    algorithm,
                    false,
                    ['sign'.toJS, 'verify'.toJS].toJS,
                  )
                  .toDart)
              as _KeyPair;
      final tx = db.transaction('keys'.toJS, 'readwrite');
      final committed = Completer<void>();
      tx.oncomplete = ((web.Event _) => committed.complete()).toJS;
      tx.onabort = ((web.Event _) => committed.completeError(
        StateError('Could not persist inspection key'),
      )).toJS;
      tx.objectStore('keys').put(generated, alias.toJS);
      await committed.future;
      return generated;
    } finally {
      db.close();
    }
  }

  Future<Uint8List> publicKey() async {
    final pair = await (_pair ??= _load());
    final bytes =
        (await web.window.crypto.subtle.exportKey('raw', pair.publicKey).toDart)
            as JSArrayBuffer;
    return bytes.toDart.asUint8List();
  }

  Future<Uint8List> sign(Uint8List data) async {
    final pair = await (_pair ??= _load());
    final algorithm = {'name': 'ECDSA', 'hash': 'SHA-256'}.jsify()!;
    final bytes =
        (await web.window.crypto.subtle
                .sign(algorithm, pair.privateKey, data.toJS)
                .toDart)
            as JSArrayBuffer;
    return bytes.toDart.asUint8List();
  }
}

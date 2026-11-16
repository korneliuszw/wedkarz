package pl.parseta.inspection

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.ECGenParameterSpec

object InspectionKeyChannel {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "pl.parseta/inspection")
            .setMethodCallHandler { call, result ->
                try {
                    val alias = "parseta.inspection." + requireNotNull(call.argument<String>("alias"))
                    val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                    when (call.method) {
                        "publicKey" -> {
                            if (!store.containsAlias(alias)) {
                                KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
                                    .apply {
                                        initialize(KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_SIGN)
                                            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                                            .setDigests(KeyProperties.DIGEST_SHA256).build())
                                    }.generateKeyPair()
                            }
                            val key = store.getCertificate(alias).publicKey as ECPublicKey
                            result.success(byteArrayOf(4) + fixedWidth(key.w.affineX.toByteArray())
                                + fixedWidth(key.w.affineY.toByteArray()))
                        }
                        "sign" -> {
                            val entry = store.getEntry(alias, null) as KeyStore.PrivateKeyEntry
                            val der = Signature.getInstance("SHA256withECDSA").run {
                                initSign(entry.privateKey)
                                update(requireNotNull(call.argument<ByteArray>("data")))
                                sign()
                            }
                            result.success(rawSignature(der))
                        }
                        else -> result.notImplemented()
                    }
                } catch (_: Exception) {
                    result.error("inspection_key", "Inspection key unavailable", null)
                }
            }
    }

    private fun fixedWidth(bytes: ByteArray): ByteArray {
        val value = if (bytes.size == 33 && bytes[0] == 0.toByte()) bytes.copyOfRange(1, 33) else bytes
        require(value.size <= 32)
        return ByteArray(32 - value.size) + value
    }

    private fun rawSignature(der: ByteArray): ByteArray {
        require(der.size in 8..72 && der[0] == 0x30.toByte() && der[1].toInt() == der.size - 2)
        require(der[2] == 2.toByte())
        val rEnd = 4 + der[3].toInt()
        require(rEnd in 5..(der.size - 3) && der[rEnd] == 2.toByte())
        val sStart = rEnd + 2
        require(der[rEnd + 1].toInt() == der.size - sStart)
        return fixedWidth(der.copyOfRange(4, rEnd)) + fixedWidth(der.copyOfRange(sStart, der.size))
    }
}

package pl.parseta.nad_parseta

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import pl.parseta.inspection.InspectionKeyChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        InspectionKeyChannel.register(flutterEngine.dartExecutor.binaryMessenger)
    }
}

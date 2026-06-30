/// Abstraction over a UHF RFID reader, so UI code never talks to vendor
/// SDK / hardware directly. Swap [MockUhfReaderService] for a real
/// implementation later (e.g. one that bridges to a vendor SDK via
/// MethodChannel, or talks LLRP to the fixed reader+antenna) without
/// touching any page that uses this service.
abstract class UhfReaderService {
  /// Connect / initialize the reader. Call once, e.g. on page init or
  /// app start. Returns false if connection failed.
  Future<bool> connect();

  /// Trigger a single scan attempt and return the EPC of the first tag
  /// detected within [timeout]. Returns null on timeout / no tag found.
  /// This is the "press SCAN button" action — not continuous listening.
  Future<String?> scanOnce({Duration timeout = const Duration(seconds: 3)});

  /// Write a new EPC value onto whatever tag is currently in range.
  /// Only needed for the "tagging" flow (writing a fresh/reused tag),
  /// not for read-only lookup scans.
  Future<void> writeTag(String epc);

  /// Release reader resources, e.g. on page dispose.
  Future<void> disconnect();
}

/// Temporary stand-in until real hardware/SDK is wired up. Returns a
/// fake but realistic-looking EPC after a short delay, so UI/UX and
/// backend binding logic can be built and tested end-to-end now.
class MockUhfReaderService implements UhfReaderService {
  @override
  Future<bool> connect() async => true;

  @override
  Future<String?> scanOnce({Duration timeout = const Duration(seconds: 3)}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    // Fake EPC — replace this whole method body with real reader call later.
    return 'EPC-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> writeTag(String epc) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> disconnect() async {}
}
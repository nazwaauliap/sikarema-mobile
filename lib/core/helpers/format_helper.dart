/// =====================================================================
/// FORMAT HELPER
/// =====================================================================
/// Kumpulan fungsi format tampilan (Rupiah, tanggal Indonesia) yang
/// dipakai lintas fitur, supaya tidak ada logic format yang
/// diduplikasi di beberapa tempat (mis. JenisRewardModel.nominalFormatted
/// & RiwayatKlaimScreen sama-sama butuh format Rupiah).
///
/// Format tanggal SENGAJA tidak memakai `intl`'s DateFormat dengan
/// locale 'id_ID', karena locale data itu perlu di-inisialisasi lebih
/// dulu (initializeDateFormatting) dan project ini belum melakukannya
/// di mana pun — daripada menambah inisialisasi baru yang berisiko
/// mengubah bagian lain, dipakai pemetaan bulan manual yang sederhana
/// dan aman dari error locale.
/// =====================================================================
class FormatHelper {
  FormatHelper._();

  static const List<String> _bulanIndo = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Format angka/string nominal ("500000", "500000.00", 500000) jadi
  /// "Rp500.000".
  static String rupiah(Object? nominal) {
    final value = double.tryParse(nominal?.toString() ?? '') ?? 0;
    final intValue = value.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  /// Format tanggal ISO ("2026-07-24") jadi "24 Jul 2026". Jika format
  /// tidak sesuai, kembalikan string aslinya apa adanya (tidak
  /// menyembunyikan data walau gagal parse).
  static String tanggalIndo(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = _bulanIndo[parsed.month - 1];
    return '$day $month ${parsed.year}';
  }
}
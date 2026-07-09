// === MOBİL PARÇA 1 BAŞLANGICI ===
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SSRestoranMobilApp());
}

// KRİTİK BAĞLANTI AYARI: Bilgisayarınızın siyah cmd ekranından bulduğunuz IPv4 adresini buraya yazın.
// Örn: "192.168.1.45" gibi. Sonundaki :8080 portunu ve tırnakları kesinlikle silmeyin.
const String ANA_BILGISAYAR_URL = "http://192.168.1.45:8080";

class SSRestoranMobilApp extends StatelessWidget {
  const SSRestoranMobilApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SS Restoran El Terminali',
      debugShowCheckedModeBanner: false,
      // Masaüstüyle tam uyumlu, gözü yormayan asil Mürekkep Mavisi teması
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF001F3F),
        primaryColor: const Color(0xFF004B93),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1329),
          elevation: 2,
        ),
      ),
      home: const MobilGirisEkrani(),
    );
  }
}
// === MOBİL PARÇA 1 SONU ===
// === MOBİL PARÇA 2 BAŞLANGICI ===
class MobilGirisEkrani extends StatefulWidget {
  const MobilGirisEkrani({Key? key}) : super(key: key);

  @override
  State<MobilGirisEkrani> createState() => _MobilGirisEkraniState();
}

class _MobilGirisEkraniState extends State<MobilGirisEkrani> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _loading = false;

  // Ana bilgisayardaki API sunucusu ile el terminali giriş doğrulama köprüsü
  Future<void> _sistemeGirisYap() async {
    final kAdi = _userCtrl.text.trim();
    final sifre = _passCtrl.text.trim();

    if (kAdi.isEmpty || sifre.isEmpty) {
      _mesajGoster("⚠️ Lütfen kullanıcı adı ve şifrenizi giriniz.");
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("$ANA_BILGISAYAR_URL/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"kullanici_adi": kAdi, "sifre": sifre}),
      );

      if (response.statusCode == 200) {
        final veri = jsonDecode(response.body);
        if (veri["status"] == "success") {
          // Giriş başarılı ise garson adıyla birlikte salon masa planına geçiş yap
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MobilSalonPlaniEkrani(garsonAdi: veri["garson_adi"].toString()),
            ),
          );
        } else {
          _mesajGoster("❌ ${veri["message"]}");
        }
      } else {
        _mesajGoster("⚠️ Sunucu hatası! Kod: ${response.statusCode}");
      }
    } catch (e) {
      _mesajGoster("🔌 Ana bilgisayara bağlanılamadı!\nIP adresini ve Wi-Fi ağını kontrol edin.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }
// === MOBİL PARÇA 2 SONU ===
// === MOBİL PARÇA 3 BAŞLANGICI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "SS RESTORAN",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.black, letterSpacing: 2),
              ),
              const Text(
                "El Terminali Giriş Sistemi",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFcbd5e1), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              // Kullanıcı Adı Giriş Kutusu
              TextField(
                controller: _userCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Kullanıcı Adı",
                  labelStyle: const TextStyle(color: Color(0xFFcbd5e1)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF38bdf8)),
                  filled: true,
                  fillColor: const Color(0xFF0B1329),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF004B93)), borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              // Şifre Giriş Kutusu
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Mobil Giriş Şifresi",
                  labelStyle: const TextStyle(color: Color(0xFFcbd5e1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF38bdf8)),
                  filled: true,
                  fillColor: const Color(0xFF0B1329),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF004B93)), borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              // Giriş Butonu
              ElevatedButton(
                onPressed: _loading ? null : _sistemeGirisYap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004B93),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SİSTEME GİRİŞ YAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// === MOBİL PARÇA 3 SONU ===
// === MOBİL PARÇA 4 BAŞLANGICI ===
class MobilSalonPlaniEkrani extends StatefulWidget {
  final String garsonAdi;
  const MobilSalonPlaniEkrani({Key? key, required this.garsonAdi}) : super(key: key);

  @override
  State<MobilSalonPlaniEkrani> createState() => _MobilSalonPlaniEkraniState();
}

class _MobilSalonPlaniEkraniState extends State<MobilSalonPlaniEkrani> {
  List<dynamic> _masalar = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _masalariYukle();
  }

  // Ana bilgisayardan anlık masa listesini ve durumlarını çeken HTTP motoru
  Future<void> _masalariYukle() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse("$ANA_BILGISAYAR_URL/masalar"));
      if (response.statusCode == 200) {
        setState(() {
          _masalar = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔌 Salon planı güncellenemedi, bağlantıyı kontrol edin.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
// === MOBİL PARÇA 4 SONU ===
// === MOBİL PARÇA 5 BAŞLANGICI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🪑 SALON PLANI - ${widget.garsonAdi.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _masalariYukle,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _masalar.length,
              itemBuilder: (context, index) {
                final masa = _masalar[index];
                final String masaAdi = masa["masa_adi"].toString();
                final String durum = masa["durum"].toString();
                final double tutar = double.tryParse(masa["toplam_tutar"].toString()) ?? 0.0;
                final bool isDolu = durum == "Dolu";

                return InkWell(
                  onTap: () async {
                    // Masaya tıklandığında sipariş ekleme ekranına fırlat
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobilSiparisEkleEkrani(masaAdi: masaAdi, garsonAdi: widget.garsonAdi),
                      ),
                    );
                    _masalariYukle(); // Geri dönüldüğünde masa listesini canlı tazele
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // Masaüstündeki gibi: Boşlar Bordo, Dolular Canlı Kırmızı
                      color: isDolu ? const Color(0xFFF43F5E) : const Color(0xFF800020),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDolu ? const Color(0xFFE11D48) : const Color(0xFF5C0017), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.table_restaurant, size: 36, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(masaAdi, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(durum, style: TextStyle(color: isDolu ? Colors.white : const Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w600)),
                        if (isDolu) ...[
                          const SizedBox(height: 6),
                          Text("${tutar.toStringAsFixed(2)} TL", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.black)),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
// === MOBİL PARÇA 5 SONU ===
// === MOBİL PARÇA 6 BAŞLANGICI ===
class MobilSiparisEkleEkrani extends StatefulWidget {
  final String masaAdi;
  final String garsonAdi;
  const MobilSiparisEkleEkrani({Key? key, required this.masaAdi, required this.garsonAdi}) : super(key: key);

  @override
  State<MobilSiparisEkleEkrani> createState() => _MobilSiparisEkleEkraniState();
}

class _MobilSiparisEkleEkraniState extends State<MobilSiparisEkleEkrani> {
  String? _secilenUrun;
  double _secilenUrunFiyat = 0.0;
  int _adet = 1;
  bool _sending = false;

  // Masaüstünde combobox eşitlemesi için örnek el terminali sipariş gönderim fonksiyonu
  Future<void> _siparisEkle() async {
    if (_secilenUrun == null) return;
    setState(() => _sending = true);
    
    try {
      final response = await http.post(
        Uri.parse("$ANA_BILGISAYAR_URL/siparis_ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "masa_adi": widget.masaAdi,
          "urun_adi": _secilenUrun,
          "adet": _adet,
          "fiyat": _secilenUrunFiyat,
          "garson_adi": widget.garsonAdi
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✔️ Sipariş mutfak kuyruğuna iletildi!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔌 Sipariş gönderilemedi!")));
    } finally {
      setState(() => _sending = false);
    }
  }
// === MOBİL PARÇA 6 SONU ===
// === MOBİL PARÇA 7 BAŞLANGICI ===
  @override
  Widget build(BuildContext context) {
    // Mobil garsonların masaya hızlıca ekleme yapabileceği popüler ürün listesi
    final List<Map<String, dynamic>> menuElemanlari = [
      {"ad": "Mercimek Çorbası", "fiyat": 120.0},
      {"ad": "Adana Kebap", "fiyat": 320.0},
      {"ad": "Ayran", "fiyat": 45.0},
      {"ad": "Künefe", "fiyat": 150.0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("➕ ${widget.masaAdi.toUpperCase()} - SİPARİŞ", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "🍔 MENÜDEN ÜRÜN SEÇİN",
              style: TextStyle(color: Color(0xFFcbd5e1), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            // Dinamik Ürün Seçim Menüsü
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF111a31),
              value: _secilenUrun,
              hint: const Text("Seçim Yapınız...", style: TextStyle(color: Colors.white54)),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0B1329),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF004B93)), borderRadius: BorderRadius.circular(8)),
              ),
              items: menuElemanlari.map((urun) {
                return DropdownMenuItem<String>(
                  value: urun["ad"].toString(),
                  onTap: () => _secilenUrunFiyat = urun["fiyat"],
                  child: Text("${urun['ad']} (${urun['fiyat'].toStringAsFixed(2)} TL)"),
                );
              }).toList(),
              onChanged: (val) => setState(() => _secilenUrun = val),
            ),
            const SizedBox(height: 24),
            const Text(
              "🔢 ADET AYARI",
              style: TextStyle(color: Color(0xFFcbd5e1), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            // Adet Artırma ve Azaltma Sayacı
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 40, color: Color(0xFFf43f5e)),
                  onPressed: () { if (_adet > 1) setState(() => _adet--); },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  boxShadow: const [],
                  child: Text("$_adet", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.black)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 40, color: Color(0xFF4ade80)),
                  onPressed: () => setState(() => _adet++),
                ),
              ],
            ),
            const Spacer(),
            // Mutfak Gönderim Butonu
            ElevatedButton(
              onPressed: (_secilenUrun == null || _sending) ? null : _siparisEkle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e7d32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _sending
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("MUTFAĞA GÖNDER (1 DK GECİKMELİ)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
// === MOBİL PARÇA 7 SONU ===

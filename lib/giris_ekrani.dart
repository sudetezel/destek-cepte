import 'package:flutter/material.dart';
import 'servis.dart';
import 'ogrenci_home.dart';
import 'bagisci_home.dart';

class GirisEkrani extends StatefulWidget {
  final String secilenRol;
  const GirisEkrani({super.key, required this.secilenRol});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final Servis _servis = Servis();
  final _formKey = GlobalKey<FormState>(); // Form kontrolü için anahtar

  bool girisModu = true;
  bool yukleniyor = false; // Yükleniyor animasyonu için

  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _sifreC = TextEditingController();
  final TextEditingController _adC = TextEditingController();
  final TextEditingController _tcC = TextEditingController();
  final TextEditingController _telC = TextEditingController();

  void islemYap() async {
    // Form geçerli mi kontrol et
    if (_formKey.currentState!.validate()) {
      setState(() => yukleniyor = true);
      String? sonuc;

      if (girisModu) {
        sonuc = await _servis.girisYap(
          _emailC.text.trim(),
          _sifreC.text.trim(),
        );
      } else {
        Map<String, dynamic> veriler = {
          'isim': _adC.text.trim(),
          'telefon': _telC.text.trim(),
        };
        if (widget.secilenRol == "ogrenci") {
          veriler['tc'] = _tcC.text.trim();
          veriler['transkript'] = "";
          veriler['ogrenci_belgesi'] = "";
          veriler['iban'] = "";
        }

        sonuc = await _servis.kayitOl(
          _emailC.text.trim(),
          _sifreC.text.trim(),
          widget.secilenRol,
          veriler,
        );
      }

      setState(() => yukleniyor = false);

      if (sonuc == null) {
        // Başarılı
        if (!mounted) return;
        if (widget.secilenRol == "ogrenci") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OgrenciHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BagisciHome()),
          );
        }
      } else {
        // Hata Mesajı
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sonuc),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.secilenRol == 'ogrenci' ? 'Öğrenci' : 'Bağışçı'} ${girisModu ? 'Girişi' : 'Kaydı'}",
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-Posta",
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "E-posta gerekli";
                    if (!val.contains("@")) return "Geçerli bir e-posta girin";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _sifreC,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (val) => (val != null && val.length < 6)
                      ? "Şifre en az 6 karakter olmalı"
                      : null,
                ),

                if (!girisModu) ...[
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _adC,
                    decoration: const InputDecoration(
                      labelText: "Ad Soyad / Kurum Adı",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => (val == null || val.isEmpty)
                        ? "İsim alanı boş kalamaz"
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _telC,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Telefon",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (val) =>
                        (val == null || val.isEmpty) ? "Telefon gerekli" : null,
                  ),
                  if (widget.secilenRol == "ogrenci") ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _tcC,
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      decoration: const InputDecoration(
                        labelText: "TC Kimlik No",
                        prefixIcon: Icon(Icons.badge),
                        counterText: "",
                      ),
                      validator: (val) => (val == null || val.length != 11)
                          ? "11 haneli TC giriniz"
                          : null,
                    ),
                  ],
                ],

                const SizedBox(height: 30),
                yukleniyor
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: islemYap,
                        child: Text(
                          girisModu ? "GİRİŞ YAP" : "KAYIT OL",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      girisModu = !girisModu;
                      _formKey.currentState
                          ?.reset(); // Hata mesajlarını temizle
                    });
                  },
                  child: Text(
                    girisModu
                        ? "Hesabın yok mu? Kayıt Ol"
                        : "Zaten hesabın var mı? Giriş Yap",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

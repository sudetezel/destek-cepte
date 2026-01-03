import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // Linki kontrol etmek/açmak için

class OgrenciProfil extends StatefulWidget {
  const OgrenciProfil({super.key});

  @override
  State<OgrenciProfil> createState() => _OgrenciProfilState();
}

class _OgrenciProfilState extends State<OgrenciProfil> {
  // Servis çağırmaya gerek kalmadı, işlemleri burada halledeceğiz.
  final TextEditingController _ibanC = TextEditingController();
  final TextEditingController _linkController =
      TextEditingController(); // Link girişi için

  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool yukleniyor = false;

  // Link Ekleme Penceresi (Dosya yükleme yerine bunu kullanacağız)
  void belgeLinkiEkle(String alanAdi, String mevcutLink) {
    _linkController.text = mevcutLink; // Varsa eski linki göster

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.link, color: Colors.teal),
            SizedBox(width: 10),
            Text("Belge Linki Ekle"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Dosyanızı Google Drive veya benzeri bir buluta yükleyip, paylaşım linkini buraya yapıştırınız.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: "Link Yapıştır",
                hintText: "https://drive.google.com/...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.http),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (_linkController.text.isEmpty) return;

              Navigator.pop(context); // Pencereyi kapat
              await linkiKaydet(alanAdi, _linkController.text.trim());
            },
            child: const Text("KAYDET", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Linki Veritabanına Kaydetme
  Future<void> linkiKaydet(String alanAdi, String link) async {
    setState(() => yukleniyor = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        alanAdi: link,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link başarıyla kaydedildi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
    setState(() => yukleniyor = false);
  }

  // Linki Test Etme (Açma)
  void linkiAc(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link açılamadı, hatalı olabilir.")),
      );
    }
  }

  // IBAN Kaydetme
  void ibanKaydet() async {
    if (_ibanC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen IBAN giriniz")));
      return;
    }
    setState(() => yukleniyor = true);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'iban': _ibanC.text,
    });
    setState(() => yukleniyor = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("IBAN Kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilim")),
      body: Stack(
        children: [
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text("Hata oluştu"));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              var data = snapshot.data!;

              // IBAN verisini controller'a ata
              if (_ibanC.text.isEmpty && data['iban'] != null) {
                _ibanC.text = data['iban'];
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${data['isim']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${data['email']}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 30),

                    // IBAN KARTI
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Banka Bilgileri",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _ibanC,
                              decoration: const InputDecoration(
                                labelText: "TR - IBAN Numaranız",
                                prefixIcon: Icon(Icons.credit_card),
                                hintText: "TR00 0000 ...",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: ibanKaydet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("IBAN GÜNCELLE"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BELGELER KARTI (Link Sistemi)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Belgelerim (Link)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Dosya yükleme sorunu yaşamamak için lütfen Google Drive linki ekleyiniz.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(height: 20),

                            _buildLinkTile(
                              baslik: "Transkript",
                              linkVerisi: data['transkript'],
                              alanAdi: "transkript",
                            ),
                            const Divider(),
                            _buildLinkTile(
                              baslik: "Öğrenci Belgesi",
                              linkVerisi: data['ogrenci_belgesi'],
                              alanAdi: "ogrenci_belgesi",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (yukleniyor)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Liste Elemanı Tasarımı
  Widget _buildLinkTile({
    required String baslik,
    required String linkVerisi,
    required String alanAdi,
  }) {
    bool linkVar = linkVerisi.isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: linkVar ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          linkVar ? Icons.check : Icons.link_off,
          color: linkVar ? Colors.green : Colors.red,
        ),
      ),
      title: Text(baslik),
      subtitle: Text(
        linkVar ? "Link eklendi" : "Link bekleniyor",
        style: TextStyle(color: linkVar ? Colors.green : Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Eğer link varsa "Göz" ikonu koyalım ki kontrol etsin
          if (linkVar)
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              tooltip: "Linki Aç",
              onPressed: () => linkiAc(linkVerisi),
            ),

          ElevatedButton(
            onPressed: () => belgeLinkiEkle(alanAdi, linkVerisi),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.teal.shade50,
              foregroundColor: Colors.teal,
              elevation: 0,
            ),
            child: Text(linkVar ? "Düzenle" : "Ekle"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'servis.dart';

class BagisciHome extends StatefulWidget {
  const BagisciHome({super.key});

  @override
  State<BagisciHome> createState() => _BagisciHomeState();
}

class _BagisciHomeState extends State<BagisciHome> {
  final Servis _servis = Servis();
  final _baslikC = TextEditingController();
  final _miktarC = TextEditingController();
  String _secilenBolum = "Bilgisayar Müh.";

  void ilanEklePenceresi() {
    // Controllerları temizle
    _baslikC.clear();
    _miktarC.clear();

    showDialog(
      context: context,
      builder: (context) {
        String yerelBolum = _secilenBolum;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Yeni Burs İlanı Oluştur"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _baslikC,
                    decoration: const InputDecoration(
                      labelText: "Burs Başlığı",
                      hintText: "Örn: Başarı Bursu",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _miktarC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Aylık Miktar (TL)",
                      suffixText: "TL",
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: yerelBolum,
                    decoration: const InputDecoration(labelText: "Hedef Bölüm"),
                    items: ["Bilgisayar Müh.", "Hukuk", "Tıp", "İnşaat Müh."]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => yerelBolum = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "İptal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_baslikC.text.isEmpty || _miktarC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun"),
                        ),
                      );
                      return;
                    }
                    _servis.ilanEkle(_baslikC.text, yerelBolum, _miktarC.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("İlan başarıyla oluşturuldu!"),
                      ),
                    );
                  },
                  child: const Text("YAYIMLA"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void basvuranlariGoster(String ilanId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Başvuran Öğrenciler",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('basvurular')
                    .where('ilan_id', isEqualTo: ilanId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Henüz başvuru yok.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var basvuru = snapshot.data!.docs[index];
                      var ogrenci = basvuru['ogrenci_bilgileri'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            child: Text(ogrenci['isim'][0].toUpperCase()),
                          ),
                          title: Text(
                            ogrenci['isim'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("TC: ${ogrenci['tc']}"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    Icons.phone,
                                    "Telefon",
                                    ogrenci['telefon'],
                                  ),
                                  _infoRow(
                                    Icons.credit_card,
                                    "IBAN",
                                    ogrenci['iban'],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.description,
                                          color: Colors.red,
                                        ),
                                        label: const Text("Transkript"),
                                        onPressed: () =>
                                            _urlAc(ogrenci['transkript']),
                                      ),
                                      OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.school,
                                          color: Colors.blue,
                                        ),
                                        label: const Text("Öğr. Belgesi"),
                                        onPressed: () =>
                                            _urlAc(ogrenci['ogrenci_belgesi']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _urlAc(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Link açılamadı")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Belge yüklenmemiş")));
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bağışçı Paneli")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ilanEklePenceresi,
        backgroundColor: const Color(0xFFFFA000),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("İLAN EKLE", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('burs_ilanlari')
            .where(
              'bagisci_id',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.volunteer_activism, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "Henüz bir ilan paylaşmadınız.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ilan = snapshot.data!.docs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.list_alt, color: Colors.teal),
                  ),
                  title: Text(
                    ilan['baslik'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${ilan['gerekli_bolum']} \n${ilan['miktar']} TL",
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                  trailing: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, color: Colors.grey),
                      Text("Başvurular", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  onTap: () => basvuranlariGoster(ilan.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

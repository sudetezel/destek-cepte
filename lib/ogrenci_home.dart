import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'servis.dart';
import 'ogrenci_profil.dart';

class OgrenciHome extends StatefulWidget {
  const OgrenciHome({super.key});

  @override
  State<OgrenciHome> createState() => _OgrenciHomeState();
}

class _OgrenciHomeState extends State<OgrenciHome> {
  final Servis _servis = Servis();
  String secilenBolum = "Tümü";

  void bursaBasvur(String ilanId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Yükleniyor göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      Navigator.pop(context); // Yükleniyor'u kapat

      String transkript = userDoc['transkript'] ?? "";
      String iban = userDoc['iban'] ?? "";

      if (transkript.isEmpty || iban.isEmpty) {
        if (!mounted) return;
        _eksikBilgiUyarisi();
      } else {
        await _servis.basvuruYap(
          ilanId,
          userDoc.data() as Map<String, dynamic>,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Başvuru Başarıyla Gönderildi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  void _eksikBilgiUyarisi() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 10),
            Text("Eksik Bilgi"),
          ],
        ),
        content: const Text(
          "Başvuru yapmadan önce Profil sayfasından Transkript belgeni yüklemeli ve IBAN bilgisini girmelisin.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OgrenciProfil()),
              );
            },
            child: const Text("Profile Git"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Burs Fırsatları"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OgrenciProfil()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // FİLTRE KISMI
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Bölüme Göre Filtrele",
                prefixIcon: Icon(Icons.filter_list),
              ),
              value: secilenBolum,
              items: ["Tümü", "Bilgisayar Müh.", "Hukuk", "Tıp", "İnşaat Müh."]
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => secilenBolum = val!),
            ),
          ),

          // LİSTE KISMI
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('burs_ilanlari')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Bir hata oluştu"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var ilanlar = snapshot.data!.docs;
                if (secilenBolum != "Tümü") {
                  ilanlar = ilanlar
                      .where((doc) => doc['gerekli_bolum'] == secilenBolum)
                      .toList();
                }

                if (ilanlar.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Bu kategoride ilan bulunamadı.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ilanlar.length,
                  itemBuilder: (context, index) {
                    var ilan = ilanlar[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.teal,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ilan['baslik'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(ilan['gerekli_bolum']),
                                        backgroundColor: Colors.teal.shade50,
                                        labelStyle: const TextStyle(
                                          color: Colors.teal,
                                          fontSize: 12,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${ilan['miktar']} TL / Ay",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => bursaBasvur(ilan.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text("BAŞVUR"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

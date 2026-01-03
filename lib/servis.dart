import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Servis {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FirebaseStorage ve FilePicker kaldırıldı, artık ihtiyacımız yok.

  // 1. KAYIT OLMA FONKSİYONU
  Future<String?> kayitOl(
    String email,
    String password,
    String rol,
    Map<String, dynamic> ekBilgiler,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'rol': rol,
        ...ekBilgiler,
      });
      return null; // Başarılı
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Şifre çok zayıf.';
      if (e.code == 'email-already-in-use')
        return 'Bu e-posta zaten kullanımda.';
      if (e.code == 'invalid-email') return 'Geçersiz e-posta formatı.';
      return 'Bir hata oluştu: ${e.message}';
    } catch (e) {
      return 'Beklenmedik bir hata: $e';
    }
  }

  // 2. GİRİŞ YAPMA FONKSİYONU
  Future<String?> girisYap(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Kullanıcı bulunamadı.';
      if (e.code == 'wrong-password') return 'Şifre yanlış.';
      if (e.code == 'invalid-email') return 'Geçersiz e-posta adresi.';
      return 'Giriş hatası: ${e.message}';
    } catch (e) {
      return 'Bağlantı hatası: $e';
    }
  }

  // 3. KULLANICI ROLÜNÜ ÖĞRENME
  Future<String> rolGetir() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc['rol'];
    } catch (e) {
      return "hata";
    }
  }

  // 4. BELGE LİNKİ KAYDETME (YENİ FONKSİYON)
  // Dosya yüklemek yerine, Drive linkini veritabanına yazar.
  Future<void> belgeLinkiKaydet(String alanAdi, String link) async {
    String uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({alanAdi: link});
  }

  // 5. İLAN EKLE
  Future<void> ilanEkle(String baslik, String bolum, String miktar) async {
    await _firestore.collection('burs_ilanlari').add({
      'baslik': baslik,
      'gerekli_bolum': bolum,
      'miktar': miktar,
      'bagisci_id': _auth.currentUser!.uid,
      'tarih': FieldValue.serverTimestamp(),
    });
  }

  // 6. BAŞVURU YAP
  Future<void> basvuruYap(
    String ilanId,
    Map<String, dynamic> ogrenciBilgileri,
  ) async {
    await _firestore.collection('basvurular').add({
      'ilan_id': ilanId,
      'ogrenci_id': _auth.currentUser!.uid,
      'ogrenci_bilgileri': ogrenciBilgileri,
      'durum': 'Bekliyor',
      'tarih': FieldValue.serverTimestamp(),
    });
  }
}

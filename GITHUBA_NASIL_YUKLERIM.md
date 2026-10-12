# DEST-OS ARES — GitHub’a Nasıl Yüklerim? (Adım Adım)

Kod bilmenize gerek yok. Sadece tarayıcı ile yapacaksınız.

---

## 1. Yeni boş repository oluştur

1. https://github.com adresine girin ve giriş yapın.
2. Sağ üstteki **+** işaretine tıklayın → **New repository** seçin.
3. Repository adı yazın (örnek: `dest-os-ares`).
4. **Public** veya **Private** seçin (isterseniz Private yapın).
5. “Add a README file” kutusunu **işaretlemeyin** (boş kalsın).
6. **Create repository** butonuna basın.

---

## 2. ZIP dosyasını bilgisayarınıza indirin

Size verdiğim ZIP dosyasını bilgisayarınıza indirin ve bir klasöre çıkarın (sağ tık → Extract / Ayıkla).

Çıkan klasörün içinde şunlar olmalı:
- `lib`
- `android`
- `assets`
- `.github`
- `pubspec.yaml`
- `README_TR.md`

---

## 3. GitHub’a yükleme (en kolay yol)

### Yöntem A — Web üzerinden sürükle-bırak (önerilen)

1. Yeni oluşturduğunuz boş repository sayfasına gidin.
2. Ortada **uploading an existing file** yazısına tıklayın.
3. Bilgisayarınızda ZIP’ten çıkardığınız **tüm dosya ve klasörleri** seçin (Ctrl+A ile hepsini seçebilirsiniz).
4. GitHub sayfasına sürükleyip bırakın.
5. Altta “Commit changes” yazan yeşil butona basın.

### Yöntem B — ZIP’i doğrudan yükleme (GitHub desteklemiyor)

GitHub web arayüzü ZIP’i tek seferde açıp yüklemez. Bu yüzden önce ZIP’i açmanız, sonra dosyaları sürüklemeniz gerekir.

---

## 4. İlk derlemeyi çalıştırma

1. Repository’nizde üst menüden **Actions** sekmesine tıklayın.
2. Sol taraftan **ARES APK Build** seçin.
3. Sağda **Run workflow** butonuna basın → tekrar **Run workflow**.
4. Birkaç dakika bekleyin.
5. Yeşil tik çıkarsa başarılı demektir.
6. Başarılı olunca **Artifacts** bölümünden APK dosyasını indirebilirsiniz.

Hata çıkarsa kırmızı X’e tıklayıp hata mesajının ekran görüntüsünü alın ve bana gönderin.

---

## Önemli uyarılar

- API anahtarı, şifre, keystore gibi gizli bilgileri **asla** yüklemeyin.
- Proje şu an kişisel kullanım içindir.
- İlk açılışta yerel (ücretsiz) yapay zeka ile çalışacak şekilde ayarlanmıştır.

Başarılar.

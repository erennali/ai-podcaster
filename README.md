# AI Podcaster

Yapay Zeka Destekli Podcast Üretim ve Paylaşım iOS Uygulaması

## Proje Hakkında

AI Podcaster, kullanıcıların yapay zeka teknolojisini kullanarak kolayca podcast içeriği oluşturmasını, düzenlemesini ve paylaşmasını sağlayan iOS tabanlı bir mobil uygulamadır. Kullanıcılar seçtikleri konu, süre ve üslup tercihlerine göre metinler oluşturabilir ve bu metinleri doğal insan sesine dönüştürebilirler.

## Özellikler

- ✅ Splash Screen: Animasyonlu giriş ekranı
- ✅ Tab Bar Navigasyon: Ana ekranlar arası geçiş
- 🔄 Kullanıcı Girişi ve Kayıt: Email/Şifre ve Apple ID ile giriş
- 🔄 Yapay Zeka ile Podcast Üretimi: Konu, süre ve üslup seçimleriyle özgün içerik oluşturma
- 🔄 Podcast Kitaplığı: Oluşturulan içeriklerin yönetimi
- 🔄 Topluluk: Diğer kullanıcıların paylaştığı içeriklere erişim
- 🔄 Ayarlar: Uygulama ve profil yönetimi

## Teknoloji Stack'i

- **Dil**: Swift 5.9+
- **UI Framework**: UIKit ,SnapKit
- **Mimari**: MVVM + Coordinator Pattern
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **API'ler**:
  - OpenAI GPT-4 / Google Gemini Pro (İçerik Oluşturma)
  - ElevenLabs / Google Cloud Text-to-Speech (Ses Dönüşümü)
- **Ağ İstekleri**: Alamofire
- **Görüntü**: Kingfisher
- **Analitik**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Bildirimler**: Firebase Cloud Messaging (FCM) , OneSignal, Push Notification Service

## Kurulum

1. Bu repository'yi klonlayın:
```bash
git clone https://github.com/erennali/ai-podcaster.git
```

2. Proje dizinine gidin:
```bash
cd ai-podcaster
```

3. Gerekli SPM'lerı yükleyin:
```bash
swift package resolve
```
4. Firebase yapılandırma dosyasını (GoogleService-Info.plist) projeye ekleyin
5. API anahtarlarını .env dosyasına ekleyin
6. Projeyi derleyin ve çalıştırın



## Gelişim Durumu

### Tamamlanan
- ✅ Proje temel yapısı oluşturuldu
- ✅ Splash Screen tamamlandı
- ✅ Tab Bar navigasyonu tamamlandı

### Devam Eden
- 🔄 Kullanıcı kimlik doğrulama (Authentication) ekranları
- 🔄 API servis katmanları
- 🔄 Ana sayfa tasarımı

### Yapılacaklar
- 📝 Podcast oluşturma akışı
- 📝 Kitaplık yönetimi
- 📝 Topluluk sayfası
- 📝 Ayarlar sayfası
- 📝 Firebase entegrasyonu
- 📝 TestFlight beta testleri

## Gereksinimler

- iOS 17.0 veya daha yüksek
- Xcode 14.0 veya daha yüksek
- SPM

## Katkıda Bulunma

1. Bu repo'yu fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inize push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun


## İletişim

Proje Yöneticisi - [@erenalikoca](https://twitter.com/erenalikoca) - info@erenalikoca.com.tr

Proje Linki: [https://github.com/erennali/ai-podcaster](https://github.com/erennali/ai-podcaster)
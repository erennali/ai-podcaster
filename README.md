# AI Podcaster

[Türkçe Versiyon](#turkce-versiyon)

AI-Powered Podcast Creation and Sharing iOS Application

## About the Project
AI Podcaster is an iOS-based mobile application that allows users to easily create, edit, and share podcast content using artificial intelligence technology. Users can generate text based on their chosen topic, duration, and style preferences, and convert these texts into natural human voices.

## Features
- ✅ Splash Screen: Animated introduction screen
- ✅ Tab Bar Navigation: Transition between main screens
- 🔄 User Login and Registration: Login with Email/Password and Apple ID
- 🔄 AI-Powered Podcast Creation: Generate original content with topic, duration, and style choices
- 🔄 Podcast Library: Management of created content
- 🔄 Community: Access to content shared by other users
- 🔄 Settings: Application and profile management

## Technology Stack
- **Language**: Swift 5.9+
- **UI Framework**: UIKit, SnapKit
- **Architecture**: MVVM + Coordinator Pattern
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **APIs**:
  - OpenAI GPT-4 / Google Gemini Pro (Content Creation)
  - ElevenLabs / Google Cloud Text-to-Speech (Voice Conversion)
- **Network Requests**: Alamofire
- **Images**: Kingfisher
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Notifications**: Firebase Cloud Messaging (FCM), OneSignal, Push Notification Service

## Installation
1. Clone this repository:
```bash
git clone https://github.com/erennali/ai-podcaster.git
```
2. Go to the project directory:
```bash
cd ai-podcaster
```
3. Install the required SPMs:
```bash
swift package resolve
```
4. Add Firebase configuration file (GoogleService-Info.plist) to the project
5. Add API keys to the .env file
6. Build and run the project

## Development Status
### Completed
- ✅ Project basic structure created
- ✅ Splash Screen completed
- ✅ Tab Bar navigation completed

### In Progress
- 🔄 User authentication screens
- 🔄 API service layers
- 🔄 Home page design

### To Do
- 📝 Podcast creation flow
- 📝 Library management
- 📝 Community page
- 📝 Settings page
- 📝 Firebase integration
- 📝 TestFlight beta tests

## Requirements
- iOS 17.0 or higher
- Xcode 14.0 or higher
- SPM

## Contributing
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to your branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## Contact
Project Manager - [@erenalikoca](https://twitter.com/erenalikoca) - info@erenalikoca.com.tr
Project Link: [https://github.com/erennali/ai-podcaster](https://github.com/erennali/ai-podcaster)

---

<a id="turkce-versiyon"></a>
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
- **UI Framework**: UIKit, SnapKit
- **Mimari**: MVVM + Coordinator Pattern
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **API'ler**:
  - OpenAI GPT-4 / Google Gemini Pro (İçerik Oluşturma)
  - ElevenLabs / Google Cloud Text-to-Speech (Ses Dönüşümü)
- **Ağ İstekleri**: Alamofire
- **Görüntü**: Kingfisher
- **Analitik**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Bildirimler**: Firebase Cloud Messaging (FCM), OneSignal, Push Notification Service

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

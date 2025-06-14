# QUAL_CEP? 🏡📦

Aplicativo Flutter para consulta de CEPs com visualização de localização no mapa.

## 📱 Funcionalidades

- Busca CEP via API (ViaCEP)
- Exibe dados como logradouro, bairro, cidade, estado
- Mostra a localização no mapa usando `flutter_map` (OpenStreetMap)
- Geração de APK para instalação no Android

---

## 📦 APK (Android)

Você pode baixar e instalar o APK diretamente no seu Android:

👉 [`app-release.apk`](build/app/outputs/flutter-apk/app-release.apk)

### Como instalar no Android:

1. Baixe o arquivo `app-release.apk` do repositório (link acima).
2. Transfira para o seu celular (via USB, e-mail, Google Drive, etc).
3. No celular:
   - Vá em **Configurações > Segurança**.
   - Ative a opção **"Permitir instalação de apps de fontes desconhecidas"** (se ainda não estiver ativa).
4. Abra o APK com um gerenciador de arquivos e toque em **Instalar**.
5. Pronto! O app estará disponível na sua lista de aplicativos. 🎉

> ⚠️ Atenção: esse processo é necessário porque o aplicativo ainda **não está na Play Store**.

---

## 🚀 Rodando via Flutter

```bash
git clone https://github.com/seu-usuario/qual_cep.git
cd qual_cep
flutter pub get
flutter run
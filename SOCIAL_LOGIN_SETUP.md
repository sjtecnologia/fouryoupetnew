# Configuração de Login Social - 4YouPet

Este documento descreve como configurar os logins sociais (Google, Apple, Facebook, X/Twitter) e autenticação biométrica no aplicativo 4YouPet.

## 📱 Funcionalidades Implementadas

- ✅ Login com Google
- ✅ Login com Apple (iOS)
- ✅ Login com Facebook
- ✅ Login com Twitter/X
- ✅ Autenticação Biométrica (Face ID / Touch ID / Fingerprint)

## 🔧 Configuração por Plataforma

### 1. Google Sign-In

#### Android
1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Authentication** > **Sign-in method**
4. Ative o provedor **Google**
5. Adicione o SHA-1 e SHA-256 do seu certificado de debug/release:
   ```bash
   # Debug
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release
   keytool -list -v -keystore /caminho/para/seu/keystore.jks -alias seu_alias
   ```
6. Baixe o arquivo `google-services.json` atualizado e coloque em `android/app/`

#### iOS
1. No Firebase Console, adicione o **iOS URL Scheme** do seu app
2. Baixe o arquivo `GoogleService-Info.plist` atualizado
3. Adicione ao projeto iOS via Xcode
4. Adicione ao `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <!-- Copie o REVERSED_CLIENT_ID do GoogleService-Info.plist -->
         <string>com.googleusercontent.apps.SEU-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

### 2. Apple Sign-In

#### iOS (Obrigatório)
1. No [Apple Developer Portal](https://developer.apple.com/):
   - Vá em **Certificates, IDs & Profiles**
   - Selecione seu App ID
   - Ative **Sign in with Apple**
   - Salve as alterações

2. No Xcode:
   - Abra `ios/Runner.xcworkspace`
   - Selecione o target **Runner**
   - Vá em **Signing & Capabilities**
   - Clique em **+ Capability**
   - Adicione **Sign in with Apple**

3. No Firebase Console:
   - Ative o provedor **Apple**
   - Configure os Services IDs se necessário

#### Android (Opcional)
- Apple Sign-In funciona no Android através de web view
- Certifique-se de que o provedor Apple está ativo no Firebase

### 3. Facebook Login

#### Configuração Geral
1. Acesse o [Facebook Developers](https://developers.facebook.com/)
2. Crie um app ou use um existente
3. Adicione o produto **Facebook Login**
4. Anote o **App ID** e **App Secret**

#### Android
1. Adicione ao `android/app/src/main/res/values/strings.xml`:
   ```xml
   <string name="facebook_app_id">SEU_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbSEU_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">SEU_CLIENT_TOKEN</string>
   ```

2. No `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.facebook.sdk.ApplicationId"
       android:value="@string/facebook_app_id"/>
   
   <meta-data
       android:name="com.facebook.sdk.ClientToken"
       android:value="@string/facebook_client_token"/>
   
   <activity
       android:name="com.facebook.FacebookActivity"
       android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
       android:label="@string/app_name" />
   ```

3. No Facebook Dashboard:
   - Adicione o **Package Name** do seu app
   - Adicione o **Key Hash**:
     ```bash
     keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
     ```

#### iOS
1. No `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>fbSEU_FACEBOOK_APP_ID</string>
       </array>
     </dict>
   </array>
   
   <key>FacebookAppID</key>
   <string>SEU_FACEBOOK_APP_ID</string>
   
   <key>FacebookClientToken</key>
   <string>SEU_CLIENT_TOKEN</string>
   
   <key>FacebookDisplayName</key>
   <string>4YouPet</string>
   
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>fbapi</string>
     <string>fb-messenger-share-api</string>
   </array>
   ```

2. No Firebase Console:
   - Ative o provedor **Facebook**
   - Insira o **App ID** e **App Secret**

### 4. Twitter/X Login

#### Configuração
1. Acesse o [Twitter Developer Portal](https://developer.twitter.com/)
2. Crie um app ou use um existente
3. Ative **OAuth 1.0a** nas configurações do app
4. Anote:
   - **API Key**
   - **API Secret Key**
   - **Callback URL** (ex: `fouryoupet://`)

#### No Código
Atualize o arquivo onde chama o login do Twitter com suas credenciais:
```dart
userManager.signInWithTwitter(
  apiKey: 'SUA_API_KEY',
  apiSecretKey: 'SUA_API_SECRET_KEY',
  redirectURI: 'fouryoupet://',
  onSuccess: () { /* ... */ },
  onFail: (e) { /* ... */ },
);
```

#### Android
Adicione ao `AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="fouryoupet" />
</intent-filter>
```

#### iOS
Adicione ao `Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fouryoupet</string>
    </array>
  </dict>
</array>
```

### 5. Autenticação Biométrica

#### Android
Adicione ao `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

#### iOS
Adicione ao `Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Por favor, autentique-se usando Face ID para acessar o app</string>
```

## 🚀 Como Usar

### No Login Screen
Os botões de login social já foram adicionados automaticamente:
- Botão Google
- Botão Apple (apenas iOS)
- Botão Facebook
- Botão Biometria (se disponível)

### No Signup Screen
Os mesmos botões estão disponíveis para cadastro rápido.

### Testando
1. Faça build do app
2. Teste cada método de login
3. Verifique se o usuário é criado corretamente no Firestore
4. Teste o login biométrico em dispositivo físico (não funciona em emulador)

## 📝 Notas Importantes

### Twitter/X
- Você precisa adicionar suas credenciais do Twitter no código
- O login do Twitter requer aprovação do Twitter Developer Portal
- Certifique-se de configurar o Callback URL corretamente

### Biometria
- **Não funciona em emuladores**
- Requer dispositivo físico
- iOS: Requer Face ID ou Touch ID configurado
- Android: Requer impressão digital ou reconhecimento facial configurado

### Firebase
- Todos os provedores devem estar ativos no Firebase Console
- Certifique-se de que os arquivos de configuração estão atualizados:
  - `google-services.json` (Android)
  - `GoogleService-Info.plist` (iOS)

## 🔐 Segurança

- As credenciais sociais são gerenciadas pelo Firebase Authentication
- Tokens são armazenados de forma segura
- A biometria adiciona uma camada extra de segurança
- Nunca commite arquivos de configuração com credenciais reais

## 📚 Documentação Adicional

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Facebook Login Flutter](https://pub.dev/packages/flutter_facebook_auth)
- [Twitter Login Flutter](https://pub.dev/packages/twitter_login)
- [Local Auth Flutter](https://pub.dev/packages/local_auth)

## ❓ Troubleshooting

### Google Sign-In não funciona
- Verifique se o SHA-1/SHA-256 está configurado no Firebase
- Certifique-se de que o `google-services.json` está atualizado

### Apple Sign-In não aparece
- Verifique se está rodando em dispositivo iOS ou simulador iOS
- Certifique-se de que Sign in with Apple está ativo no Apple Developer

### Facebook retorna erro
- Verifique se o App ID e Client Token estão corretos
- Certifique-se de que o app está em modo de desenvolvimento (permite testers)

### Biometria não funciona
- Use dispositivo físico (não funciona em emulador/simulador)
- Verifique se o dispositivo tem biometria configurada
- Verifique as permissões no AndroidManifest.xml e Info.plist

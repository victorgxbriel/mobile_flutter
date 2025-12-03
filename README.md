# mobile_flutter
[Video Desktop](https://vimeo.com/1143188692?share=copy&fl=sv&fe=ci)
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


---

# 🚗 **Lava-Jato Marketplace App**

### *Aplicativo Flutter para gestão de lava-jatos e agendamentos de serviços*

---

## 📌 **Visão Geral**

Este projeto consiste em um aplicativo **Flutter** que atua como um *marketplace de lava-jatos*.
Usuários podem:

* 📍 **Buscar lava-jatos próximos**
* 🧽 **Visualizar serviços oferecidos**
* 🗓️ **Realizar agendamentos**
* 🚘 **Cadastrar veículos**
* ✔️ **Acompanhar atendimentos**

Lava-jatos podem:

* 🏪 **Cadastrar estabelecimento**
* 🧾 **Criar serviços**
* 📆 **Abrir agenda diária**
* 🕒 **Gerenciar slots de horários**
* 🔧 **Gerenciar atendimentos**

A aplicação consome uma **REST API em NestJS**, já existente.

---

## 🧱 **Arquitetura**

O app utiliza uma arquitetura baseada em:

* **Clean Architecture**
* **DDD (Domain-Driven Design)** aplicado ao que faz sentido no mobile
* **State Management: Riverpod 3**
* **Navigation: GoRouter**
* **Dependency Injection: Riverpod**
* **Rest API: Dio + Interceptors**
* **Storage: Shared Preferences / Secure Storage**
* **Theming: Material 3 + Custom Tokens**
* **Responsiveness: Flutter ScreenUtils**

---

## 📂 **Estrutura de Pastas**

```
lib/
 ├── app/
 │    ├── router/
 │    │     └── app_router.dart
 │    ├── theme/
 │    │     ├── colors.dart
 │    │     ├── typography.dart
 │    │     └── app_theme.dart
 │    └── di/
 │          └── providers.dart
 │
 ├── core/
 │    ├── errors/
 │    ├── exceptions/
 │    ├── network/
 │    │     ├── dio_client.dart
 │    │     └── interceptors/
 │    ├── utils/
 │    ├── constants/
 │    └── shared/
 │
 ├── features/
 │    ├── auth/
 │    │     ├── data/
 │    │     ├── domain/
 │    │     └── presentation/
 │    ├── customer/
 │    ├── establishment/
 │    ├── scheduling/
 │    ├── services/
 │    ├── vehicles/
 │    ├── home/
 │    └── profile/
 │
 ├── widgets/
 └── main.dart
```

---

## 🚀 **Principais Funcionalidades**

### 👤 **Autenticação**

* Login
* Cadastro: cliente ou estabelecimento
* Renovação automática de token
* Proteção de rotas

### 🧼 **Para Clientes**

* Explorar lava-jatos próximos
* Filtrar por serviços
* Ver informações completas do estabelecimento
* Agendar serviço
* Listar agendamentos
* Ver status do atendimento

### 🏪 **Para Estabelecimentos**

* Gerenciar agenda diária
* Abrir slots de horários
* Registrar atendimentos
* Marcar avarias
* Gerenciar serviços oferecidos

---

## 🛠️ **Tecnologias Utilizadas**

### **Frontend**

* Flutter 3.x
* Material Design 3
* Dart 3.x

### **Gerenciamento de Estado**

* Riverpod 3

### **Navegação**

* GoRouter

### **Comunicação com API**

* Dio
* Interceptors para:

  * Autenticação (JWT)
  * Logging
  * Retry automático

### **Persistência**

* Flutter Secure Storage (tokens)
* Shared Preferences (preferências)

### **Mapas / Localização**

* Google Maps Flutter
* geolocator

### **Outros**

* Freezed para modelos
* JsonSerializable
* flutter_screenutil para responsividade
* intl para datas e moedas

---

## 📦 **Instalação**

### 1. Clone o repositório:

```sh
git clone https://github.com/seu-user/lava-jato-marketplace.git
cd lava-jato-marketplace
```

### 2. Instale as dependências:

```sh
flutter pub get
```

### 3. Configure variáveis de ambiente:

Crie o arquivo:

```
lib/env/env.dart
```

Com conteúdo:

```dart
class Env {
  static const apiBaseUrl = "https://sua-api.com/api";
  static const googleMapsApiKey = "SUA_KEY";
}
```

### 4. Execute o projeto:

```sh
flutter run
```

---

## 🧪 **Testes**

Rodar testes unitários:

```sh
flutter test
```

Rodar testes de integração/end-to-end:

```sh
flutter test integration_test
```

---

## 📍 **Roadmap**

O roadmap completo está disponível no arquivo:

➡ **`ROADMAP.md`**

---

## ✨ **Design & UX**

* Minimalista
* Material Design 3
* Componentes customizados
* Feedback visual consistente
* Animações leves e responsivas

---

## 🤝 **Contribuição**

Pull Requests são bem-vindos!

1. Fork o repositório
2. Crie sua branch:
   `git checkout -b feature/minha-feature`
3. Commit:
   `git commit -m "feat: minha feature"`
4. Push:
   `git push origin feature/minha-feature`
5. Abra o PR

---

## 📄 **Licença**

MIT — use como quiser.

---

## 📞 Contato

Caso precise de apoio técnico aprofundado, abra uma issue ou entre em contato.

---

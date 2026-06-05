# 🐾 Projeto FrentisCão

Aplicativo mobile voltado para facilitar a conexão entre ONGs de proteção animal, protetores independentes e doadores, promovendo adoções, campanhas e doações de forma simples e acessível.

---

## 🎯 Objetivo

Criar um ecossistema digital para a causa animal, centralizando:

- Divulgação de animais para adoção 🐶🐱
- Campanhas (vacinação, resgates, eventos) 💉
- Doações diretas e recorrentes 💰
- Conteúdo educativo sobre cuidados com animais 📚

---

## 👥 Perfis de Usuário

O aplicativo contempla três tipos principais de usuários:

1. **Doador**
2. **Protetor Independente**
3. **ONG**

---

## 📱 Funcionalidades Principais

### 🔐 Autenticação e Cadastro

- Login e criação de conta
- Uso opcional sem conta (com limitações)
- Tela de Termos de Uso e Política de Privacidade
- Seleção do tipo de perfil: Doador, Protetor Independente ou ONG
- Cadastro com coleta de dados do usuário
- Verificação em duas etapas (2FA) via e-mail com código

### 🧭 Navegação Principal (Tab Bar)

O app possui 4 abas principais:

#### 🏠 Home
- Feed com postagens de ONGs
- Conteúdo informativo sobre cuidados com animais

#### 🐾 Adoção
- Lista de animais disponíveis
- Exibição em cards com: Imagem, Nome e Informações básicas

#### 📢 Campanhas
- Cards contendo: Localização, Tipo de campanha (ex: vacinação, feira de adoção) e Data

#### 👤 Perfil
- Foto e nome do usuário
- Duas opções de contato
- Funcionalidades organizadas em cards: Favoritos, Doações recorrentes, Campanhas salvas, Últimas doações e Logout

### 🔎 Telas de Detalhes

#### 📄 Post Específico
- Conteúdo completo da publicação
- Opções de: Compartilhar e Doar diretamente para a instituição

#### 🐶 Detalhes do Animal
- Nome do animal
- Informações gerais (idade, porte, etc.)
- Seção "Sobre o animal"
- Galeria de imagens

#### 📍 Detalhes da Campanha
- Informações básicas
- Instruções completas
- Conteúdo adicional com imagens

### 💳 Integração de Pagamentos

O sistema contará com integração para:

- Doações únicas
- Doações recorrentes
- Apoio direto a campanhas e ONGs

> **Sugestões:** Mercado Pago (PIX, Brasil) · Stripe

---

## 🛠 Stack Tecnológica

### 📱 Frontend
- **Flutter** (Dart)
- **Arquitetura:** MVVM (Model-View-ViewModel)
- **Navegação:** go_router
- **Estado:** Provider (ChangeNotifier)
- **Tipografia:** Google Fonts (Inter + Roboto)

### 🗄 Backend / Banco de Dados
- **Supabase** (PostgreSQL)
  - Autenticação (incluindo 2FA)
  - Storage de imagens
  - APIs e funções serverless

---

## 🧱 Arquitetura

Padrão **MVVM**:

| Camada | Responsabilidade |
|---|---|
| **Model** | Representação dos dados (User, Animal, Campaign, etc.) |
| **ViewModel** | Gerenciamento de estado, lógica de apresentação e comunicação com backend |
| **View** | Interface (Widgets Flutter), reativa às mudanças da ViewModel |

> ⚠️ **Regra importante:** A lógica de negócio **NÃO** deve estar na View.

---

## 🎨 Diretrizes de UI

- Fidelidade total ao protótipo de alta qualidade
- Foco em espaçamento consistente, responsividade e experiência do usuário
- Componentes reutilizáveis: Cards (adoção, campanha), Botões, Inputs de formulário

---

## 🧾 Convenções de Código

- **Código:** inglês
- **Interface do usuário:** português (pt-BR)

| Convenção | Uso |
|---|---|
| `PascalCase` | Classes |
| `camelCase` | Variáveis e métodos |
| `snake_case` | Arquivos |

**Exemplos:** `adoption_card.dart` · `campaign_view_model.dart` · `user_model.dart`

---

## 🚀 Como Rodar

```bash
# Instalar dependências
flutter pub get

# Rodar o app
flutter run

# Verificar qualidade do código
flutter analyze
```

---

## 🔄 Fluxo de Desenvolvimento

Para cada nova funcionalidade:

1. Criar/ajustar os **Models**
2. Implementar a **ViewModel** (estados: Loading, Success, Error)
3. Construir a **View** utilizando componentes reutilizáveis
4. Integrar com backend (**Supabase**)

---

## 📌 Status do Projeto

🚧 **Em desenvolvimento**

✅ **Funcionalidades já implementadas:**
- Autenticação e Perfis (Ong, Doador, Protetor)
- Feed de Posts e Listagem de Campanhas e Animais
- Favoritar Posts e Salvar Campanhas (com persistência no Supabase)
- Fluxo simulado de Doações Únicas e Recorrentes
- Criação e Edição de Conteúdos por ONGs

🎯 **Foco atual:** 
- Fase 2 do Sistema de Adoções (Registro de interesses, tela de gerenciamento para o dono, aprovação/rejeição)
- Integração oficial via webhook de Pagamentos (Mercado Pago)


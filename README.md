# 📘 Diário PEI — Gestão Colaborativa de Plano Educacional Individualizado

![Status](https://img.shields.io/badge/status-MVP%20Completo-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-Web%20(PWA)-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%2B%20Auth%20%2B%20RLS-3ECF8E?logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

**Diário PEI** é um Web App (PWA) desenvolvido com foco em escolas, equipes de Atendimento Educacional Especializado (AEE) e operações EdTech B2B para estruturar o **Plano Educacional Individualizado (PEI)** e construir memória pedagógica contínua de forma simples, colaborativa e em conformidade com a LGPD.

---

## 🎯 Visão Geral do Produto

Nas escolas brasileiras, o acompanhamento de estudantes que necessitam de adaptações pedagógicas frequentemente se perde entre anotações isoladas, planilhas despadronizadas e trocas informais de mensagens. Quando muda o bimestre, o ano letivo ou o docente, a escola perde o histórico do que funcionou em sala de aula.

O **Diário PEI** resolve essa dor institucional atuando em três pilares:

- **Inclusão escolar orientada à prática:** transforma o PEI em um instrumento vivo de metas claras e registros cotidianos por disciplina.
- **Memória institucional colaborativa:** conecta coordenação pedagógica, AEE e professores da mesma escola em um único prontuário compartilhado.
- **Privacidade e conformidade (LGPD — Art. 14):** projetado desde a base com isolamento de dados por escola (RLS), aceite auditável de termo no cadastro e foco estritamente pedagógico (evitando exposição de dados clínicos sensíveis).

---

## ✨ Funcionalidades do MVP

### 🔐 Autenticação e Conformidade LGPD

- Acesso individualizado por e-mail e senha via **Supabase Auth**.
- Aceite obrigatório do **Termo de Uso e Diretrizes da LGPD (Art. 14)** no fluxo de criação de conta, com leitura completa em diálogo dedicado e registro auditável (`lgpd_aceito` e timestamp UTC `lgpd_aceito_em`) nos metadados do usuário.

### 🏫 Ambiente Escolar Colaborativo (Multi-Professor)

- Onboarding pós-login para **Criar nova escola** (gerando código curto `PEI-XXXX` e atribuindo papel `Coordenador`) ou **Entrar em uma escola** via código de convite (papel `Professor`).
- Banner institucional na tela de alunos com nome da escola, código de convite com cópia rápida (`Clipboard`), **edição do nome da escola** e **Gestão de Equipe** exclusivos para o `Coordenador` (listagem de membros com papéis e remoção com confirmação).

### 🧑‍🎓 Prontuário Pedagógico Completo

- **Gestão de Alunos:** cadastro rápido com foco pedagógico e busca instantânea por nome, turma ou adaptação.
- **Metas do PEI:** cadastro de objetivos por área pedagógica com prazo opcional e alteração rápida de status (*Pendente*, *Em andamento*, *Atingida*).
- **Diário de Bordo Colaborativo:** linha do tempo cronológica com registro automático de autoria (`autor_email`), seleção de **Disciplina** e barra de filtros instantâneos por disciplina e período agrupado (**Todo o período**, **Últimos 30 dias**, **Trimestres** e **Bimestres**).

### 📄 Relatório / AEE e Exportação Nativa (`.DOC` e `.PDF`)

- Aba dedicada **Relatório / AEE** com editor multilinha e botão **Importar Resumo**, que compila automaticamente metas e registros do diário (incluindo `[Disciplina]`).
- Exportação nativa via navegador — sem bibliotecas pesadas de PDF/Word:
  - **Baixar `.DOC`:** gera documento editável compatível com Microsoft Word e Google Docs (UTF-8 com BOM).
  - **PDF / Imprimir:** impressão limpa em folha A4 via `iframe` oculto (sem bloqueio de pop-up e sem URL/data do navegador no rodapé), com cabeçalho institucional da escola e linha de assinatura centralizada para **Coordenação Pedagógica / AEE**.

---

## 🛠️ Arquitetura e Decisões Técnicas

Projetado para rodar com fluidez inclusive em máquinas com **4 GB de RAM**, o projeto mantém apenas **`supabase_flutter`** como dependência externa no `pubspec.yaml` e dispensa completamente geradores de código (`build_runner`, `freezed`, `json_serializable`).

| Camada | Escolha Técnica | Motivação |
| :--- | :--- | :--- |
| **Frontend** | Flutter Web (PWA) & Dart 3 | Experiência responsiva única para computadores escolares e dispositivos móveis. |
| **Backend & Banco** | Supabase (PostgreSQL + Auth + RLS) | Modelagem relacional segura com isolamento por escola/usuário no banco de dados. |
| **Arquitetura** | Clean Architecture Enxuta | Separação clara entre `domain`, `data` e `presentation` sem boilerplate excessivo. |
| **Estado** | `ChangeNotifier` / `StatefulWidget` | Gerenciamento nativo do Flutter, previsível e de baixíssimo consumo de memória. |
| **Serialização & Export** | `fromMap`/`toMap` manuais + `dart:js_interop` | Builds rápidos, zero codegen e geração nativa de `.doc` / `.pdf` no navegador. |

### 📂 Estrutura do Projeto

```text
lib/
├── app.dart                           # Bootstrap, _AuthGate e roteamento por vínculo escolar
├── main.dart                          # Inicialização do Supabase
├── core/
│   ├── config/
│   │   └── supabase_config.dart       # Leitura de SUPABASE_URL e SUPABASE_ANON_KEY (--dart-define)
│   ├── theme/
│   │   └── app_theme.dart             # Tema Material 3 limpo e acessível
│   └── utils/
│       ├── export_helper.dart         # Ponte multiplataforma (.DOC / .PDF) via dart:js_interop
│       └── pei_summary_formatter.dart # Compilador de resumo estruturado para Clipboard e AEE
└── features/
    └── pei/
        ├── domain/
        │   ├── entities/              # Escola, MembroEscola, Aluno, MetaPei, RegistroDiario
        │   └── repositories/          # Contrato PeiRepository
        ├── data/
        │   ├── datasources/           # PeiSupabaseDatasource
        │   ├── models/                # Mapeamento manual (fromMap / toMap)
        │   └── repositories/          # PeiRepositoryImpl
        └── presentation/
            ├── controllers/           # AuthController, EscolaController, AlunosController, ProntuarioController
            ├── pages/                 # LoginPage, EscolaSetupPage, AlunosPage, ProntuarioPage
            └── widgets/               # Formulários, cards de metas e tiles do diário
```

---

## 🚀 Como Rodar Localmente

### Pré-requisitos

- Flutter SDK (3.x+) com suporte a Web habilitado
- Projeto configurado no [Supabase](https://supabase.com/) com o schema aplicado (`supabase/schema.sql` e tabelas multi-escola)

### Passo a passo

```bash
# 1. Clonar o repositório
git clone https://github.com/danhistoria-pm-po/diario-pei.git
cd diario-pei

# 2. Instalar dependências
flutter pub get

# 3. Executar no Chrome injetando as variáveis do Supabase
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=SUA_SUPABASE_ANON_KEY
```

*(Dica para máquinas com 4 GB de RAM: use `-d web-server --web-port=8080` no lugar de `-d chrome` para reduzir o uso de memória.)*

### Validação e Testes

```bash
flutter analyze
flutter test
```

---

## 🗺️ Roadmap (Próximos Passos)

- [x] Arquitetura enxuta, schema relacional com RLS e autenticação com Termo LGPD auditável.
- [x] Ambiente escolar colaborativo (código de convite, papéis, edição da escola e gestão de equipe).
- [x] Prontuário completo com Metas do PEI, Diário de Bordo com disciplina/autoria e filtros por Trimestre e Bimestre.
- [x] Aba Relatório / AEE com exportação nativa em `.DOC` e `.PDF` A4.
- [ ] **Deploy PWA em produção** (CI/CD na nuvem com domínio próprio e instalação offline-first).
- [ ] **Módulos de adaptação por disciplina** (banco de estratégias pedagógicas reutilizáveis por componente curricular).
- [ ] **Camada comercial B2B** (painel multi-unidades para redes de ensino, planos por escola e indicadores de acompanhamento).

---

## 📄 Licença

Distribuído sob a licença **MIT**. Consulte o arquivo [LICENSE](LICENSE) para mais informações.

---

## 👤 Autor

Desenvolvido por **Danny Bustamante** — Educador e entusiasta de Produtos Digitais & EdTech.

- **Portfólio / Web:** [prismadigital.net.br](https://www.prismadigital.net.br)
- **GitHub:** [@danhistoria-pm-po](https://github.com/danhistoria-pm-po)

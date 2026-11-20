# 📘 Diário PEI — Acompanhamento Educacional Individualizado

![Status](https://img.shields.io/badge/status-MVP%20Funcional-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-Web%20(PWA)-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

Aplicação Web (PWA) leve e funcional desenvolvida para professores, coordenadores pedagógicos e equipes de EdTechs gerenciarem o **Plano Educacional Individualizado (PEI)** e a tutoria de alunos em um só lugar.

---

## 🎯 Problema que Resolve
O acompanhamento individualizado e as adaptações pedagógicas costumam ficar dispersos em cadernos, planilhas ou mensagens soltas, dificultando a continuidade do trabalho entre professores e bimestres. O **Diário PEI** centraliza o perfil de adaptação do aluno, suas metas pedagógicas e um diário de bordo cronológico, permitindo gerar resumos estruturados em segundos para reuniões, atas e relatórios.

---

## ✨ Funcionalidades do MVP
- **Autenticação Segura:** Acesso individualizado por e-mail e senha via Supabase Auth.
- **Gestão de Alunos:** Cadastro rápido com turma e resumo do perfil de adaptação (ex.: *tempo extra, enunciados curtos, apoio de leitura*) + busca instantânea.
- **Metas do PEI:** Checklist interativo de objetivos pedagógicos com controle de status (*Em andamento* / *Concluída*).
- **Diário de Bordo:** Registro rápido por disciplina e data para documentar intervenções e estratégias que funcionaram em sala.
- **Exportação Leve (Clipboard):** Botão **Copiar Resumo** que compila dados do aluno, metas e histórico recente direto para a área de transferência, pronto para colar em relatórios oficiais ou e-mails (sem dependência de bibliotecas pesadas de PDF).
- **Aba Relatório / AEE (Editor de Parecer):** Permite importar o resumo automático, editar livremente o parecer pedagógico e salvá-lo na nuvem (Supabase).
- **Exportação em .DOC e .PDF:** Geração nativa via navegador de documento editável (`.doc` compatível com Word/Google Docs) e impressão formatada em folha A4 (`.pdf`), sem pacotes externos pesados.

---

## 🛠️ Stack Tecnológica e Decisões Arquiteturais

| Camada | Tecnologia | Justificativa |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Web / PWA) & Dart | Base única responsiva acessível via navegador em celulares e computadores escolares. |
| **Backend & Banco** | Supabase (PostgreSQL + Auth) | Banco relacional robusto com autenticação pronta e segurança a nível de linha (RLS). |
| **Estado** | `ChangeNotifier` / `ValueNotifier` | Gerenciamento nativo do Flutter, eliminando pacotes externos e reduzindo o consumo de RAM. |
| **Serialização** | Manual (`fromMap` / `toMap`) | Evita o uso de `build_runner` e geração de código, garantindo builds leves em máquinas com 4 GB de RAM. |

### 📂 Estrutura de Pastas (Clean Architecture Enxuta)
```text
lib/
├── core/
│   ├── config/          # Inicialização do Supabase (via --dart-define)
│   ├── theme/           # Tema Material 3 limpo e acessível
│   └── utils/           # Formatador de resumo (Clipboard) e export_helper.dart (.DOC / .PDF)
└── features/
    └── pei/
        ├── domain/
        │   ├── entities/       # Aluno, MetaPei, RegistroDiario
        │   └── repositories/   # Interfaces (contratos abstratos)
        ├── data/
        │   ├── datasources/    # Comunicação direta com Supabase
        │   ├── models/         # Mapeamento manual (fromMap / toMap)
        │   └── repositories/   # Implementação dos contratos
        └── presentation/
            ├── controllers/    # Gerenciamento de estado nativo
            ├── pages/          # LoginPage, AlunosPage, ProntuarioPage
            └── widgets/        # Cards, modais e formulários reutilizáveis
```

---

## 🔒 Segurança e Privacidade (LGPD)
Por lidar com o contexto educacional de menores de idade, o projeto adota princípios de **Privacy by Design**:
- **Isolamento de Dados (RLS):** Todas as tabelas no Supabase possuem *Row Level Security* ativado, garantindo que cada usuário autenticado acesse apenas seus próprios registros.
- **Proteção de Credenciais:** As chaves da API (`SUPABASE_URL` e `SUPABASE_ANON_KEY`) nunca são versionadas no código-fonte, sendo injetadas exclusivamente em tempo de execução via `--dart-define`.
- **Boas Práticas de Registro:** Recomenda-se registrar apenas o **primeiro nome + inicial** (ou código de matrícula) do estudante e focar o campo de adaptação em **estratégias pedagógicas**, evitando o armazenamento de diagnósticos clínicos ou códigos CID.

---

## 🗄️ Configuração do Banco de Dados (Supabase)
1. Crie um projeto gratuito no [Supabase](https://supabase.com/).
2. No menu lateral, acesse **SQL Editor** e execute o script completo localizado em `supabase/schema.sql`.
3. Em **Project Settings > API Keys**, copie a **Project URL** e a **Publishable Key** (ou `anon` key).

---

## 🚀 Como Rodar Localmente (Otimizado para 4 GB de RAM)

### Pré-requisitos
- Flutter SDK instalado (com suporte a Web habilitado)
- Conta gratuita no Supabase

### Execução
```bash
# 1. Clonar o repositório
git clone https://github.com/danhistoria-pm-po/diario-pei.git
cd diario-pei

# 2. Instalar a única dependência do projeto
flutter pub get

# 3. Rodar no Chrome passando as chaves do Supabase
flutter run -d chrome \
  --dart-define=SUPABASE_URL=SUA_URL_AQUI \
  --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_AQUI
```
*(Dica para máquinas com 4 GB de RAM: para economizar ainda mais memória, troque `-d chrome` por `-d web-server --web-port=8080` e abra `http://localhost:8080` em uma aba do seu navegador.)*

### Validação de Código
Antes de cada commit, valide a integridade do código sem sobrecarregar a máquina:
```bash
flutter analyze
```

---

## ☁️ Deploy (Build na Nuvem)
Para evitar builds pesados localmente, recomenda-se o deploy contínuo via **Vercel** ou **GitHub Pages (GitHub Actions)**, configurando `SUPABASE_URL` e `SUPABASE_ANON_KEY` como variáveis de ambiente diretamente no painel da plataforma escolhida.

---

## 🗺️ Roadmap
- [x] Definição de arquitetura enxuta e modelagem relacional (SQL + RLS).
- [x] MVP funcional (Login, Gestão de Alunos, Metas PEI, Diário de Bordo e Copiar Resumo).
- [x] Exportação de relatórios pedagógicos / AEE em `.DOC` e `.PDF` (A4 nativo).
- [ ] Compartilhamento multi-professor (acesso colaborativo por escola/turma).
- [ ] Filtros por disciplina e período no Diário de Bordo.
- [ ] Deploy contínuo em produção (PWA).

---

## 🤝 Boas Práticas e Contribuição
Este projeto segue princípios de **Clean Architecture**, **Clean Code** e **Conventional Commits** (`feat:`, `fix:`, `docs:`, `refactor:`).

1. Crie uma branch para sua alteração (`git checkout -b feat/nova-funcionalidade`).
2. Mantenha o projeto livre de geradores de código (`build_runner`) e dependências desnecessárias.
3. Garanta que `flutter analyze` retorne zero erros.
4. Envie um Pull Request descrevendo claramente o problema resolvido.

---

## 📄 Licença
Este projeto está licenciado sob a licença **MIT** — consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor
Desenvolvido por **Danny Bustamante** — Educador e entusiasta de Produtos Digitais & EdTech.
- **Portfólio / Web:** [prismadigital.net.br](https://www.prismadigital.net.br)
- **GitHub:** [@danhistoria-pm-po](https://github.com/danhistoria-pm-po)

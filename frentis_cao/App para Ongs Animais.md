# App para Ongs Animais

## Visao Geral

O projeto FrentisCao e um aplicativo mobile voltado para conectar ONGs de protecao animal, protetores independentes e doadores. A proposta e centralizar publicacoes, campanhas, animais para adocao e fluxos de apoio em uma experiencia simples para usuarios finais e util para organizacoes.

O app foi desenvolvido em Flutter e usa Supabase como backend principal, incluindo autenticacao, banco PostgreSQL, storage de imagens e funcoes RPC para regras de negocio executadas no banco.

## Tecnologias Usadas

### Frontend Mobile

- Flutter com Dart.
- Material Design.
- Provider e ChangeNotifier para gerenciamento de estado.
- go_router para navegacao declarativa.
- Google Fonts para tipografia.
- image_picker para selecao de imagens em posts, campanhas e animais.
- share_plus para compartilhamento de posts e campanhas.
- flutter_dotenv para carregar variaveis de ambiente, como URL e chave publica do Supabase.
- flutter_localizations para suporte pt-BR.

### Backend e Dados

- Supabase Auth para login, cadastro, OAuth com Google e verificacao por OTP.
- Supabase PostgreSQL para persistencia de perfis, posts, animais, campanhas e adocoes.
- Supabase Storage para imagens de posts, campanhas e animais.
- Supabase RPC/PostgreSQL functions para operacoes sensiveis, como alternar like em posts.
- Row Level Security, considerada no fluxo de autenticacao e escrita.

### Qualidade e Ferramentas

- flutter_lints para padronizacao.
- `dart analyze` para verificacao estatica.
- Estrutura organizada por models, services, viewmodels, views e widgets.

## Arquitetura

O projeto segue uma organizacao inspirada em MVVM:

- Models: representam os dados de dominio, como `PostModel`, `AnimalModel`, `CampaignModel`, `AdoptionModel` e `UserModel`.
- Views: telas e widgets Flutter, responsaveis pela interface e interacao visual.
- ViewModels: controlam estado, carregamento, acoes de usuario e comunicacao com services.
- Services: encapsulam chamadas ao Supabase Auth, banco, storage e RPCs.
- Core: concentra configuracoes globais como tema e rotas.

Principais arquivos:

- `lib/main.dart`: inicializacao do Flutter, dotenv, Supabase e providers globais.
- `lib/core/app_router.dart`: definicao das rotas com go_router.
- `lib/core/app_theme.dart`: tokens visuais, cores e tema.
- `lib/services/supabase_auth_service.dart`: autenticacao, cadastro, OAuth e perfil.
- `lib/services/supabase_data_service.dart`: posts, animais, campanhas, adocoes, uploads e RPCs.
- `lib/viewmodels/auth_view_model.dart`: estado e regras de tela para autenticacao/onboarding.
- `lib/viewmodels/data_view_model.dart`: estado do feed, animais, campanhas, favoritos, likes e permissoes.

## Features Implementadas

### Autenticacao e Onboarding

- Login com email e senha.
- Login com Google via Supabase OAuth.
- Cadastro de usuario.
- Fluxo de onboarding com selecao de tipo de usuario.
- Aceite de termos.
- Coleta de dados do usuario.
- Verificacao por codigo via Supabase OTP.
- Criacao/complemento de perfil na tabela `profiles`.

### Perfis de Usuario

O app trabalha com tres perfis principais:

- Doador.
- Protetor independente.
- ONG.

As permissoes usam o tipo salvo em `profiles.user_type`. Usuarios comuns nao podem criar posts, e o botao de adicionar post na Home fica oculto para esses perfis.

### Home e Feed

- Feed de posts ativos.
- Cards com dados da ONG, imagens, titulo, descricao, like, salvar e compartilhar.
- Busca por texto em posts, ONGs e campanhas.
- Sugestoes de ONGs durante a busca.
- Filtros por categorias, como ONGs, pets, caes, gatos e recentes.
- Pull-to-refresh do feed.
- Criacao, edicao e exclusao logica de posts por usuarios autorizados.
- Galeria de imagens para posts.

### Likes em Posts

- Cada post possui `likes_id`, com os UUIDs dos usuarios que curtiram.
- Cada post tambem possui `like_count`, usado como fonte do total exibido na interface.
- O clique no like chama a RPC `public.like_post`.
- A function no banco alterna o like:
  - se o usuario ainda nao curtiu, adiciona o UUID em `likes_id`;
  - se ja curtiu, remove o UUID de `likes_id`;
  - recalcula e atualiza `like_count`;
  - retorna `likes_id` e `like_count` para atualizar a UI.

### Animais para Adocao

- Listagem de animais disponiveis.
- Cards com imagem e dados principais.
- Tela de detalhe do animal.
- Cadastro de animal com upload de imagens.
- Consulta de adocoes feitas pelo usuario.
- Registro de interesse em adocao.

### Campanhas

- Listagem de campanhas e eventos.
- Cards com titulo, localizacao, data, tipo e imagem.
- Tela de detalhe com instrucoes e galeria.
- Criacao de campanhas por ONGs.
- Controle de permissao para exibir o botao de nova campanha.
- Campo para indicar se a campanha aceita doacao.

### Perfil e Area do Usuario

- Tela de perfil com atalhos.
- Favoritos.
- Minhas adocoes.
- Doacoes e checkout mockados.
- Logout.

### Compartilhamento

- Compartilhamento de posts.
- Compartilhamento de campanhas.
- Textos de compartilhamento montados com dados do conteudo.

### Storage de Imagens

- Upload de imagens para o bucket `frentiscao_images`.
- Organizacao de caminhos por tipo de conteudo e usuario.
- Conversao de paths privados/publicos para URLs publicas quando necessario.

## Casos de Uso Possiveis

### Para Doadores

- Navegar por posts de ONGs.
- Buscar ONGs ou campanhas.
- Curtir e salvar posts.
- Compartilhar publicacoes.
- Visualizar animais disponiveis para adocao.
- Demonstrar interesse em adotar.
- Acompanhar campanhas e eventos.
- Fazer doacoes por fluxos mockados ou futura integracao real de pagamento.

### Para ONGs

- Criar posts institucionais.
- Editar ou remover posts proprios.
- Cadastrar campanhas e eventos.
- Divulgar campanhas com imagens e instrucoes.
- Cadastrar animais para adocao.
- Receber visibilidade por busca e feed.
- Compartilhar campanhas com apoiadores.

### Para Protetores Independentes

- Divulgar animais resgatados.
- Participar da rede de adocao.
- Criar conteudo conforme permissao do perfil.
- Apoiar campanhas e interagir com ONGs.

### Para Administracao/Futuras Evolucoes

- Moderar posts, campanhas e animais.
- Medir engajamento por `like_count`.
- Criar dashboards de campanhas, adocoes e doacoes.
- Integrar pagamentos reais via Mercado Pago, Stripe ou outro provedor.
- Expandir regras de permissao por perfil.

## Implementacoes Realizadas no Projeto

- Estrutura Flutter com separacao entre core, models, services, viewmodels, views e widgets.
- Inicializacao do Supabase com variaveis `.env`.
- Roteamento principal com go_router.
- Providers globais para `AuthViewModel` e `DataViewModel`.
- Servico de autenticacao com login, cadastro, Google OAuth, verificacao de codigo e perfil.
- Servico de dados com leitura e escrita em posts, campanhas, animais e adocoes.
- Upload de imagens para Supabase Storage.
- Feed com busca, filtros, sugestoes de ONGs e skeleton loading.
- Cards reutilizaveis para posts, campanhas e adocao.
- Telas de detalhes para posts, animais e campanhas.
- Criacao e edicao de posts.
- Criacao de campanhas.
- Cadastro de animais.
- Permissao para ocultar o botao de novo post de usuarios comuns.
- Bloqueio de criacao de posts para perfis `donor`, `usuario` e `user`.
- Like de post via RPC no banco, usando `likes_id` e `like_count`.
- Toggle de like/unlike ao clicar novamente.
- Uso de `like_count` como contador exibido no botao de like.
- Migration SQL para criar a function `public.like_post`.

## Estrutura de Banco Relacionada

As principais tabelas utilizadas ou inferidas pelo codigo sao:

- `profiles`: dados do usuario e tipo de perfil.
- `posts`: publicacoes do feed, imagens, status ativo, autor, likes e contador.
- `animals`: animais disponiveis para adocao.
- `adoptions`: registros de interesse/adocao.
- `campaigns`: campanhas e eventos.

Campos importantes em `posts`:

- `id`: identificador do post.
- `org_id`: usuario/ONG autor do post.
- `title`: titulo.
- `description`: descricao curta.
- `full_description`: descricao completa.
- `image_url`: lista ou JSON com imagens.
- `tag`: classificacao do post.
- `ativo`: controle de exclusao logica.
- `likes_id`: array de UUIDs dos usuarios que curtiram.
- `like_count`: total persistido de likes.

## Observacoes de Evolucao

- Aplicar a migration da function `public.like_post` no Supabase para habilitar o toggle de likes.
- Revisar politicas RLS para garantir que usuarios autenticados possam executar a RPC sem abrir updates diretos indesejados.
- Substituir telas mockadas de doacao por integracao real de pagamento.
- Implementar favoritos persistidos no banco.
- Persistir salvamentos e historico de doacoes.
- Criar perfis publicos para ONGs e protetores.
- Adicionar testes automatizados para services, viewmodels e fluxos principais.

# 🚨 Relatório de Investigação: RLS na Tabela `campaigns`

Este relatório analisa os dois problemas relatados em relação à tabela `campaigns` no Supabase: o aviso de segurança no painel e o erro 403 recebido pelo Jonathan ao tentar inserir dados.

---

## 1. O Aviso de Segurança: "RLS Policy Always True"

O Supabase detectou que a política de `INSERT` criada pelo Jonathan está insegura. O erro diz:
> *"Table public.campaigns has an RLS policy... that allows unrestricted access (WITH CHECK clause is always true)"*

### O que isso significa?
No Supabase, uma política de inserção para "usuários autenticados" geralmente é criada apenas marcando a caixinha "Authenticated" na interface. O problema é que o banco de dados entende isso como: **"Qualquer pessoa logada pode inserir qualquer coisa"**.

**O Risco:** O usuário A poderia enviar um JSON malicioso criando uma campanha no nome do usuário B, e o banco aceitaria, pois a política está `WITH CHECK (true)`.

### Como Corrigir (A Política Correta)
A política de `INSERT` não deve ser "verdadeira para sempre". Ela deve garantir que o usuário só possa criar uma campanha no próprio nome dele.

Você deve alterar a política (ou recriá-la via SQL) para que a verificação (WITH CHECK) seja:
```sql
-- Garante que a pessoa inserindo a campanha é a dona do ID vinculado
(auth.uid() = user_id) 

-- (Substitua "user_id" pelo nome da coluna que guarda o ID do criador na tabela campaigns)
```

---

## 2. A Investigação do Erro 403 (Forbidden)

*"Se a política está aberta (Always True), por que o Jonathan tomou um Erro 403 ao tentar inserir?"*

Aqui estão as 3 causas mais prováveis para esse comportamento "fantasma" no Supabase:

### Causa A: O Problema do `.select()` (Mais Provável)
No Flutter, quando fazemos um insert, costumamos encadear o método `.select()` no final para receber o dado recém-criado:
```dart
final response = await supabase.from('campaigns').insert(dados).select();
```
**O Problema:** A inserção funciona perfeitamente, mas no milissegundo seguinte, o Flutter tenta fazer um `SELECT` para ler a campanha criada. Se o Jonathan criou a política de `INSERT`, **mas esqueceu de criar a política de `SELECT`**, o banco de dados bloqueia a leitura e cospe um erro 403!
**Solução:** Criar uma política de `SELECT` para a tabela `campaigns` (Ex: `USING (true)` se as campanhas forem públicas).

### Causa B: O Problema do Storage (Imagens)
Se o formulário de campanha do Jonathan faz upload de uma foto do animal ANTES de salvar a campanha no banco, o erro 403 pode não ser da tabela `campaigns`!
**O Problema:** O Supabase Storage também tem RLS (Row Level Security). Se o bucket (ex: `campaign_images`) não tiver uma política de `INSERT` configurada, o upload da foto falha com Erro 403 e a campanha nem chega a ser salva.
**Solução:** Ir na aba *Storage* -> *Policies* e garantir que usuários autenticados podem inserir arquivos no bucket.

### Causa C: Passagem do Token
Se o token de autenticação não estiver sendo enviado corretamente na requisição (ou se a sessão expirou na máquina do Jonathan), o Supabase não reconhece ele como "Authenticated" e bloqueia o insert na hora, gerando o 403.

---

## ✅ Resumo de Ação para o Jonathan
Para resolver tudo de uma vez, peçam para ele rodar o seguinte script SQL no painel do Supabase (Aba *SQL Editor*), substituindo `owner_id` pelo nome correto da coluna de vocês:

```sql
-- 1. Remove políticas defeituosas antigas
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.campaigns;

-- 2. Cria a política de INSERT segura
CREATE POLICY "Usuários só inserem as próprias campanhas" 
ON public.campaigns FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = owner_id);

-- 3. Cria a política de SELECT (leitura) para evitar o 403 no .select()
CREATE POLICY "Todo mundo pode ver as campanhas" 
ON public.campaigns FOR SELECT 
USING (true);
```

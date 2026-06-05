-- ====================================================================
-- SCRIPT DE ATUALIZAÇÃO DO BANCO DE DADOS (SUPABASE)
-- Execute este script no SQL Editor do Supabase.
-- ====================================================================

-- 1. Favoritos nos Posts
-- Adiciona um array para guardar os IDs e um contador para performance (boa prática!)
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS likes text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS like_count integer DEFAULT 0;

-- 2. Campanhas Salvas (Bookmarks) nas Campanhas
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS saves text[] DEFAULT '{}';

-- 3. Atualização na Tabela de Animais (Adoções)
ALTER TABLE animals 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'disponivel',
ADD COLUMN IF NOT EXISTS adopter_id uuid REFERENCES auth.users(id) ON DELETE SET NULL;

-- 4. Criação da Tabela de Interesses de Adoção
CREATE TABLE IF NOT EXISTS adoption_interests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  animal_id uuid REFERENCES animals(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  status text DEFAULT 'pendente', -- pendente, aprovado, rejeitado
  created_at timestamp with time zone DEFAULT now(),
  -- Impede que o mesmo usuário demonstre interesse duas vezes no mesmo animal
  UNIQUE(animal_id, user_id)
);

-- Políticas RLS básicas para a nova tabela (ajuste conforme as regras da sua ONG)
ALTER TABLE adoption_interests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver interesses dos seus animais"
ON adoption_interests FOR SELECT
USING ( 
  -- Pode ver se for o dono do animal
  EXISTS (SELECT 1 FROM animals WHERE animals.id = adoption_interests.animal_id AND animals.owner_id = auth.uid())
  OR 
  -- Ou se for o próprio usuário interessado
  user_id = auth.uid()
);

CREATE POLICY "Usuários podem criar seus próprios interesses"
ON adoption_interests FOR INSERT
WITH CHECK ( auth.uid() = user_id );

CREATE POLICY "Donos do animal podem atualizar o status do interesse"
ON adoption_interests FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM animals WHERE animals.id = adoption_interests.animal_id AND animals.owner_id = auth.uid())
);

# PERSPLANIA - MVP Fase 1

## Objetivo
Criar um app funcional básico para gerenciamento de tarefas com:
- Login por email/senha
- Criação de tarefas
- Listagem de tarefas
- Marcação de tarefas como concluídas
- Visualização simples (lista)

## Stack definida
- Frontend: FlutterFlow (planejado)
- Backend: Supabase

## Implementação no workspace
Criei um app Flutter local em `flutter_app/` com autenticação, criação de tarefas, listagem e marcação de concluído. Use esse código como ponto de partida ou como referência para reproduzir o mesmo fluxo no FlutterFlow.

## Banco de dados no Supabase
O Supabase já fornece a tabela `users` via Auth com campos básicos como `id` e `email`.

### Tabelas adicionais
#### `tasks`
- `id` (UUID ou serial)
- `user_id` (UUID, referência para `auth.users`)
- `title` (texto)
- `description` (texto)
- `category` (texto; ex: trabalho, escola)
- `completed` (boolean)
- `created_at` (timestamp)

#### `goals` (opcional para MVP)
- `id`
- `user_id`
- `title`
- `progress`

## Passos principais
1. Criar projeto no Supabase.
2. Ativar autenticação por email/senha em Authentication > Settings.
3. Criar tabela `tasks` no SQL Editor.
4. No FlutterFlow, conectar o app ao Supabase.
5. Criar telas:
   - Login
   - Cadastro
   - Dashboard com lista de tarefas
   - Tela de criação de tarefa
6. Implementar lógica:
   - Criar tarefa → inserir em `tasks`
   - Listar tarefas do usuário logado
   - Marcar tarefa como concluída → atualizar `completed`
7. Testar:
   - Login / cadastro
   - Criação de tarefa
   - Listagem de tarefas
   - Atualização de status

## Fase 2 — Organização inteligente
Agora o app inclui melhorias de interface para deixar o uso mais prático:
- categorias pré-definidas na criação da tarefa
- filtros por categoria e status
- pequeno calendário para filtrar tarefas pela data do evento
- edição de tarefas criadas pelo usuário
- status de tarefas atrasadas
- prazo com data e horário

### Melhorias implementadas
- `CreateTaskScreen`: seleção de categoria via `DropdownButtonFormField`
- `CreateTaskScreen`: prazo com data e horário
- `DashboardScreen`: chips de filtro para categorias e status
- `DashboardScreen`: calendário simples com `CalendarDatePicker` vinculado à data do evento
- `DashboardScreen`: exibição de tarefas atrasadas e edição ao tocar na tarefa

## SQL de exemplo para Supabase
Veja o arquivo `supabase-schema.sql`.

## Políticas de acesso (RLS)
Se você ativou Row Level Security no Supabase, é necessário criar políticas para permitir que o usuário autenticado leia, insira e atualize suas próprias tarefas.
Use o arquivo `supabase-policies.sql` no SQL Editor do Supabase.

### Exemplo de uso no dashboard
1. Abra o projeto no Supabase.
2. Acesse `Database` > `SQL editor`.
3. Cole o conteúdo de `supabase-policies.sql`.
4. Clique em `RUN`.

Se estiver usando o app Flutter e receber o erro:
`PostgrestException(message: new row violates row-level security policy for table "tasks"...)`,
então este arquivo resolve o problema.

# Persplania Flutter MVP

Este aplicativo é um MVP de gerenciamento de tarefas com autenticação e banco de dados via Supabase.

## Configuração
1. Crie um projeto no Supabase.
2. Ative autenticação por email/senha em Authentication > Settings.
3. Execute o arquivo `supabase-schema.sql` para criar a tabela `tasks`.
4. Copie a URL e a chave anônima do Supabase.
5. Abra `lib/constants.dart` e substitua `YOUR_SUPABASE_URL` e `YOUR_SUPABASE_ANON_KEY` pelos valores do seu projeto.

## Executar localmente
No terminal, dentro de `flutter_app`:

```bash
flutter pub get
flutter run
```

## Funcionalidades incluídas
- Login por email/senha
- Cadastro de usuário
- Listagem de tarefas do usuário logado
- Criação de tarefas
- Marcação de tarefas como concluída
- Logout

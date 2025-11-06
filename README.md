# 📚 Biblioteca SQL Server

Sistema de gerenciamento de biblioteca desenvolvido em SQL Server, com suporte a CRUD para Livros, Usuários e Empréstimos, além de controle de status de empréstimos.

## 🗂 Estrutura do Banco de Dados

O banco biblioteca contém três tabelas principais:

#### Livro
| Coluna | Tipo | Observação |
| --- | :---: | --- |
|id_livro|INT IDENTITY|Chave primária|
|titulo|NVARCHAR(100)|Obrigatório|
|autor|NVARCHAR(100)|Opcional|
|ano_publicacao|INT|Opcional|
|edicao|INT|Opcional|

#### Usuario
| Coluna | Tipo	| Observação |
| --- | :---: | --- |
|id_usuario	|INT IDENTITY |Chave primária|
|nome	|NVARCHAR(150)|	Obrigatório|
|email|	NVARCHAR(150)|	Obrigatório e único|

#### Emprestimo

|Coluna	|Tipo|	Observação|
| --- | :---: | --- |
|id_emprestimo|	BIGINT IDENTITY| Chave primária|
|id_usuario	|INT	|FK → Usuario|
|id_livro	|INT	|FK → Livro|
|data_emprestimo|	DATE|	Data do empréstimo|
|data_prevista|	DATE	|Data prevista para devolução|
|data_devolucao|	DATE|	NULL se não devolvido|
|status_emprestimo	|VARCHAR(20)|EM_ANDAMENTO, DEVOLVIDO, EM_ATRASO|

## ⚙️ Procedimentos Armazenados
Livros

- `livro_insert (@titulo_livro, @autor, @ano_publicacao, @edicao)` – Inserir livro

- `livro_select (@id_livro)` – Listar todos ou por ID

- `livro_update (@id_livro, ...)` – Atualizar informações

- `livro_delete (@id_livro)` – Excluir livro (não permitido se houver empréstimos ativos)

Usuários

- `usuario_insert (@nome, @email)` – Inserir usuário

- `usuario_select (@id_usuario)` – Listar todos ou por ID

- `usuario_update (@id_usuario, ...)` – Atualizar informações

- `usuario_delete (@id_usuario)` – Excluir usuário (não permitido se houver empréstimos ativos)

Empréstimos

- `emprestimo_insert (@id_usuario, @id_livro, @data_prevista)` – Criar empréstimo (verifica disponibilidade)

- `emprestimo_select (@id_emprestimo)` – Listar todos ou por ID

- `emprestimo_update (@id_emprestimo, @data_prevista, @data_devolucao)` – Atualizar datas e status

- `emprestimo_delete (@id_emprestimo)` – Cancelar empréstimo (apenas em andamento)

- `atualizar_emprestimos_atrasados ()` – Atualiza status para EM_ATRASO

## 📌 Regras de Negócio

    - Um livro não pode ser emprestado se já estiver com empréstimo ativo.

    - data_prevista ≥ data_emprestimo.

    - data_devolucao ≥ data_emprestimo.

    - Usuários e livros não podem ser excluídos se houver empréstimos ativos.

    - Empréstimos atrasados são atualizados para EM_ATRASO.

## 🚀 Como Usar
Criar um livro
```
EXEC dbo.livro_insert 
    @titulo_livro = 'Dom Casmurro', 
    @autor = 'Machado de Assis', 
    @ano_publicacao = 1899, 
    @edicao = 1;
```
Criar um usuário
```
EXEC dbo.usuario_insert 
    @nome = 'João Silva', 
    @email = 'joao.silva@email.com';
```
Registrar um empréstimo
```
EXEC dbo.emprestimo_insert
    @id_usuario = 1,
    @id_livro = 1,
    @data_prevista = '2025-11-20';
```
Atualizar devolução
```
EXEC dbo.emprestimo_update
    @id_emprestimo = 1,
    @data_devolucao = GETDATE();
```
Listar empréstimos
```
EXEC dbo.emprestimo_select;
```
Atualizar status de atrasos
```
EXEC dbo.atualizar_emprestimos_atrasados;
```

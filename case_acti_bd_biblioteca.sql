
-- Criação de Tabelas

CREATE TABLE Livro(
	id_livro INT IDENTITY(1,1) PRIMARY KEY,
	titulo NVARCHAR(100) NOT NULL,
	autor NVARCHAR(100) NULL,
	ano_publicacao INT NULL,
	edicao INT NULL
);

CREATE TABLE Usuario(
	id_usuario INT IDENTITY(1,1) PRIMARY KEY,
	nome NVARCHAR(150) NOT NULL,
	email NVARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE Emprestimo(
	id_emprestimo BIGINT IDENTITY(1,1) PRIMARY KEY,
	id_usuario INT NOT NULL,
	id_livro INT NOT NULL,
	data_emprestimo DATE NOT NULL,
	data_prevista DATE NOT NULL,
	data_devolucao DATE NULL,
	status_emprestimo VARCHAR(20) NOT NULL DEFAULT 'EM_ANDAMENTO',
	CONSTRAINT FK_Emprestimo_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
	CONSTRAINT FK_Emprestimo_Livro FOREIGN KEY (id_livro) REFERENCES Livro(id_livro)
);
GO

-- Criação de procedures CRUD (Livro) --

-- CREATE
CREATE PROCEDURE sp_livro_insert
	@titulo_livro NVARCHAR(100),
	@autor NVARCHAR(100) = NULL,
	@ano_publicacao INT = NULL,
	@edicao INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @titulo_livro IS NULL
    BEGIN
        RAISERROR('Título do livro é obrigatório.', 16, 1);
        RETURN;
    END;
	INSERT INTO Livro(titulo,autor,ano_publicacao,edicao)
	VALUES (@titulo_livro,@autor,@ano_publicacao,@edicao);
END
GO

-- READ
CREATE PROCEDURE sp_livro_select
	@id_livro INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	IF @id_livro IS NULL
		SELECT * FROM Livro;
	ELSE
		SELECT * FROM Livro 
        WHERE id_livro = @id_livro;
END;
GO

-- UPDATE
CREATE PROCEDURE sp_livro_update
    @id_livro INT,
    @titulo NVARCHAR(100) = NULL,
    @autor NVARCHAR(100) = NULL,
    @ano_publicacao INT = NULL,
	@edicao INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Livro WHERE id_livro = @id_livro)
    BEGIN
        RAISERROR('Livro não encontrado para atualização.', 16, 1);
        RETURN;
    END;
    UPDATE Livro
    SET 
        titulo = COALESCE(@titulo, titulo),
        autor = COALESCE(@autor, autor),
        ano_publicacao = COALESCE(@ano_publicacao, ano_publicacao),
		edicao = COALESCE(@edicao, edicao)
    WHERE id_livro = @id_livro;
END;
GO

-- DELETE
CREATE PROCEDURE sp_livro_delete
    @id_livro INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Livro WHERE id_livro = @id_livro)
    BEGIN
        RAISERROR('Livro não encontrado para exclusão.', 16, 1);
        RETURN;
    END;
    IF EXISTS (
        SELECT 1 
        FROM Emprestimo
        WHERE id_livro = @id_livro
          AND data_devolucao IS NULL
    )
    BEGIN
        RAISERROR('Não é possível excluir o livro: ele está associado a empréstimos ativos.', 16, 1);
        RETURN;
    END;
    DELETE FROM Livro
    WHERE id_livro = @id_livro;
END;
GO

-- Criação de procedures CRUD (Usuario)

-- CREATE
CREATE PROCEDURE sp_usuario_insert
    @nome NVARCHAR(150),
    @email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    IF @nome IS NULL OR @email IS NULL
    BEGIN
        RAISERROR('Nome e Email são obrigatórios.', 16, 1);
        RETURN;
    END;

    INSERT INTO Usuario(nome, email) 
    VALUES(@nome, @email);
END;
GO

-- READ
CREATE PROCEDURE sp_usuario_select
    @id_usuario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @id_usuario IS NULL
        SELECT * FROM Usuario;
    ELSE
        SELECT * FROM Usuario WHERE id_usuario = @id_usuario;
END;
GO

-- UPDATE
CREATE PROCEDURE sp_usuario_update
    @id_usuario INT,
    @nome NVARCHAR(150) = NULL,
    @email NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
    BEGIN
        RAISERROR('Usuário não encontrado para atualização.', 16, 1);
        RETURN;
    END;

    UPDATE Usuario
    SET 
        nome = COALESCE(@nome, nome),
        email = COALESCE(@email, email)
    WHERE id_usuario = @id_usuario;
END;
GO

-- DELETE
CREATE PROCEDURE sp_usuario_delete
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
    BEGIN
        RAISERROR('Usuário não encontrado para exclusão.', 16, 1);
        RETURN;
    END;
    IF EXISTS (
        SELECT 1
        FROM Emprestimo
        WHERE id_usuario = @id_usuario
          AND data_devolucao IS NULL
    )
    BEGIN
        RAISERROR('Não é possível excluir o usuário: existem empréstimos ativos.', 16, 1);
        RETURN;
    END;

    DELETE FROM Usuario
    WHERE id_usuario = @id_usuario;
END;
GO

-- Criação de procedures CRUD (Emprestimo)

-- CREATE
CREATE PROCEDURE sp_emprestimo_insert
    @id_usuario INT,
    @id_livro INT,
    @data_prevista DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @hoje DATE = GETDATE();
    IF EXISTS (
        SELECT 1 FROM Emprestimo
        WHERE id_livro = @id_livro
          AND data_devolucao IS NULL
          AND status_emprestimo = 'EM_ANDAMENTO'
    )
    BEGIN
        RAISERROR('Livro já está emprestado e não foi devolvido.', 16, 1);
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
    BEGIN
        RAISERROR('Usuário não encontrado.', 16, 1);
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Livro WHERE id_livro = @id_livro)
    BEGIN
        RAISERROR('Livro não encontrado.', 16, 1);
        RETURN;
    END;
    IF @data_prevista < @hoje
    BEGIN
        RAISERROR('Data prevista não pode ser anterior à data do empréstimo.', 16, 1);
        RETURN;
    END
    INSERT INTO Emprestimo (id_usuario, id_livro, data_emprestimo, data_prevista, status_emprestimo)
    VALUES (@id_usuario, @id_livro, GETDATE(), @data_prevista, 'EM_ANDAMENTO');
END;
GO

-- READ
CREATE PROCEDURE sp_emprestimo_select
    @id_emprestimo BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @id_emprestimo IS NULL
        SELECT 
            e.id_emprestimo, 
            u.nome AS usuario, 
            l.titulo AS livro,
            e.data_emprestimo, 
            e.data_prevista, 
            e.data_devolucao, 
            e.status_emprestimo
        FROM Emprestimo e
        JOIN Usuario u ON e.id_usuario = u.id_usuario
        JOIN Livro l ON e.id_livro = l.id_livro
    ELSE
        SELECT 
            e.id_emprestimo, 
            u.nome AS usuario, 
            l.titulo AS livro,
            e.data_emprestimo, 
            e.data_prevista, 
            e.data_devolucao, 
            e.status_emprestimo
        FROM Emprestimo e
        JOIN Usuario u ON e.id_usuario = u.id_usuario
        JOIN Livro l ON e.id_livro = l.id_livro
        WHERE e.id_emprestimo = @id_emprestimo;

END;
GO

-- UPDATE
CREATE PROCEDURE sp_emprestimo_update
    @id_emprestimo BIGINT,
    @data_prevista DATE = NULL,
    @data_devolucao DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @data_emprestimo DATE;
    IF NOT EXISTS (SELECT 1 FROM Emprestimo WHERE id_emprestimo = @id_emprestimo)
    BEGIN
        RAISERROR('Empréstimo não encontrado.', 16, 1);
        RETURN;
    END;
    SELECT @data_emprestimo = data_emprestimo
    FROM Emprestimo
    WHERE id_emprestimo = @id_emprestimo;
    IF @data_prevista IS NOT NULL AND @data_prevista < @data_emprestimo
    BEGIN
        RAISERROR('Data prevista não pode ser anterior à data do empréstimo.', 16, 1);
        RETURN;
    END
    IF @data_devolucao IS NOT NULL AND @data_devolucao < @data_emprestimo
    BEGIN
        RAISERROR('Data de devolução não pode ser anterior à data do empréstimo.', 16, 1);
        RETURN;
    END
    UPDATE Emprestimo
    SET 
        data_prevista = COALESCE(@data_prevista, data_prevista),
        data_devolucao = COALESCE(@data_devolucao, data_devolucao),
        status_emprestimo = CASE 
                                WHEN @data_devolucao IS NOT NULL THEN 'DEVOLVIDO'
                                ELSE status_emprestimo
                            END
    WHERE id_emprestimo = @id_emprestimo;
END;
GO

-- DELETE
CREATE PROCEDURE sp_emprestimo_delete
    @id_emprestimo BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Emprestimo WHERE id_emprestimo = @id_emprestimo)
    BEGIN
        RAISERROR('Empréstimo não encontrado.', 16, 1);
        RETURN;
    END;
    IF EXISTS (
        SELECT 1 FROM Emprestimo
        WHERE id_emprestimo = @id_emprestimo
          AND (data_devolucao IS NOT NULL OR status_emprestimo <> 'EM_ANDAMENTO')
    )
    BEGIN
        RAISERROR('Não é possível cancelar: empréstimo já foi concluído.', 16, 1);
        RETURN;
    END;

    DELETE FROM Emprestimo
    WHERE id_emprestimo = @id_emprestimo;
END;
GO

-- STATUS UPDATE
CREATE PROCEDURE sp_atualizar_emprestimos_atrasados
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Emprestimo
    SET status_emprestimo = 'EM_ATRASO'
    WHERE status_emprestimo = 'EM_ANDAMENTO'
      AND data_prevista < CAST(GETDATE() AS DATE)
      AND data_devolucao IS NULL;
END;
GO
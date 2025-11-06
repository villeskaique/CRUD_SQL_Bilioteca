USE biblioteca;
GO

-- CREATE
CREATE PROCEDURE dbo.livro_insert
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
CREATE PROCEDURE dbo.livro_select
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
CREATE PROCEDURE dbo.livro_update
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
CREATE PROCEDURE dbo.livro_delete
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
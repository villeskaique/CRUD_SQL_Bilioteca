USE biblioteca;
GO

-- CREATE
CREATE PROCEDURE dbo.emprestimo_insert
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
CREATE PROCEDURE dbo.emprestimo_select
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
CREATE PROCEDURE dbo.emprestimo_update
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
CREATE PROCEDURE dbo.emprestimo_delete
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
CREATE PROCEDURE dbo.atualizar_emprestimos_atrasados
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
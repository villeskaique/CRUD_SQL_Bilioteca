USE biblioteca;
GO

-- CREATE
CREATE PROCEDURE dbo.usuario_insert
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
CREATE PROCEDURE dbo.usuario_select
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
CREATE PROCEDURE dbo.usuario_update
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
CREATE PROCEDURE dbo.usuario_delete
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
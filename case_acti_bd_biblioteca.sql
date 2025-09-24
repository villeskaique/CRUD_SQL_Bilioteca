
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

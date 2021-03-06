--Создать базу данных в папке по умолчанию для SQL Server
CREATE DATABASE testProject;

go
use testProject

go
CREATE Table Clients 
	(
		ID int IDENTITY(1,1) PRIMARY KEY, 
		Name varchar(255)
	)

go
CREATE Table Goods 
	(
		ID int IDENTITY(1,1) PRIMARY KEY, 
		Name varchar(255)
	)

go
CREATE Table Consumpions 
	(
		ID int IDENTITY(1,1) PRIMARY KEY, 
		ClientID int, 
		DateTimeInsert DATETIME DEFAULT GETDATE(), 
		Sum FLOAT, 
		DateTimeCreate DATETIME, 
		Done int NOT NULL DEFAULT 0, --0-Не завершён (значение по умолчанию), 1-Завершён изменения состава запрещены 
		DateTimeDone DATETIME, 
		FOREIGN KEY (ClientID) REFERENCES Clients(ID),
		CONSTRAINT CHK_Consumpions CHECK (Done = 0 OR Done=1)
	)

go
CREATE Table Consumpion_Compositions
	(
		ID int IDENTITY(1,1) PRIMARY KEY, 
		ConsumpionID int, 
		GoodID int,
		Count FLOAT,
		Price FLOAT,
		Sum FLOAT,
		FOREIGN KEY (ConsumpionID) REFERENCES Consumpions(ID),
		FOREIGN KEY (GoodID) REFERENCES Goods(ID)
	)

go
--Создание тригера на запрет внесения изменений в завершенный "расход" и корректрировка суммы расхода с суммой состава расхода
CREATE TRIGGER CHK_IDU_DONE_AND_CORRECT ON Consumpion_Compositions 
	AFTER INSERT, DELETE, UPDATE AS  
	DECLARE @ID int;
	DECLARE @SUM float;

	--Узнаем заблокирован ли расход...
	SELECT 
		@ID = c.ID
	FROM Consumpions AS c   
	LEFT JOIN inserted AS i ON (c.ID = i.ConsumpionID)
	LEFT JOIN deleted AS d ON (c.ID = d.ConsumpionID)
	WHERE c.Done = 1 

	IF ISNULL(@ID, 0) != 0
	BEGIN  
		--Если расход заблокирован значит показываем сообщение и отменяем транзакцию 
		RAISERROR(N'Состояние Расхода ID:"%d" запрещает редактирование', -1, -1, @ID);  

		ROLLBACK TRANSACTION;  
		RETURN   
	END
	ELSE
	BEGIN
		--Получаем ID рахода для дальнейших манипуляций, выделенно под отдельное условия (упрощение отладки)
		IF EXISTS(SELECT * FROM inserted)
		BEGIN
			SELECT @ID = i.ConsumpionID FROM inserted i;
		END
		ELSE
		BEGIN
			SELECT @ID = d.ConsumpionID FROM deleted d;
		END
		(SELECT @SUM = Sum(ISNULL(cc.sum, 0)) FROM Consumpion_Compositions cc WHERE cc.ConsumpionID = @ID);

		--Из за того что DELETE происходит раньше тригера то изменений в сумму вносить не нужно но для INSERT и UPDATE нужно так как они еще не повлияли на таблицу (Актуально для MSSQL 2014 для которого это писалось)
		IF EXISTS(SELECT * FROM inserted) and EXISTS(SELECT * FROM deleted)
		BEGIN
			(SELECT @SUM = @SUM +ISNULL(i.Count*i.Price, 0) FROM inserted i);
			(SELECT @SUM = @SUM -ISNULL(d.Count*d.Price, 0) FROM deleted d);
		END
		IF EXISTS(SELECT * FROM inserted) and NOT EXISTS(SELECT * FROM deleted)
		BEGIN
			(SELECT @SUM = @SUM +ISNULL(i.Count*i.Price, 0) FROM inserted i);
		END;

		--Обновляем сумму для состава расхода
		UPDATE Consumpions SET Sum = @SUM WHERE ID = @ID;
		if EXISTS(SELECT * FROM inserted)
		BEGIN
			UPDATE Consumpion_Compositions
			SET sum = i.Count*i.Price
			FROM Consumpion_Compositions
			INNER JOIN inserted i on i.ID = Consumpion_Compositions.ID
		END
	END
	
go
--Тригер для установки даты завершения и даты создания для расхода  
CREATE TRIGGER CHK_IU_DONE ON Consumpions
	AFTER INSERT, UPDATE AS
		DECLARE @Done int;
		IF EXISTS(SELECT * FROM inserted)
		BEGIN
			IF EXISTS(SELECT * FROM inserted) and NOT EXISTS(SELECT * FROM deleted)
			BEGIN
				UPDATE Consumpions
				SET DateTimeCreate = GETDATE()
				FROM Consumpions
				INNER JOIN inserted i on i.ID = Consumpions.ID 
			END
			ELSE
			BEGIN
				(SELECT @Done = i.done FROM inserted i);

				IF @Done = 1
				BEGIN
					UPDATE Consumpions
					SET DateTimeDone = GETDATE()
					FROM Consumpions
					INNER JOIN inserted i on i.ID = Consumpions.ID 
				END
				ELSE
				BEGIN
					UPDATE Consumpions
					SET DateTimeDone = NULL
					FROM Consumpions
					INNER JOIN inserted i on i.ID = Consumpions.ID 
				END
			END
		END
		
go
--Заполняем таблицу клиентов 
DECLARE @Count int;
DECLARE @MAXCount int;

SET @Count = 0;
SET @MAXCount = 9;

WHILE @MAXCount >= @Count
BEGIN 
	INSERT INTO Clients (Name) VALUES ('Client Number'+Convert(VarChar(2), @Count));
	SET @Count = @Count + 1;
END; 

go
--Заполняем таблицу товаров
DECLARE @Count int;
DECLARE @MAXCount int;

SET @Count = 0;
SET @MAXCount = 9;

WHILE @MAXCount >= @Count
BEGIN 
	INSERT INTO Goods (Name) VALUES ('Good Number'+Convert(VarChar(2), @Count));
	SET @Count = @Count + 1;
END; 
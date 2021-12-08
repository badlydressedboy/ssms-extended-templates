DECLARE @Emoji TABLE
(
     [name] VARCHAR(50) NOT NULL,
     [character] NVARCHAR(20) NOT NULL
);

INSERT INTO @Emoji ([name], [character])
     VALUES ('recycling symbol', NCHAR(0x267B));
INSERT INTO @Emoji ([name], [character])
     VALUES ('money bag', NCHAR(0xD83D) + NCHAR(0xDCB0));
INSERT INTO @Emoji ([name], [character])
     VALUES ('woman juggling', NCHAR(0xD83E) + NCHAR(0xDD39) + NCHAR(0x200D)
                                        + NCHAR(0x2640) + NCHAR(0xFE0F));

SELECT * FROM @Emoji;
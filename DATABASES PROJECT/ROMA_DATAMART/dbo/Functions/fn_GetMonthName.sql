Create FUNCTION [dbo].[fn_GetMonthName] (
    @Date DATETIME,
    @Language NVARCHAR(100)
)
RETURNS NVARCHAR(400)
AS
BEGIN
    DECLARE @i INT, @m INT,@mlist NVARCHAR(1000)
    SET @m = MONTH(@Date)
    SET @mlist = (SELECT months FROM sys.syslanguages WHERE ALIAS = @language)
    SET @i = 1
    WHILE(@i < @m)
        BEGIN
           SET @mlist = REPLACE(@mlist, SUBSTRING(@mlist,1,CHARINDEX(',',@mlist)) ,'')
           SET @i = @i + 1
        END
    SET @mlist = (CASE CHARINDEX(',',@mlist) WHEN 0 THEN @mlist ELSE SUBSTRING(@mlist,0,CHARINDEX(',',@mlist) ) END )
    RETURN @mlist
END

GO


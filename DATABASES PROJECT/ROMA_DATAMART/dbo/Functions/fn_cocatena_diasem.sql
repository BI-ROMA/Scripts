Create FUNCTION [dbo].[fn_cocatena_diasem](@nombre1 CHAR(7),@dia int ) 
RETURNS char(7)
as
BEGIN
    DECLARE @ls_nombre varchar(7)
    DECLARE @li_nombre int
	DECLARE @ls_char char(1)
	DECLARE @RESUL char(7)
	DECLARE @NINICIO INT

        set @ls_char=CAST(@dia as CHAR(1))
        set @li_nombre=CAST(@nombre1 as INT )
        set @ls_nombre=CAST(@li_nombre as varchar(7))

        SET @NINICIO = CHARINDEX(@ls_char,@ls_nombre)
           if  @NINICIO=0 
               begin 
                  set @ls_nombre=@ls_nombre+@ls_char
               end   
           
   
        
        SET @RESUL=right('0000000'+@ls_nombre,7)
           


return @RESUL
END

GO


create function  [dbo].[fn_get_nomdiaSemana]  ( @ai_dia integer  )
returns varchar(15)
begin
declare @nomdia varchar(15)
   select @nomdia=CASE @ai_dia when 1 then 'LUNES' when 2 then 'MARTES' when 3 then 'MIERCOLES' when 4 then 'JUEVES' when 5 then 'VIERNES' when 6 then 'SABADO' 
      when 7 then 'DOMINGO' end

return @nomdia
 end

GO


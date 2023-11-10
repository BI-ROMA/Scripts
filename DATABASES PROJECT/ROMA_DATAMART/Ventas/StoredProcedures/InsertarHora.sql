create procedure ventas.InsertarHora
   @Time datetime
as
   declare @IdHora int, @Hora tinyint,
           @Minuto tinyint, @Segundo tinyint, @AM char(2),
           @NombreHora char(2), @NombreHoraAM char(5),
           @NombreMinuto char(2), @NombreSegundo char(2),
           @HoraMinuto char(5), @HoraMinutoAM char(8),
           @HoraMinutoSegundo char(8), @HoraMinutoSegundoAM char(11)

   --Calcular columnas mínimas necesarias
   set @Hora = datepart(hour, @Time)
   set @Minuto = datepart(minute, @Time)
   set @Segundo = datepart(second, @Time)
   set @IdHora = (@Hora*10000) + (@Minuto*100) + @Segundo 
       --Se puede dejar tanto para granularidad minutos como
       --segundos, o bien
       --(@Hora*100) + @Minuto, para granularidad minutos,
       --pero luego no habría huecos para aumentar la
       --granularidad a segundos
       --@Hora, para granularidad horas, pero luego no habría
       -- huecos para aumentar la granularidad a minutos o segundos
   --Aquí se agregarán todos los cálculos en base a esa hora
   --que estimemos oportunos
   --Mostramos algunos de los formatos más habituales,
   --pero no su cálculo, sino que le asignamos un valor fijo
   --a modo de ejemplo
   set @AM = right(convert(varchar,@Time,109),2) -- AM/PM
   set @NombreHora = '00'        -- HH con ceros por la izquierda
   set @NombreHoraAM = '12 AM'   -- HH AM las 00 son las 12 AM
   set @NombreMinuto = '00'      -- MM con ceros por la izquierda
   set @NombreSegundo = '00'     -- SS con ceros por la izquierda
   set @HoraMinuto = '00:00'     -- HH:MM con ceros por la izquierda
   set @HoraMinutoAM = '12:00 AM'
   -- HH:MM AM las 00:00 son las 12:00 AM
   set @HoraMinutoSegundo = convert(varchar, @Time, 108) -- HH:MM:SS
   set @HoraMinutoSegundoAM = '12:00:00 AM'
   -- HH:MM:SS AM las 00:00:00 son las 12:00:00 AM

   --Insertar fila
   insert into Ventas.DimHora(IdHora, Tiempo, Hora, Minuto, Segundo,
          AM, NombreHora, NombreHoraAM, NombreMinuto, NombreSegundo,
          HoraMinuto, HoraMinutoAM, HoraMinutoSegundo,
          HoraMinutoSegundoAM)
      select @IdHora, @Time, @Hora, @Minuto, @Segundo, @AM,
             @NombreHora, @NombreHoraAM, @NombreMinuto,
             @NombreSegundo, @HoraMinuto, @HoraMinutoAM,
             @HoraMinutoSegundo, @HoraMinutoSegundoAM

GO


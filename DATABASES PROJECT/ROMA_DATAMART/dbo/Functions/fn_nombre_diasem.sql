CREATE FUNCTION [dbo].[fn_nombre_diasem](@nombre1 CHAR(7) ) 
RETURNS varchar(50)
as
BEGIN
    DECLARE @ls_nombre varchar(50)
    DECLARE @ls_nomb1 varchar(10)
    DECLARE @ls_nomb2 varchar(10)
	DECLARE @ls_char char(1)
	DECLARE @ls_char_min char(1)
	DECLARE @ls_char_max char(1)
	DECLARE @RESUL varchar(50)
	DECLARE @NINICIO INT
	DECLARE @I INT 
	DECLARE @LI_LEN1 INT 
	DECLARE @LI_CONT INT 

 
        SET @LI_CONT=0
        
        SET @LI_LEN1=LEN(@nombre1)
        SET @I=0
		SET @ls_nombre=''        

        WHILE @I < @LI_LEN1 
		BEGIN
                
				set @I=@I+1
                set @ls_char=CAST(@I AS CHAR(1))						
				SET @NINICIO = CHARINDEX(@ls_char,@nombre1)
				IF @NINICIO>0
				   BEGIN
						if @LI_CONT=0 
						    begin 
							   set @ls_char_min= @ls_char
							   set @ls_char_max= @ls_char
							end    
				        else
				            begin 
								   if @ls_char<@ls_char_min
									  set @ls_char_min= @ls_char
									  
								   if @ls_char>@ls_char_max
									  set @ls_char_max= @ls_char
									  
						    end 			  
				   
							IF @ls_char='1'
								BEGIN 
									SET @ls_nombre=@ls_nombre+'Lun'
									SET @LI_CONT=@LI_CONT+1

								END 				    
						
							IF @ls_char='2'
									BEGIN 
										
										SET @LI_CONT=@LI_CONT+1
										IF @LI_CONT=1
										   SET @ls_nombre=@ls_nombre+'Mar'
										ELSE  
										   SET @ls_nombre=@ls_nombre+' Y '+'Mar' 
										
									END 	
						    
							IF @ls_char='3'
									BEGIN 
										SET @LI_CONT=@LI_CONT+1
										IF @LI_CONT=1
										   SET @ls_nombre=@ls_nombre+'Mie'
										ELSE
										   SET @ls_nombre=@ls_nombre+' Y '+'Mie'
									END 	
						    
							IF @ls_char='4'
									BEGIN 
										SET @LI_CONT=@LI_CONT+1
										IF @LI_CONT=1
										   SET @ls_nombre=@ls_nombre+'Jue'
										ELSE
										   SET @ls_nombre=@ls_nombre+' Y '+'Jue'

									END 	
										
							
							IF @ls_char='5'
									BEGIN 
										SET @LI_CONT=@LI_CONT+1
										IF @LI_CONT=1
										   SET @ls_nombre=@ls_nombre+'Vie'
										ELSE
										   SET @ls_nombre=@ls_nombre+' Y '+'Vie'
									END 	
							    
							    
							IF @ls_char='6'
									BEGIN 	
												
										SET @LI_CONT=@LI_CONT+1
										IF @LI_CONT=1
										   SET @ls_nombre=@ls_nombre+'Sab'
										ELSE
										   SET @ls_nombre=@ls_nombre+' Y '+'Sab'
									
									END 	
						END 			
			
		END
		
if cast(@ls_char_max as INT )- cast(@ls_char_min as INT )+ 1 =	@LI_CONT and @LI_CONT<>1
    begin	
      set @ls_nomb1=case @ls_char_min when '1' then 'Lun' WHEN '2' THEN 'Mar' WHEN '3' THEN 'Mie' WHEN '4' THEN 'Jue' WHEN '5' THEN 'Vie' END
      set @ls_nomb2=case @ls_char_max when '2' THEN 'Mar' WHEN '3' THEN 'Mie' WHEN '4' THEN 'Jue' WHEN '5' THEN 'Vie' when '6' then 'Sab' END
      
      SET @ls_nombre=@ls_nomb1 + ' ' +'A'+' '+ @ls_nomb2
      
    end       
    
SET @RESUL=@ls_nombre

return @RESUL
END

GO


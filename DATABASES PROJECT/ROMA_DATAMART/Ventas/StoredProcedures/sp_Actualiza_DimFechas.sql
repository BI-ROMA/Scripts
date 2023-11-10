CREATE Procedure [Ventas].[sp_Actualiza_DimFechas]
As
-- Select * From ventas.DimFechas Order By Fecha Desc

Begin

	Set NoCount On
	Set DateFormat dmy
	Set LANGUAGE SPANISH

	-- Drop Table #Fechas 
	-- Select * Into #Fechas From Ventas.DimFechas
	--Truncate Table Ventas.DimFechas
	--Truncate Table #Fechas 

	Declare @fi Date = '01/01/2019', @ff Date = Cast(Getdate() as Date)
	While @fi <= @ff
	Begin
		Insert Into Ventas.DimFechas (Fecha, Año, Mes, Dia, DiaMes, DiaAño, NuNombreMes, NombreMes,
		NombreMesAbr, NombreDia, NombreDiaAbr, NombreDiaFull, NombreFechaFull, NuSemestre, NoSemestre, FechaKey, 
		IdDiezDias, NoDiezDias, IdTrimestre, NoTrimestre, NoTrimestreFull, NuDiezDias)
		Select @fi, Year(@fi), MONTH(@fi), Day(@fi), 'Día ' + Ltrim(Str(Day(@fi))),	'Día ' + Ltrim(Str(DatePart(dy, @fi))), 
		Convert(Char(6), @fi, 112), DateName(Month, @fi), 
		Left(DateName(Month, @fi), 3) + '-' + Right(Ltrim(Str(Year(@fi))), 2), 
		DateName(DW, @fi),
		Left(DateName(DW, @fi), 3),
		Left(DateName(DW, @fi), 3) + ' ' + Ltrim(Str(Day(@fi))), 
		Left(DateName(DW, @fi), 3) + ', ' + Convert(Varchar(15), @fi, 106), 
		Case When MONTH(@fi) <= 6 Then Ltrim(Str(Year(@fi))) + '01' Else Ltrim(Str(Year(@fi))) + '02' End ,
		Case When MONTH(@fi) <= 6 Then 'S-1' Else 'S-2' End, Convert(Char(8), @fi, 112),
		Convert(Int , Convert(Char(6), @fi, 112)+ Case When Day(@fi) > 20 Then '03' Else Case When Day(@fi) > 10 Then '02' Else '01' End End),
		--(Case When Day(@fi) > 20 Then '3er Diez Días' Else Case When Day(@fi) > 10 Then '2do Diez Días' Else '1er Diez Días' End End)+'.'+Left(DateName(Month, @fi), 3) + '.' + Right(Ltrim(Str(Year(@fi))), 2),
		(Case When Day(@fi) > 20 Then '3er Diez Días' Else Case When Day(@fi) > 10 Then '2do Diez Días' Else '1er Diez Días' End End),
		Cast(Ltrim(Str(Year(@fi))) + Right('00'+Ltrim(Str(DatePart(Q, @fi))), 2) As Int),
		NoTrimestre = 'TRI-'+Ltrim(Str(DatePart(Q, @fi))),
		NoTrimestreFull = 'TRI-'+Ltrim(Str(DatePart(Q, @fi))) + ', ' + Right(Ltrim(Str(Year(@fi))), 2),
		(Case When Day(@fi) > 20 Then 3 Else Case When Day(@fi) > 10 Then 2 Else 1 End End)
		Where Not Exists(Select * From Ventas.DimFechas x Where x.Fecha = @fi)

		Set @fi = DateAdd(dd, 1, @fi)

	End


	Update Ventas.DimFechas Set DiaSemana = Null

	Update Ventas.DimFechas 
	Set IdSemana = Ltrim(Str(Year(Fecha)))+Right('00'+Ltrim(Str(DATEPART(WEEK, Fecha))), 2),
		NoSemana = 'Sem ' + Ltrim(Str(DATEPART(WEEK, Fecha))) + ', ' + Right(Ltrim(Str(Year(Fecha))), 2),
		DiaSemana = DatePart(dw, Fecha)
	Where IdSemana Is Null Or NoSemana Is Null Or DiaSemana Is Null
		
	Declare @Periodo Char(6) = Convert(Char(6), Getdate(), 112)
	Declare @Fe Char(8)
	If Not Exists(Select * From ventas.DimCalendario Where Convert(Char(6), Fecha, 112) = @Periodo)
	Begin
		Print 'x'
		Set @fi = Cast(@Periodo + '01' as date)
		Set @ff = DateAdd(Day, -1, DateAdd(Month, 1, @fi))
				
		While @fi <= @ff
		Begin
			Set @Fe = Convert(Char(8), @fi, 112)			
			Insert Into Ventas.DimCalendario(Fecha)
			Select @fi 
			Where Not Exists(Select * From Ventas.DimCalendario b Where b.Fecha = @fi)
			Set @fi = DateAdd(dd, 1,@fi)
		End


		Update a Set FlFeriado = 1
		From Ventas.DimCalendario a
		Inner Join SRVSAP.roma_productiva.Reportes.mae_feriado b On a.fecha = b.fecdia
		Where numano = Left(@Periodo, 4)
			
	End
	/*
	;With dtferiados as (Select * From SRVSAP.roma_productiva.reportes.mae_feriado)
	Insert Into Ventas.DimFeriados
	Select * From dtferiados a
	Where Not Exists(Select * From Ventas.DimFeriados b Where a.fecdia = b.fecdia)
	And a.numano >=2019*/


	;With dt As (Select *, ROW_NUMBER() Over(Partition By Convert(Varchar(6), fecha, 112) Order By Fecha) NuDiaLaboral
					From ventas.DimCalendario Where FlFeriado = 0)
	--Select a.NuNombreMes+Right('00'+Ltrim(Str(b.NuDiaLaboral)), 2), * 
	Update a Set IdDiaLaboral = a.NuNombreMes+Right('00'+Ltrim(Str(b.NuDiaLaboral)), 2), NuDiaLaboral = b.NuDiaLaboral, NoDiaLaboral = b.NuDiaLaboral
	From ventas.DimFechas a
	Inner Join dt b On a.Fecha = b.Fecha
	Where IdDiaLaboral Is Null

	;With dt As (Select *, ROW_NUMBER() Over(Partition By Convert(Varchar(6), fecha, 112) Order By Fecha) NuDiaLaboral
					From ventas.DimCalendario Where FlFeriado = 1)
	--Select a.NuNombreMes+Right('00'+Ltrim(Str(b.NuDiaLaboral)), 2), * 
	Update a Set IdDiaLaboral = a.NuNombreMes+Right('00'+Ltrim(Str(b.NuDiaLaboral)), 2), NuDiaLaboral = 0, NoDiaLaboral = b.NuDiaLaboral
	From ventas.DimFechas a
	Inner Join dt b On a.Fecha = b.Fecha
	Where IdDiaLaboral Is Null


	;With 
	dt As (Select *, Case When FlFeriado=1 Then 0 Else 1 End QtdDias
				From ventas.DimCalendario a
				Where Year(Fecha)=Year(Getdate()) And MONTH(Fecha)=Month(Getdate())),
	dt1 As (Select *, Sum(QtdDias) Over(Order By Fecha) QDiasAcum, Sum(QtdDias) Over(Partition By Month(Fecha)) QTDias
		From dt),
	dt2 As (Select *, (QTDias-QDiasAcum) DiasFaltantes From dt1)
	Update a Set DiasFaltates_xMes = DiasFaltantes 
	--Select * 
	From Ventas.DimFechas a
	Inner Join dt2 b On a.Fecha = b.Fecha
	Where a.DiasFaltates_xMes Is Null

	--Set NoCount On
	--Set DateFormat dmy
	--SET LANGUAGE SPANISH

	--Declare @fi Date = '01/01/2021', @ff Date = Cast(Getdate()-2 as Date), @fecha Varchar(8)
	--While @fi <= @ff
	--Begin
	--	Set @fecha = Convert(Varchar(11), @fi, 112)
	--	Print 'Inicio: ' + @fecha
	--	Exec [Ventas].[SP_Fact_Digitacion] @fecha
	--	Print 'Fin: ' + @fecha
	--	Set @fi = DateAdd(dd, 1, @fi)
	--End

	/*
	Select * 
	--Update a Set FlFeriado  =1
	From Ventas.DimCalendario a
	Inner Join SrvSAP.Roma_Productiva.Reportes.Mae_Feriado b On a.Fecha = b.Fecdia
	Where Year(a.Fecha)=2022 And MONTH(a.Fecha)= 6
	Order By Fecha Desc
	*/

	Update ventas.DimFechas Set Fl4UltMesesCerrados = '0'

	;With dt As (Select Convert(Char(8), Getdate()-1, 112) FechaFin, FechaKey, ROW_NUMBER() Over(Order By FechaKey Desc) Cor
			From ventas.DimFechas 
			Where NuDiaLaboral > 0 And FechaKey <= Convert(Char(8), Getdate()-1, 112))
	Update a Set Fl4UltMesesCerrados = 1
	From Ventas.DimFechas a, dt b 
	Where a.FechaKey Between b.FechaKey And b.FechaFin And Cor = 180


	Update ventas.DimFechas Set FlUlt30DiasHabiles = '0'

	;With dt As (Select Convert(Char(8), Getdate()-1, 112) FechaFin, FechaKey, ROW_NUMBER() Over(Order By FechaKey Desc) Cor
			From ventas.DimFechas 
			Where NuDiaLaboral > 0 And FechaKey <= Convert(Char(8), Getdate()-1, 112))
	Update a Set FlUlt30DiasHabiles = 1
	From Ventas.DimFechas a, dt b 
	Where a.FechaKey Between b.FechaKey And b.FechaFin And Cor = 30

	
	--;With dt As (Select Convert(Char(8), getdate()-1, 112) PeriodoFin, 	
	--			Convert(Char(8), DateAdd(Day, -180, getdate()) , 112) PeriodoIni)
	--Update a Set Fl4UltMesesCerrados = '1'
	---- Select * 
	--From ventas.DimFechas a
	--Inner Join dt b On a.FechaKey Between b.PeriodoIni And b.PeriodoFin

	--Select * From ventas.DimFechas Order By FechaKey Desc

	Set NoCount Off
		
End

GO


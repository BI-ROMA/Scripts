


CREATE View [Ventas].[Dim_vw_FactorProyectado]
As
With dt As (Select
			Cast(Getdate()-1 As Date) FechaActual, 
			Cast(Getdate() As Time) HoraActual,
			Cast(Convert(Varchar(11), Getdate(), 111) + ' 07:30:00 AM' as Datetime) HoIni,
			Cast(Convert(Varchar(11), Getdate(), 111) + ' 06:00:00 PM' as Datetime) HoFin),
	dtCalendario As (Select 			
			Cast(Getdate()-1 As Date) Fecha, 
			Sum(Case When FlFeriado=1 And Fecha <= Getdate()-1 Then 1 Else 0 End) DiasFeriadosTranscurridos,
			Sum(Case When FlFeriado=0 And Fecha <= Getdate()-1 Then 1 Else 0 End) DiasValidosTranscurridos,
			Sum(Case When FlFeriado=1 Then 1 Else 0 End) DiasFeriadosMes,
			Sum(Case When FlFeriado=0 Then 1 Else 0 End) DiasValidosMes
			-- Select *
			From Ventas.DimCalendario 
			Where Convert(Char(6), Fecha, 112) = Convert(Char(6), Getdate()-1, 112))
	,DtTot As (Select FechaActual, HoraActual,
			1.00*DateDiff(mi, HoIni, getdate())/(1.00*DateDiff(mi, HoIni, HoFin)) FactorPry,
			Day(Getdate()-1) Dia,
			Day(Getdate()-2) DiaAnterior, DiasFeriadosTranscurridos, DiasFeriadosMes, 
			DiasValidosMes, DiasValidosTranscurridos,
			1.00*1/(Case When DiasValidosMes = DiasValidosTranscurridos Then 1 Else (DiasValidosMes - DiasValidosTranscurridos) End) FactorPryDiasFaltantes
			From dt a
			Inner Join dtCalendario b On a.FechaActual = b.Fecha)
Select Convert(int, Convert(Char(8), FechaActual, 112)) FechaKey, a.*, 
Round(1.00*DiasValidosMes/DiasValidosTranscurridos, 4) FactorPryMes, 
Cast(Getdate()-1 As Date) FechaDiaAnterior, Cast(Convert(Varchar(8), Getdate()-2, 112) As Int) Fecha2DiasAntes,
DiasValidosMes -DiasValidosTranscurridos DiasFaltantes,
'[Fechas].[Año - Tri - Mes].[Trimestre].&['+Ltrim(Str(IdTrimestre))+']' TriActual
From DtTot a
Inner Join ventas.DimFechas b On Convert(Char(8), a.FechaActual, 112) = b.FechaKey

GO


;With dt As (Select IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVen, 
				'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
				Right('00'+Ltrim(Str(IdMesa)), 2) + 
				Right('00'+Ltrim(Str(IdCanal)), 2) + Right('000'+Ltrim(Str(IdCar)), 3) +
				Right('000'+Ltrim(Str(IdPrv)), 3) + Right('000'+Ltrim(Str(IdCat_xPrv)), 3) +
				Right('0000'+Ltrim(Str(IdVen)), 4) IdRelGeneral
				From Ventas.Fact_Cuotas)
Insert Into ventas.DimRelGeneral(IdRelGeneral, IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVendedor)
Select Distinct IdRelGeneral, IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVen From dt a
Where Not Exists (Select * From Ventas.DimRelGeneral b Where a.IdRelGeneral = b.IdRelGeneral)


;With dt As (Select IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv,
				'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
					Right('00'+Ltrim(Str(IdCanal)), 2) + Right('000'+Ltrim(Str(IdCar)), 3) +
					Right('000'+Ltrim(Str(IdPrv)), 3) + Right('000'+Ltrim(Str(IdCat_xPrv)), 3) IdRelGeneral2
				From Ventas.Fact_Cuotas)
Insert Into ventas.DimRelGeneral2(IdRelGeneral, IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv)
Select Distinct IdRelGeneral2, IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv From dt a
Where Not Exists (Select * From Ventas.DimRelGeneral2 b Where a.IdRelGeneral2 = b.IdRelGeneral)


Update Ventas.Fact_Cuotas 
Set IdRelGeneral = 'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
					Right('00'+Ltrim(Str(IdMesa)), 2) + 
					Right('00'+Ltrim(Str(IdCanal)), 2) + Right('000'+Ltrim(Str(IdCar)), 3) +
					Right('000'+Ltrim(Str(IdPrv)), 3) + Right('000'+Ltrim(Str(IdCat_xPrv)), 3) +
					Right('0000'+Ltrim(Str(IdVen)), 4),
	IdRelGeneral2 = 'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
					Right('00'+Ltrim(Str(IdCanal)), 2) + Right('000'+Ltrim(Str(IdCar)), 3) +
					Right('000'+Ltrim(Str(IdPrv)), 3) + Right('000'+Ltrim(Str(IdCat_xPrv)), 3)

Update Planillas.Fact_Ventas 
Set IdRelGeneral = 'X0001000000002280376',
	IdRelGeneral2 = 'X0000000000228'

Update Ventas.Fact_CarteraInicial_xVendedor 
Set IdRelGeneral = 'X0001000000002280376',
	IdRelGeneral2 = 'X0000000000228'

Update Ventas.Fact_Ventas_Detalle
Set IdRelGeneral = 'X0001000000002280376',
	IdRelGeneral2 = 'X0000000000228'




;With dt As (Select distinct IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVen, IdRelGeneral 
			From Ventas.Fact_Cuotas)
Update a Set IdRelGeneral = b.IdRelGeneral
From Planillas.Fact_Ventas a
Inner Join dt b On a.IdSede = b.IdSede and a.IdMesa = b.IdMesa And a.IdCanal = b.IdCanal And a.IdVendedor = b.IdVen
And a.IdProveedor = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCartera = b.IdCar

;With dt As (Select distinct IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdRelGeneral2 From Ventas.Fact_Cuotas)
Update a Set IdRelGeneral2 = b.IdRelGeneral2
From Planillas.Fact_Ventas a
Inner Join dt b On a.IdSede = b.IdSede and a.IdCanal = b.IdCanal 
And a.IdProveedor = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCartera = b.IdCar

--select top(100)* from Planillas.Fact_Ventas where left(fechakey, 6) = 202206

;With dt As (Select distinct IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVen, IdRelGeneral From Ventas.Fact_Cuotas)
Update a Set IdRelGeneral = b.IdRelGeneral
From Ventas.Fact_CarteraInicial_xVendedor a
Inner Join dt b On a.IdSede = b.IdSede and a.IdMesa = b.IdMesa And a.IdCanal = b.IdCanal And a.IdVen = b.IdVen
And a.IdProveedor = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCartera = b.IdCar

;With dt As (Select distinct IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdRelGeneral2 From Ventas.Fact_Cuotas)
Update a Set IdRelGeneral2 = b.IdRelGeneral2
-- Select Top 1000 *
From Ventas.Fact_CarteraInicial_xVendedor a
Inner Join dt b On a.IdSede = b.IdSede and a.IdCanal = b.IdCanal 
And a.IdProveedor = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCartera = b.IdCar





--Select * From ventas.DimRelGeneral2


;With 
dt As (Select Distinct IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdRelGeneral2, IdVen, FechaKey
	From Ventas.Fact_Cuotas),
dt1 As (Select IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdRelGeneral2, IdVen, FechaKey,
	ROW_NUMBER() Over(Partition By idsede, IdPrv, IdCat_xPrv, idcar Order By FechaKey Desc) Orden
	From dt),
dt2 As (Select distinct a.*, b.NomVen From dt1 a
	Inner Join Ventas.DimVendedores b On a.IdVen = b.IdVen
	Where Orden = 1)
Update a Set NomVendedor = b.NomVen
From ventas.DimRelGeneral2 a 
Inner Join dt2 b On a.IdCar = b.IdCar And a.IdPrv = b.IdPrv 
And a.IdCat_xPrv = b.IdCat_xPrv 
And a.IdSede = b.IdSede And a.IdCanal = b.IdCanal


--;With dt As (
--	Select Distinct IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdRelGeneral2, IdVen
--	From Ventas.Fact_Cuotas)
--Update a Set NomVendedor = c.NomVen
---- Select *
--From ventas.DimRelGeneral2 a
--Inner Join dt b On a.IdRelGeneral = b.IdRelGeneral2
--Inner Join ventas.DimVendedores c On b.IdVen = c.IdVen
--Where NomVendedor Is Null


Select * From ventas.DimCanales
Select * From ventas.DimSedes
Select * From Ventas.Dim_Categorias_xProveedor Where NomCat_Abrv Like '%family%'

Select * From ventas.Fact_Cuotas a
Inner Join ventas.DimVendedores b On a.IdVen = b.IdVen
Where Left(FechaKey, 6)=202112 And IdCat_xPrv = 65 And IdCanal = 1 And IdSede = 4

Select * From ventas.DimRelGeneral2 Where IdCat_xPrv = 65 And IdCanal = 1 And IdSede = 4
Select * From ventas.DimRelGeneral Where IdCat_xPrv = 65 And IdCanal = 1 And IdSede = 4

select * from ventas.DimProveedores where codprv = 'PM00000027'

select * from ventas.Dim_Categorias_xProveedor where IdPrv =7
Select * 
-- Update a Set NomVendedor = 'YUCRA ROBLES, TANIA NADINE'
From ventas.DimRelGeneral2 a Where IdCat_xPrv = 370


Select * From ventas.DimRelGeneral Where IdCat_xPrv IN (53, 112)
Select * From ventas.DimRelGeneral2 Where IdCat_xPrv IN (53, 112)

Select Distinct IdVendedor From Planillas.Fact_Ventas 
Where IdCartera = 89 And LEft(FechaKey, 6)=202112


Select Distinct IdVen From Ventas.Fact_Cuotas 
Where IdCar = 89 And LEft(FechaKey, 6)=202112



Select * From Planillas.Fact_Ventas 
Where IdRelGeneral2 In (Select distinct IdRelGeneral2 
						From ventas.DimRelGeneral2 Where NomVendedor Like '%CURO HUANACO, BERTHA%')
And LEft(FechaKey, 6)=202112

CREATE Procedure [Ventas].[sp_Actualiza_Fact_Cuotas]
@pPeriodo Char(6) = Null
As

Begin
	-- Ventas.SP_Fact_Cuotas 202311
	-- Declare @pPeriodo Char(6) = 202311
	Drop Table If Exists #CommVendedor
	Drop Table If Exists #Cuotas
	Drop Table If Exists #Cuotasxxx
	Drop Table If Exists #tmpsupgrupo
	Drop Table If Exists #prvcatfam
	Drop Table If Exists #relfamcatgrupo
	Drop Table If Exists #CuotaFull
	Drop Table If Exists #Cartera
	Drop Table If Exists #Colaboradores
	Drop Table If Exists #XXXXX
	Drop Table If Exists #FormaPago
	Drop Table If Exists #relfamcatgrupo_xItem

	------Select * From #prvcatfam
	Declare @a Char(4) = Left(@pPeriodo, 4)
	Declare @m Char(4) = Right(@pPeriodo, 2)

	--Select Top 0 * Into #relfamcatgrupo
	--From srvsap.roma_productiva.reportes.relfamcatgrupo a 
	


	Select Distinct a.CodPrv, a.CodFam, a.CodCat, a.itemcode CodPro, b.name nomcat, b.name nomcat_corto
	Into #relfamcatgrupo_xItem
	From SrvSAP.dw.Reportes.item_unidadvolumenpeso a
	inner join srvsap.roma_productiva.dbo.[@RM_CATEGORIA_CUOTA] b on a.codcat = b.code
	Where a.CodCat Is Not Null

	Select Distinct CodPrv, CodCat, nomcat, nomcat_corto
	Into #relfamcatgrupo
	From #relfamcatgrupo_xItem
	--select * from #relfamcatgrupo where codprv = 'PM00000074'
	;With dtCatGrp As (Select  * 
					From #relfamcatgrupo )
	Select Distinct 
	codmesa Collate SQL_Latin1_General_CP1_CI_AS CodMesa, 
	codcar Collate SQL_Latin1_General_CP1_CI_AS CodCar, 
	codven, 
	a.codprv Collate SQL_Latin1_General_CP1_CI_AS CodPrv,
	Null codfam, cuota, codsup, 
	codsede Collate SQL_Latin1_General_CP1_CI_AS CodSede, 
	grupovnd, 
	b.codcat Collate SQL_Latin1_General_CP1_CI_AS CodCat, 
	b.nomcat, b.nomcat_corto, CobMeta, FactorCobertura, aa.code codjv
	Into #Cuotas
	-- Select *
	From srvsap.roma_productiva.reportes.mov_cuotas a
	Inner Join srvsap.roma_productiva.dbo.[@bks_supervisores] aa On aa.u_sedes like '%'+ a.codsede +'%' And u_tipo = 'J'
	Left Join dtCatGrp b On a.codprv = b.codprv and a.codgrupo = b.codcat
	Where periodo =  @pPeriodo And a.cuota > 0 And aa.u_bks_estatus='A'

	--select * From srvsap.roma_productiva.dbo.[@bks_supervisores] Where u_bks_estatus = 'A' and u_tipo = 'J'
	--Select * From #Cuotas WHERE CODCAT = 199
	
	
	--Select * From #Cuotas where codprv = 'PM00000074'
	--Select * From #CuotaFull
	-- Drop Table #CuotaFull
	;With dt As (Select *, Rank() Over(Partition By CodVen Order By CodCat) Ord	From #Cuotas Where CodPrv <> 'PM00000027' )
	Select *, Convert(Decimal(18, 5), 1.00 / Max(Ord) Over(Partition By CodVen)) Peso, 
	Convert(Decimal(18, 2), Null) CarteraIni
	Into #CuotaFull
	From dt
	
	;With dt As (Select *, Rank() Over(Partition By CodVen Order By CodCat) Ord	
					From #Cuotas Where CodPrv = 'PM00000027' And nomcat Not Like '%BODEG%')
	Insert Into #CuotaFull
	Select *, Convert(Decimal(18, 5), 0.4 / Max(Ord) Over(Partition By CodVen)) Peso, Null From dt
	Union All 
	Select *, 99 Ord, 0.6, Null From #Cuotas Where CodPrv = 'PM00000027' And nomcat Like '%BODEG%'

	-- Truncate Table Ventas.DimCarteras
	;With dt As (Select distinct CodCar From #Cuotas)
	Insert Into Ventas.DimCarteras (CodCartera, NomCartera)
	Select Distinct a.CodCar, b.name From dt a 
	Inner Join SrvSAP.Roma_Productiva.dbo.[@BKS_CARTERA] b On a.CodCar = b.Code Collate SQL_Latin1_General_CP1_CI_AS
	Where Not Exists (Select * From Ventas.DimCarteras c Where a.codcar= c.codcartera)
			
	Delete Ventas.Fact_Cuotas Where Convert(Char(6), Fecha, 112) = @pPeriodo
	
	Select Distinct CodMesa, Escala, Excedente, ExcedentePorc 
	Into #FormaPago
	From SrvSAP.Roma_Productiva.Reportes.vw_FormaPago 
	Where Tipo='VE' --And Periodo = @pPeriodo
	
	;With dt As (Select Distinct 	
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(e.IdPrv)), 3) + Right('000'+Ltrim(Str(cp.IdCat_xPrv)), 3) IdRelGeneral2, 
	IdSede, IdCan, IdCartera, e.IdPrv, IdCat_xPrv
	From #CuotaFull a	
	Inner Join Ventas.DimSedes s On a.codsede = s.CodSede
	Inner Join Ventas.DimCarteras c On a.codcar = c.CodCartera
	Inner Join Ventas.DimProveedores e On a.codprv = e.CodPrv
	Inner Join Ventas.DimCategorias cp 
		On a.codcat = cp.CodCat And e.IdPrv = cp.IdPrv
	Inner Join Ventas.DimCanales can On can.CodCan = a.grupovnd Collate SQL_Latin1_General_CP1_CI_AS)
	Insert Into ventas.DimRelGeneral2 (IdRelGeneral, IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv)
	Select * From dt a
	Where not Exists (Select * From ventas.DimRelGeneral2 b Where a.IdRelGeneral2=b.IdRelGeneral)
	/*
	;With dt As (Select Distinct 	
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdMesa)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(e.IdPrv)), 3) + Right('000'+Ltrim(Str(cp.IdCat_xPrv)), 3) +
	Right('0000'+Ltrim(Str(v.IdVen)), 4) IdRelGeneral, 
	IdSede, IdMesa, IdCan, IdCartera, e.IdPrv, IdCat_xPrv, IdVen
	From #CuotaFull a	
	Inner Join Ventas.DimSedes s On a.codsede = s.CodSede
	Inner Join Ventas.DimVendedores v On a.codven = v.CodVen
	Inner Join Ventas.DimMesas m On a.CodMesa = m.CodMesa
	Inner Join Ventas.DimCarteras c On a.codcar = c.CodCartera
	Inner Join Ventas.DimProveedores e On a.codprv = e.CodPrv
	Inner Join Ventas.DimCategorias cp 
		On a.codcat = cp.CodCat And e.IdPrv = cp.IdPrv
	Inner Join Ventas.DimCanales can On can.CodCan = a.grupovnd Collate SQL_Latin1_General_CP1_CI_AS)
	Insert Into ventas.DimRelGeneral (IdRelGeneral, IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVendedor)
	Select * From dt a
	Where not Exists (Select * From ventas.DimRelGeneral b Where a.IdRelGeneral=b.IdRelGeneral)
	*/


	
	--Alter Table Ventas.Fact_Cuotas Alter Column IdRelGeneral Varchar(20)
	
	Insert Into Ventas.Fact_Cuotas(Fecha, IdSede, IdMesa, IdCar, IdVen, IdPrv, Cuota, IdCat_xPrv, FechaKey, IdCanal, 
	Peso, BaseComisionable, TopeExcedentePorc, IdSupervisor, cobmeta, FactorCob_xLinea, IdJefe_dVenta, IdRelGeneral2, IdRelGeneral)
	Select Distinct Case When Convert(Char(6), Getdate(), 112) > @pPeriodo
	Then DateAdd(Day, -1, DateAdd(Month, 1, Cast(@pPeriodo+'01' As Date)))
	Else Cast(Getdate()-1 as Date) End, IdSede,
	IdMesa, IdCartera, IdVen, e.IdPrv, a.cuota, IdCat_xPrv, Convert(int, @pPeriodo+'01'), can.IdCan, a.Peso, 
	Escala, ExcedentePorc/100, sup.IdSup, cobmeta, a.FactorCobertura, jv.IdJV,	
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(e.IdPrv)), 3) + Right('000'+Ltrim(Str(cp.IdCat_xPrv)), 3) IdRelGeneral2,
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdMesa)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(e.IdPrv)), 3) + Right('000'+Ltrim(Str(cp.IdCat_xPrv)), 3) +
	Right('0000'+Ltrim(Str(d.IdVen)), 4) IdRelGeneral
	-- Select Count(*)
	-- Select *
	From #CuotaFull a	
	Inner Join Ventas.DimSedes s On a.codsede = s.CodSede
	Inner Join Ventas.DimMesas b On a.codmesa = b.CodMesa
	Inner Join Ventas.DimCarteras c On a.codcar = c.CodCartera
	Inner Join Ventas.DimVendedores d On a.codven = d.CodVen
	Inner Join Ventas.DimProveedores e On a.codprv = e.CodPrv
	Inner Join Ventas.DimCategorias cp 
		On a.codcat = cp.CodCat And e.IdPrv = cp.IdPrv --And a.codfam = cp.CodFam
	Inner Join Ventas.DimCanales can On can.CodCan = a.grupovnd Collate SQL_Latin1_General_CP1_CI_AS
	Inner Join Ventas.Dim_vw_Supervisores sup On a.codsup = sup.CodSup
	Inner Join Ventas.Dim_vw_Jefes_dVenta jv On a.codjv = jv.CodJV
	Inner Join #FormaPago aa On a.CodMesa = aa.codMesa Collate SQL_Latin1_General_CP1_CI_AS


	--select * from ventas.dimsedes

	-----------------------------------------------------------------------------------------------------------------------------
	--- Cartera Inicial
	-----------------------------------------------------------------------------------------------------------------------------
	
	Select * Into #Cartera	
	From SrvSAP.Roma_Productiva.Reportes.Registro_CarteraInicial
	Where periodo = @pPeriodo

	-- Drop Table #Cuotas
	Select Distinct CodSup, CodVen, Codprv, CodGrupo CodCat, CodMesa, CodSede, grupovnd CodCanal, aa.code CodJV
	Into #Cuotasxxx
	From SrvSAP.Roma_Productiva.Reportes.mov_cuotas a
	Inner Join srvsap.roma_productiva.dbo.[@bks_supervisores] aa On aa.u_sedes like '%'+ a.codsede +'%' And u_tipo = 'J'
	Where periodo = @pPeriodo And cuota > 0 And aa.u_bks_estatus='A'

		
	Delete Ventas.Fact_CarteraInicial_xVendedor Where Left(FechaKey, 6) = @pPeriodo
	

	--Select * From #Cartera

	;With dt As (Select Distinct periodo, a.*, b.CodCar, b.CodCli, b.coddom
				From #Cuotasxxx a, #Cartera b
				Where a.codven = b.codven And a.CodSede = b.CodSede 
				And a.CodMesa = b.CodMesa And a.CodCanal = b.CodCanal)
	Select Distinct Ltrim(Str(Periodo)) + '01' FechaKey, IdMesa, IdSede, IdVen, IdCartera, CodCli, 1 Qtd, Cast(codcanal As Smallint) IdCanal,
	prv.IdPrv, cat.IdCat_xPrv, IdSup, jv.IdJV,
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(prv.IdPrv)), 3) + Right('000'+Ltrim(Str(cat.IdCat_xPrv)), 3) IdRelGeneral2,
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdMesa)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(prv.IdPrv)), 3) + Right('000'+Ltrim(Str(cat.IdCat_xPrv)), 3) +
	Right('0000'+Ltrim(Str(aa.IdVen)), 4) IdRelGeneral, coddom
	Into #XXXXX
	From dt a
	Inner Join Ventas.DimVendedores aa On a.codven = aa.CodVen
	Inner Join Ventas.DimMesas b On a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = b.CodMesa
	Inner Join Ventas.DimCanales can On can.CodCan Collate SQL_Latin1_General_CP1_CI_AS = a.CodCanal
	Inner Join Ventas.DimSedes c On a.codsede Collate SQL_Latin1_General_CP1_CI_AS = c.CodSede
	Inner Join Ventas.DimCarteras car On a.codcar Collate SQL_Latin1_General_CP1_CI_AS = car.CodCartera
	--Inner Join Ventas.DimClientes cli On a.CodCli Collate SQL_Latin1_General_CP1_CI_AS = cli.CodCli
	Inner Join Ventas.DimProveedores prv on prv.CodPrv = a.CodPrv Collate SQL_Latin1_General_CP1_CI_AS
	Inner Join Ventas.Dim_vw_Supervisores sup On sup.CodSup = a.codsup
	Inner Join Ventas.Dim_vw_Jefes_dVenta jv On jv.CodJV = a.CodJV
	Inner Join Ventas.DimCategorias cat On cat.IdPrv = prv.IdPrv 
	And cat.CodCat = a.CodCat Collate SQL_Latin1_General_CP1_CI_AS

	--Select * From #XXXXX



	--Alter Table Ventas.Fact_CarteraInicial_xVendedor Alter Column CodDom Varchar(3) Not Null
	--Select Top 100 * From #XXXXX

	Insert Into ventas.DimRelGeneral2(IdRelGeneral, IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv, NomVendedor)
	Select Distinct IdRelGeneral2, IdSede, IdCanal, IdCartera, IdPrv, IdCat_xPrv, Null NomVendedor
	From #XXXXX a
	Where not Exists (Select * From ventas.DimRelGeneral2 b Where a.IdRelGeneral2 = b.IdRelGeneral)
	/*
	Insert Into ventas.DimRelGeneral(IdRelGeneral, IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVendedor, NomVendedor)
	Select Distinct IdRelGeneral, IdSede, IdMesa, IdCanal, IdCartera, IdPrv, IdCat_xPrv, IdVen, Null NomVendedor
	-- Select Top 10000 *
	From #XXXXX a
	Where not Exists (Select * From ventas.DimRelGeneral b Where a.IdRelGeneral = b.IdRelGeneral)
	*/

	Insert Into Ventas.Fact_CarteraInicial_xVendedor(FechaKey, IdMesa, IdSede, IdVen, IdCartera, 
	CodCli, CarteraInicial, Idcanal, IdProveedor, IdCat_xPrv, IdSupervisor, IdJefe_dVenta, IdRelGeneral2, IdRelGeneral, CodDom)
	Select * From #XXXXX

	update ventas.Fact_CarteraInicial_xVendedor
		set periodo = @pPeriodo
	where left(fechakey,6) = @pPeriodo

	
End
GO


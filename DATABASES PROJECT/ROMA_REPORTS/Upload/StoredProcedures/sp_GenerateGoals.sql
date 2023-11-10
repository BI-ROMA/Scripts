CREATE procedure [Upload].[sp_GenerateGoals] @Period Char(6)

as
BEGIN
	--Declare @Period Char(6) = 202311 

	Drop Table If Exists #Goals
	Drop Table If Exists #Ven
	Drop Table If Exists #CuotasNew
	
	Drop Table If Exists #XrelfamcatgrupoX
	Drop Table If Exists #Cuotas_Full
	Drop Table If Exists #Fact_Ventas
	Drop Table If Exists #Result
	Drop Table If Exists #FactorCob
	Drop Table If Exists #TeamCategory
	Drop Table If Exists #TmpFact_Ventas
	Drop Table If Exists #CarteraInicial
	Drop Table If Exists #tmpBase
	

	

	delete from [Upload].[CoverageFactorFormat] where Period = @Period


	Insert Into [Upload].[CoverageFactorFormat]
		(Period, SupplierCode, SupplierName, CategoryCode, CategoryName, Origin, FactorCov)
		Select @Period Period, SupplierCode, SupplierName, CategoryCode, CategoryName, 'Retail', Retail
		From [Upload].[CoverageFactor] Where Retail > 0
		Union All 
		Select @Period Period, SupplierCode, SupplierName, CategoryCode, CategoryName, 'WholeSale', WholeSale
		From [Upload].[CoverageFactor] Where Wholesale > 0


	Create Table #Goals (SupplierCode Varchar(20), CategoryCode Char(3), ChannelCode Char(2), TerritoryCode Char(2), Goal Decimal(18,2))

	Insert Into #Goals
	Select SupplierCode, CategoryCode, ChannelCode, 'CN', CÑ From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'CH', CH From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'PS', PS From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'IC', IC From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'NZ', NZ From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'AY', AY From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'AP', AP From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'AV', AV From [Upload].[CommercialGoalsGeneral] 
	Union All
	Select SupplierCode, CategoryCode, ChannelCode , 'AN', AN From [Upload].[CommercialGoalsGeneral] 



	-- Drop Table #TeamCategory
	Select Distinct a.TeamCode, a.categorycode, a.suppliercode, b.IdMesa, d.IdPrv, c.IdCat_xPrv 
	Into #TeamCategory
	From Upload.TeamCategory a
	Inner Join ROMA_DATAMART.ventas.DimMesas b On a.TeamCode= b.CodMesa
	Inner Join ROMA_DATAMART.ventas.DimCategorias c On a.CategoryCode = c.CodCat
	inner join ROMA_DATAMART.Ventas.DimProveedores d on a.SupplierCode = d.CodPrv
	--Select * From #TeamCategory 
	
	Select 
		distinct idven, CodVen, NomVen, CodCar, CodMesa, 
		CodSede, CodSup, CodCan, Estado
	Into #Ven 
	From ROMA_DATAMART.Ventas.DimVendedores 
	where Estado = 'A'


	
	SET IDENTITY_INSERT #Ven ON;
	-- VENDEDOR : MAYORISTA MINORISTA  
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, '01', 'A' 
	From #Ven Where CodCar = 'MAY06'
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'AP', CodSup, '02' ,'A'
	From #Ven Where CodCar = 'TAY05'
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'AV', CodSup, '01', 'A'
	From #Ven Where CodCar = 'TAY06'
	-- SUPERVISOR : MINIMAYORISTA
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'AN', CodSup, '07', 'A'
	From #Ven Where CodCar = 'HAY07'
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'NZ', CodSup, '07', 'A' 
	From #Ven Where CodCar = 'HIC07'
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'PS', CodSup, '07', 'A' 
	From #Ven Where CodCar = 'HCH05'
	Insert Into #Ven (idven, CodVen, NomVen, CodCar, CodMesa, CodSede, CodSup, CodCan, Estado)
	Select Distinct IdVen, CodVen, NomVen, CodCar, CodMesa, 'CN', CodSup, '07', 'A'
	From #Ven Where CodCar = 'HCH05'
	SET IDENTITY_INSERT #Ven OFF;
	--select * from #ven where codcar = 'HCH05'


	update #Goals set CategoryCode= 201 where CategoryCode= '048'



	Select Distinct a.*, Codmesa, CodVen, CodCar
	Into #CuotasNew
	From #Goals a 
	Inner Join (Select Distinct CodVen, CodMesa, CodSede, CodCan, CodCar From #Ven) b 
	On a.TerritoryCode = b.CodSede Collate SQL_Latin1_General_CP1_CI_AS
	And a.ChannelCode = b.codcan Collate SQL_Latin1_General_CP1_CI_AS 
	Where Goal > 0



	Select Distinct a.*, b.IdPrv, cm.IdCat_xPrv, IdSede, IdCan, cm.IdMesa
	Into #Cuotas_Full
	From #CuotasNew a
	Inner Join ROMA_DATAMART.Ventas.DimProveedores b On a.SupplierCode = b.CodPrv
	Inner Join ROMA_DATAMART.Ventas.DimCategorias c On b.IdPrv = c.IdPrv And a.CategoryCode = c.CodCat
	Inner Join ROMA_DATAMART.Ventas.DimCanales d On a.ChannelCode = d.CodCan Collate SQL_Latin1_General_CP1_CI_AS
	Inner Join ROMA_DATAMART.Ventas.DimSedes e On a.TerritoryCode = e.CodSede
	Inner Join ROMA_DATAMART.Ventas.DimMesas f On a.CodMesa Collate SQL_Latin1_General_CP1_CI_AS = f.CodMesa
	Inner Join #TeamCategory cm On a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = cm.TeamCode
	And a.SupplierCode Collate SQL_Latin1_General_CP1_CI_AS = cm.SupplierCode 
	And a.CategoryCode Collate SQL_Latin1_General_CP1_CI_AS = cm.CategoryCode
	Where Goal > 0 
	--select * from #cuotasnew
	--select * from #cuotas_full

	;With dt As (Select a.Period, FactorCov, a.Origin, a.CategoryCode, a.SupplierCode 
				From [Upload].[CoverageFactorFormat]  a
				Where Period = @Period And FactorCov > 0)
	Select SupplierCode, CategoryCode, 
	Max(Case When Origin = 'Retail' Then FactorCov Else 0 End) fMin,
	Max(Case When Origin = 'WholeSale' Then FactorCov Else 0 End) fMay
	Into #FactorCob
	From dt
	Group By SupplierCode, CategoryCode
	


	Select Distinct a.*
	Into #Fact_Ventas
	From ROMA_DATAMART.Planillas.Fact_Ventas a
	Inner Join ROMA_DATAMART.Ventas.DimClientes b On a.IdCliente = b.IdCli
	Where Left(FechaKey, 6) >= Convert(Char(6), DateAdd(Month,-6, Cast(@Period+'01' As Date)), 112)
			and left(FechaKey,6) < Convert(Char(6),  GETDATE(), 112)
			And Left(FechaKey, 6) <> @Period 
			And b.TiCliente <> 'EM' And IdCartera <> 0



	;With dtVen As (Select distinct a.IdVen, d.IdCartera, a.CodCar, c.IdCan, a.CodCan From #Ven a 
				Inner Join ROMA_DATAMART.ventas.DimCanales c On a.CodCan = c.CodCan
				inner join ROMA_DATAMART.Ventas.DimCarteras d on a.CodCar = d.CodCartera)
	Select a.* 
	Into #TmpFact_Ventas
	From #Fact_Ventas a
	Inner Join dtVen b On a.IdVendedor = b.IdVen And a.IdCanal = b.IdCan
				


	Truncate Table #Fact_Ventas
	Insert Into #Fact_Ventas
	Select * From #TmpFact_Ventas



	Update #Fact_Ventas Set IdCanal = 7 Where IdCanal In (8,9)



	Drop Table If Exists #CarteraInicialSAP
	Select * 
	Into #CarteraInicialSAP
	From SrvSAP.Roma_Productiva.Reportes.Registro_CarteraInicial Where Periodo = @Period



	Drop Table If Exists #CarteraTotal
	;With dt As (Select Distinct a.Periodo, a.codmesa, a.codsede, a.codcanal, b.SupplierCode, b.CategoryCode, a.codcar
				From #CarteraInicialSAP a
				Inner Join #Cuotas_Full b On a.codsede collate SQL_Latin1_General_CP850_CI_AS = b.TerritoryCode 
				And a.codcanal Collate SQL_Latin1_General_CP850_CI_AS = b.ChannelCode 
				And a.codmesa Collate SQL_Latin1_General_CP850_CI_AS = b.codmesa and a.codcar Collate SQL_Latin1_General_CP850_CI_AS = b.CodCar
				Where Goal > 0)
	Select a.*, b.IdMesa, c.IdSede, d.IdCan IdCanal, e.IdCartera, e.IdCartera CodCarAnt, p.IdPrv, cp.IdCat_xPrv
	Into #CarteraTotal
	From dt a
	Inner Join ROMA_DATAMART.ventas.DimMesas b On a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = b.CodMesa
	Inner Join ROMA_DATAMART.ventas.DimProveedores p On a.SupplierCode Collate SQL_Latin1_General_CP1_CI_AS = p.CodPrv
	Inner Join ROMA_DATAMART.ventas.DimCategorias cp On p.IdPrv = cp.IdPrv and a.CategoryCode Collate SQL_Latin1_General_CP1_CI_AS = cp.CodCat
	Inner Join ROMA_DATAMART.ventas.DimSedes c On a.codsede Collate SQL_Latin1_General_CP1_CI_AS = c.CodSede
	Inner Join ROMA_DATAMART.ventas.DimCanales d On a.codcanal Collate SQL_Latin1_General_CP1_CI_AS = d.CodCan
	Inner Join ROMA_DATAMART.ventas.DimCarteras e On a.codcar Collate SQL_Latin1_General_CP1_CI_AS = e.CodCartera
	Drop Table If Exists #tmpBase_Prev
	Select Distinct a.*, IdCartera,IdCartera IdCarteraAnt , 0 OrdenVta, Convert(Decimal(18, 0), 0.0) VtaPrm, 0 Fl0, Convert(Decimal(18, 2), 0.00) Peso, 
	Convert(Decimal(18, 0), 0.0) Cuota_xLinea, 
	Convert(Decimal(18, 0), 0.0) VtaMin, Convert(Decimal(18, 0), 0.0) VtaMax,
	Convert(Decimal(18, 0), 0.0) VtaMdn
	Into #tmpBase_Prev
	From #Cuotas_Full a
	Inner Join #CarteraTotal b On a.IdPrv = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv
	And a.IdSede = b.IdSede And a.IdCan = b.IdCanal	And a.idMesa = b.IdMesa And a.CodCar collate SQL_Latin1_General_CP1_CI_AS = b.codcar
	--select * from #tmpbase_prev


	;With dt As (Select distinct * From #TeamCategory)
	Select distinct a.*, Cast(0.00 As Decimal(18, 2)) VtaPrm_Tot
	Into #tmpBase
	-- Select *
	From #tmpBase_Prev a
	Inner Join ROMA_DATAMART.ventas.DimMesas x On a.IdMesa = x.IdMesa		
	Inner Join dt b On a.SupplierCode = b.SupplierCode Collate SQL_Latin1_General_CP1_CI_AS			
	And x.CodMesa = b.TeamCode Collate SQL_Latin1_General_CP1_CI_AS And a.idmesa = b.idmesa
	And a.CategoryCode = b.CategoryCode Collate SQL_Latin1_General_CP1_CI_AS



	;With dt As (Select IdSede, IdMesa, IdCanal, IdProveedor, IdCat_xPrv, IdCartera,
				Convert(Decimal(18,0), Avg(TotalIGV)) TotalIGV_AVG,
				Convert(Decimal(18,0), Min(TotalIGV)) TotalIGV_Min,
				Convert(Decimal(18,0), Max(TotalIGV)) TotalIGV_Max				
				From (Select Left(FechaKey, 6) Period, IdSede, IdMesa, IdCanal, IdProveedor, IdCat_xPrv, IdCartera,
						Sum(TotalIGV) TotalIGV
						From #Fact_Ventas 
						Group By Left(FechaKey, 6), IdSede, IdMesa, IdCanal, IdProveedor, IdCat_xPrv, IdCartera
						Having Sum(TotalIGV) > 0) dt
				Group By IdSede, IdMesa, IdCanal, IdProveedor, IdCat_xPrv, IdCartera)
	Update a Set VtaPrm = TotalIGV_AVG, VtaMin = TotalIGV_Min, VtaMax = TotalIGV_Max
	From #tmpBase a
	Inner Join dt b On a.IdSede = b.IdSede And a.IdMesa = b.IdMesa And a.IdCan = b.IdCanal
	And a.IdPrv = b.IdProveedor And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCartera = b.IdCartera
	;With dt As (Select SupplierCode, TerritoryCode, IdMesa, ChannelCode, CategoryCode, Min(VtaPrm) VtaPrm_Min 
				From #tmpBase 
				Where VtaPrm > 0
				Group By SupplierCode, TerritoryCode, IdMesa, ChannelCode, CategoryCode)	
	Update a Set VtaPrm = VtaPrm_Min, fl0 = 1
	From #tmpBase a
	Inner Join dt b On a.SupplierCode = b.SupplierCode And a.TerritoryCode = b.TerritoryCode And a.IdMesa = b.IdMesa 
	And a.ChannelCode = b.ChannelCode And a.CategoryCode = b.CategoryCode 
	Where VtaPrm = 0
	   	 
	;With dt As (Select SupplierCode, IdMesa, ChannelCode, CategoryCode, Min(VtaPrm) VtaPrm_Min 
				From #tmpBase 
				Where VtaPrm > 0
				Group By SupplierCode, IdMesa, ChannelCode, CategoryCode)	
	Update a Set VtaPrm = VtaPrm_Min, fl0 = 2
	From #tmpBase a
	Inner Join dt b On a.SupplierCode = b.SupplierCode And a.IdMesa = b.IdMesa
	And a.ChannelCode = b.ChannelCode And a.CategoryCode = b.CategoryCode 
	Where VtaPrm = 0
	   
	;With dt As (Select SupplierCode, TerritoryCode, ChannelCode, CategoryCode, Min(VtaPrm) VtaPrm_Min 
				From #tmpBase 
				Where VtaPrm > 0
				Group By SupplierCode, TerritoryCode, ChannelCode, CategoryCode)	
	Update a Set VtaPrm = VtaPrm_Min, fl0 = 3
	From #tmpBase a
	Inner Join dt b On a.SupplierCode = b.SupplierCode And a.TerritoryCode = b.TerritoryCode
	And a.ChannelCode = b.ChannelCode And a.CategoryCode = b.CategoryCode 
	Where VtaPrm = 0

	;With dt As (Select SupplierCode, b.Zona, ChannelCode, CategoryCode, Min(VtaPrm) VtaPrm_Min 
				From #tmpBase a
				Inner Join ROMA_DATAMART.ventas.DimSedes b On a.IdSede = b.IdSede
				Where VtaPrm > 0
				Group By SupplierCode, Zona, ChannelCode, CategoryCode)		
	Update a Set VtaPrm = VtaPrm_Min, fl0 = 4
	From #tmpBase a
	Inner Join ROMA_DATAMART.ventas.DimSedes x On a.IdSede = x.IdSede
	Inner Join dt b On a.SupplierCode = b.SupplierCode And x.Zona = b.Zona
	And a.ChannelCode = b.ChannelCode And a.CategoryCode = b.CategoryCode 
	Where VtaPrm = 0



	Update #tmpBase Set VtaPrm = 1, Fl0 = 7 Where VtaPrm = 0

	;With dt As (Select SupplierCode, TerritoryCode, CategoryCode, Min(VtaPrm) VtaPrm_Min, Avg(VtaPrm) VtaPrm_Avg  
				From #tmpBase 
				Where VtaPrm > 0
				Group By SupplierCode, TerritoryCode, CategoryCode)	
	Update a Set VtaPrm = VtaPrm_Min, fl0 = 6
	From #tmpBase a
	Inner Join dt b On a.SupplierCode = b.SupplierCode And a.TerritoryCode = b.TerritoryCode
	And a.CategoryCode = b.CategoryCode 
	Where CodMesa = '029'








	;With dt As (Select IdSede, IdCan, IdPrv, IdCat_xPrv, IdCartera, VtaPrm, 
				Sum(VtaPrm) Over(Partition By IdSede, IdCan, IdPrv, IdCat_xPrv) VtaPrm_Tot,
				ROW_NUMBER() Over(Partition By IdSede, IdCan, IdPrv, IdCat_xPrv Order By VtaPrm) Orden
				From #tmpBase)
	Update a Set Peso = Convert(Decimal(18, 2), 1.00*a.VtaPrm/b.VtaPrm_Tot), OrdenVta = b.Orden, VtaPrm_Tot=b.VtaPrm_Tot
	From #tmpBase a
	Inner Join dt b On a.IdSede = b.IdSede And a.IdCan = b.IdCan 
	And a.IdPrv = b.IdPrv And a.IdCat_xPrv = b.IdCat_xPrv And a.IdCarteraAnt = b.IdCartera


	update #tmpBase set peso = 0.01 where CategoryCode in(35,36,37,38,150) and peso <= 0
	

	;With dt As
	(Select *, peso - 1 Dif
			From (Select IdSede, IdPrv, IdCan, IdCat_xPrv, Sum(Peso) Peso, Max(OrdenVta) OrdenMax
			From #tmpBase 
			Group By IdSede, IdPrv, IdCan, IdCat_xPrv
			Having Sum(Peso) > 1.00) dt)
	Update a Set Peso = a.Peso - Dif
	From #tmpBase a
	Inner Join dt b On a.IdSede = b.IdSede And a.IdPrv = b.IdPrv And a.IdCan = b.IdCan 
	And a.IdCat_xPrv = b.IdCat_xPrv And a.OrdenVta = b.OrdenMax
	


	;With dt As
	(Select *, 1 - peso Dif
		From (Select IdSede, IdPrv, IdCan, IdCat_xPrv, Sum(Peso) Peso, Min(OrdenVta) OrdenMin
		From #tmpBase
		Group By IdSede, IdPrv, IdCan, IdCat_xPrv
		Having Sum(Peso) < 1.00) dt)
	Update a Set Peso = a.Peso + Dif
	From #tmpBase a
	Inner Join dt b On a.IdSede = b.IdSede And a.IdPrv = b.IdPrv And a.IdCan = b.IdCan 
	And a.IdCat_xPrv = b.IdCat_xPrv And a.OrdenVta = b.OrdenMin

	
	
	Update #tmpBase Set Cuota_xLinea = Goal*Peso
	
	Select a.*, c.codcar codcartera, c.NomVen NomVen, p.NomPrvAbr, c.CodSup
	Into #Result
	From #tmpBase a
	Inner Join ROMA_DATAMART.Ventas.DimProveedores p On a.IdPrv = p.IdPrv
	Inner Join (select distinct codven, NomVen, CodSup, codcar, codmesa, Estado from #ven) c
		On a.codcar = c.CodCar Collate SQL_Latin1_General_CP1_CI_AS 
		And a.CodMesa = c.CodMesa Collate SQL_Latin1_General_CP1_CI_AS 
		and a.CodVen = c.CodVen
	Where c.Estado = 'A'



	Truncate Table Upload.tmp_mov_cuotas
	Insert Into Upload.tmp_mov_cuotas
	Select Distinct @Period Period, TerritoryCode, codven, nomven, SupplierCode, NomPrvAbr, Cuota_xLinea cuota, 
	Right('000'+Ltrim(CategoryCode), 3) codgrupo, 
	0 cuotamay, Peso FactorCuota, Goal, Null, ChannelCode, CodMesa, CodSup, CodCar
	From #Result dt
	Where Cuota_xLinea>0 
	





	--select * from Temp.tmp_mov_cuotas where codven = 1955
	update Upload.tmp_mov_cuotas set CodSup = '0076' where codcar= 'TAY05' and codprv in ('PM00000066','PM00000091')
	--ACTUALIZAR EL FACTOR DE COBERTURA DE HISPANICA A REQUERIMIENTO DE COMERCIAL
	Update a Set FactorCobertura = (Case When a.CodPrv = 'PM00000066' And codmesa In ('023','024','029','030') Then 0.25 Else 1 End)*(Case When grupovnd = '01' Then b.fMin Else b.fMay End)	
	From Upload.tmp_mov_cuotas a
	Inner Join #FactorCob b On a.codprv = b.SupplierCode And a.codgrupo = b.CategoryCode




/*************************************** FIN GENERA CUOTA *************************************/
	Insert Into SrvSAP.Roma_Productiva.reportes.tmp_mov_cuotas
	Select Periodo, sede, codven, nomven, codprv, nomprv, cuota, codgrupo, cuotamay, FactorCuota FactorVenta, 
	CuotaTot Cuota_dVtaTot, FactorCobertura, GrupoVnd, CodSup, codmesa, CodCar
	--Select *
	From Upload.tmp_mov_cuotas

	Select * From SrvSAP.Roma_Productiva.reportes.tmp_mov_cuotas	
	/*

		Select codprv, sum(cuota) From Upload.tmp_mov_cuotas group by codprv order by 1
		Select sum(cuota) From Upload.tmp_mov_cuotas group by nomprv order by 1
		Select sum(cuota) From Upload.tmp_mov_cuotas where codven = 1593
	*/
/**********************************************************************************************/
END

GO


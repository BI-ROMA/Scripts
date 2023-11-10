CREATE Procedure [Reports].[sp_ReportCoverageCategory]
@Period Char(6),
@UserName VarChar(50),
@Day Smallint
As
Begin

	-- Replace(User!UserID,"DSROMASAC\","")
	-- Ventas.SP_Reporte_dCobertura_xCategoria 202105, 'c_altamirano', 5
	Set NoCount On

	-- Declare @Period Char(6)=202206, @UserName VarChar(50)='r_quispe',	@Day Smallint = 0
	-- Declare @Period Char(6)=202310, @UserName VarChar(50)='k_alfaro',	@Day Smallint = 0

	--Select * 
	---- Update a Set u_login = 'e_graziani'
	--From Ventas.DimVendedores a Where CodVen = 749

	If @UserName In ('g_lopez', 'e_rodriguez', 'u_pruebas')
	Begin
		Set @UserName = 'l_espinoza'
	End
	
	Drop Table If Exists #Data
	Drop Table If Exists #Result
	Drop Table If Exists #Colores
	Drop Table If Exists #OrdenCat
	Drop Table If Exists #ResultFinal
	Drop Table If Exists #Cli
	Drop Table If Exists #Cat_Car
	Drop Table If Exists #Cuo
	Drop Table If Exists #Resultados
	
	Create Table #Colores (IdColor Smallint, Color Varchar(100), ColorFuente Varchar(100))
	Insert Into #Colores Values (1, 'Green', 'White')
	Insert Into #Colores Values (2, 'Red', 'White')
	Insert Into #Colores Values (3, 'Yellow', 'Black')
	Insert Into #Colores Values (4, 'PaleTurquoise', 'Black')
	Insert Into #Colores Values (5, 'Orange', 'Black')
	Insert Into #Colores Values (6, 'SlateBlue', 'White')
	Insert Into #Colores Values (7, 'Tomato', 'Black')
	Insert Into #Colores Values (8, 'LightBlue', 'Black')
	Insert Into #Colores Values (9, 'CornflowerBlue', 'Black')
	Insert Into #Colores Values (10, 'Silver', 'Black')
	Insert Into #Colores Values (11, 'Orange', 'Black')
	Insert Into #Colores Values (12, 'Gold', 'Black')
	Insert Into #Colores Values (13, 'Aqua', 'Black')
	Insert Into #Colores Values (14, 'PaleTurquoise', 'Black')
	Insert Into #Colores Values (15, 'Orange', 'Black')
	Insert Into #Colores Values (16, 'SlateBlue', 'Black')
	Insert Into #Colores Values (17, 'Tomato', 'Black')
		
	Declare @CodVen Char(5),
			@OrdenCli Smallint, 
			@CodCar Varchar(15)

	Select @CodVen = SlpCode From SrvSAP.roma_productiva.dbo.OSLP Where u_username = @UserName	
	Select @CodCar=codcar From srvsap.roma_productiva.reportes.mov_cuotas Where Periodo = @Period And CodVen = @CodVen

	Select codven, nomven, codcar, CodPrv, nomprv, CodGrupo CodCat, codmesa, Sum(cuota) Cuota
	Into #Cuo
	From srvsap.roma_productiva.reportes.mov_cuotas 
	Where Periodo = @Period And CodVen = @CodVen And Cuota>0
	Group BY codven, nomven, codcar, CodPrv, nomprv, CodGrupo, codmesa
	
	;With 
	dt As (Select * From #Cuo),
	dt1 As (Select codven, nomven, Convert(Varchar(100), codprv) codprv, nomprv, CodCat, codcar, Sum(Cuota) Cuota From dt Group By codven, nomven, codprv, nomprv, CodCat, codcar),
	dtprv As (Select codprv, Sum(cuota) Cuota
			From srvsap.roma_productiva.reportes.mov_cuotas 
			Where Periodo = @Period And CodVen = @CodVen And Cuota>0
			Group BY codprv),
		dtprvord as (Select *, ROW_NUMBER() Over(Order By Cuota Desc) OrdenPrv From dtprv)
	Select a.*, ROW_NUMBER() Over(Order By ordenprv, a.Cuota Desc) OrdenCat, OrdenPrv, c.NomCat
	Into #Cat_Car
	From dt1 a
	Inner Join dtprvord b On a.codprv = b.codprv
	Inner Join (Select Distinct a.CodCat, a.NomCat, b.codprv, b.NomPrvAbr From ROMA_DATAMART.ventas.DimCategorias a inner join ROMA_DATAMART.Ventas.DimProveedores b on a.IdPrv = b.IdPrv) c On a.CodCat Collate SQL_Latin1_General_CP1_CI_AS = c.CodCat
	and a.codprv Collate SQL_Latin1_General_CP1_CI_AS = c.codprv
	-- Drop Table #Cli
	Select Distinct u_bkp_cliente CodCli, U_BKP_CODDOM CodDom, cli.IdCli, TiCliente, NomCli,cli.Direccion, U_BKP_CODMESA, U_BKP_CODDIA
	Into #Cli
	From srvsap.roma_productiva.dbo.[@BKS_CLIENTE_MESA] a
	Inner Join ROMA_DATAMART.Ventas.DimClientes cli On a.u_bkp_cliente Collate SQL_Latin1_General_CP1_CI_AS = cli.CodCli
	Inner Join (Select Distinct CodCar, CodMesa From #Cuo) x On x.codcar = U_BKP_CODVEN And x.codmesa = U_BKP_CODMESA 
	Where U_BKP_ESTADO = 'A' And U_BKP_CODDIA Is Not Null
	


	--parada
	--Select * From #Cli Order By U_BKP_CODDIA

	If @Day != '0'
	Begin
		Truncate Table #Cli
		Insert Into #Cli
		Select Distinct u_bkp_cliente CodCli, U_BKP_CODDOM CodDom, cli.IdCli, TiCliente, NomCli,cli.Direccion, U_BKP_CODMESA, U_BKP_CODDIA
		From srvsap.roma_productiva.dbo.[@BKS_CLIENTE_MESA] a
		Inner Join ROMA_DATAMART.Ventas.DimClientes cli On a.u_bkp_cliente Collate SQL_Latin1_General_CP1_CI_AS = cli.CodCli
		Inner Join (Select Distinct CodCar, CodMesa From #Cuo) x On x.codcar = U_BKP_CODVEN And x.codmesa = U_BKP_CODMESA 
		Where U_BKP_ESTADO = 'A' And U_BKP_CODDIA Like '%'+ Ltrim(Str(@Day))+'%' 
	End
	
	Select * Into #Resultados From #Cat_Car, #Cli

	--Select * From #Resultados	
	-- Drop Table #data
	;With dt As (Select a.*, 
			CodVen, NomVen, CodPro, prv.CodPrv/*, CodProm*/, doc.TiDocumento, 
			cli.CodCli, cli.CodDom, cli.TiCliente, cli.NomCli,cli.Direccion, c.NombreDiaAbr, b.CodCat, b.NomCat, prv.NomPrvAbr, car.CodCartera
			-- Select *
			From ROMA_DATAMART.Planillas.Fact_Ventas a
			Inner Join ROMA_DATAMART.Ventas.DimCarteras car On a.IdCartera = car.IdCartera
			Inner Join ROMA_DATAMART.ventas.DimDocumentos doc On a.IdDocumento = doc.IdDoc
			Inner Join ROMA_DATAMART.Ventas.DimCategorias b On a.IdCat_xPrv = b.IdCat_xPrv
			Inner Join ROMA_DATAMART.Ventas.DimProductos prd On a.IdProducto = prd.IdPro
			Inner join ROMA_DATAMART.ventas.DimProveedores prv on a.IdProveedor = prv.IdPrv
			Inner Join ROMA_DATAMART.Ventas.DimVendedores ve On a.IdVendedor = ve.IdVen
			Inner Join ROMA_DATAMART.Ventas.DimFechas c On a.FechaKey = c.FechaKey	
			Inner Join #Cli cli On a.IdCliente = cli.IdCli
			--Inner Join Ventas.DimClientes cli On a.IdCliente = cli.IdCli
			--Inner Join Ventas.DimPromociones prom On prom.IdPromocion = a.IdPromocion
			Where NuNombreMes = @Period -- And c.Dia < Day(Getdate())	
			And CodVen = @CodVen) 
	Select CodCli, CodDom, CodPrv, CodCat, NomPrvAbr, NomCat, NomVen, CodVen, NomCli, Direccion, Sum(TotalIgv) TotalIgv, 999 OrdenCli, CodCartera
	Into #data
	From dt
	Group By CodCli, CodDom, CodPrv, CodCat, NomPrvAbr, NomCat, NomVen, CodVen, NomCli, Direccion, CodCartera
	Having Sum(TotalIgv) > 0

	;With 
	dt As (Select CodCli, CodDom , Sum(TotalIgv) TotalIgv From #data Group By CodCli, CodDom),
	dt1 As (Select *, ROW_NUMBER() Over(Order By TotalIgv) OrdenCli From dt)
	-- Select * 
	Update a Set OrdenCli = b.OrdenCli
	From #data a
	Inner Join dt1 b On a.CodCli = b.CodCli And a.CodDom = b.CodDom
	
	-- Drop Table #Result
	;With xdata As (Select OrdenCli, CodCli, CodDom, NomCli, Direccion, CodCat, CodPrv, Sum(TotalIgv) TotalIgv
				From #data
				Group By OrdenCli, CodCli, CodDom, NomCli, CodCat,Direccion, CodPrv, NomCat, NomPrvAbr)
	Select a.CodVen, a.NomVen, NomCat, nomprv NomPrvAbr, a.CodCli, a.CodDom, a.NomCli, a.Direccion, a.CodPrv, a.CodCat, TotalIgv, OrdenCat, OrdenPrv, OrdenCli, U_BKP_CODDIA
	Into #Result
	From #Resultados a
	Left Outer Join xdata b 
	On a.CodCat = b.CodCat Collate SQL_Latin1_General_CP1_CI_AS	
		And a.CodPrv = b.codprv Collate SQL_Latin1_General_CP1_CI_AS
		And a.CodCli = b.CodCli Collate SQL_Latin1_General_CP1_CI_AS
		And a.CodDom = b.CodDom Collate SQL_Latin1_General_CP1_CI_AS

	--Select * From #Result
	;With dt As (Select distinct CodCli, CodDom, OrdenCli From #data Where OrdenCli > 0)
	--Select * 
	Update a Set OrdenCli = b.OrdenCli
	From #Result a
	Inner Join dt b On a.CodCli = b.CodCli And a.CodDom = b.CodDom
				
	-- Drop Table #ResultFinal
	;With dt As (Select Distinct NomCli, Direccion, CodDom From #result),
	dt1 As (Select ROW_NUMBER() Over(Order By NomCli) OrdenCli, CodDom,Direccion, NomCli From dt),
	dtMaxCat As (Select Count(Distinct CodCat) MaxCat From #result),
	dtMaxCli As (Select Count(Distinct NomCli) MaxCli From #result),
	dtCat As (Select Distinct CodCat From #result)
	Select a.*, MaxCat, 1 Flg, a.CodCat CodCatx
	Into #ResultFinal
	From #Result a
	Inner Join dtMaxCat x On 1=1
	Inner Join dt1 b On a.NomCli = b.NomCli And a.CodDom = b.CodDom

	Update a Set NomPrvAbr = b.NomPrvAbr
	From #ResultFinal a
	Inner Join ROMA_DATAMART.ventas.DimProveedores b On a.codprv collate SQL_Latin1_General_CP1_CI_AS = b.CodPrv

	Select @OrdenCli = Max(OrdenCli) From #ResultFinal Where OrdenCli Is Not Null
	
	;With dt As (Select Distinct CodCli, CodDom, NomCli From #ResultFinal Where OrdenCli Is Null),
			dt1 As (Select CodCli, CodDom, ROW_NUMBER() Over(Order By NomCli) Cor From dt)
	Update a Set OrdenCli = b.Cor + @OrdenCli
	--Select * 
	From #ResultFinal a
	Inner Join dt1 b On a.CodCli = b.CodCli And a.CodDom = b.CodDom
	Where OrdenCli Is Null
	
	--Select CodCli, Count(Distinct U_BKP_CODDIA) From #ResultFinal Group By CodCli Order By 2 Desc
	--Select * From #ResultFinal Where CodCli = 'CL00902778' Order by CodDom

	Update #ResultFinal Set OrdenCli = 999 Where OrdenCli Is Null	
	--Update #ResultFinal Set CodCli = Null Where IsNull(TotalIgv, 0) <= 0
	Update #ResultFinal Set CodCatx = Null Where IsNull(TotalIgv, 0) <= 0

	;With dt As (Select Distinct CodCat, NomCat From #ResultFinal where NomCat Is Not Null)
	--Select * 
	Update a Set a.NomCat = b.NomCat
	From #ResultFinal a
	Inner Join dt b On a.CodCat = b.CodCat
	Where a.NomCat Is Null
	   	
	;With dtMaxCli As (Select Count(Distinct NomCli) MaxCli From #ResultFinal)
	Select a.*, b.Color ColorPrv, b.ColorFuente, MaxCli, ROMA_DATAMART.[dbo].[fn_nombre_diasem](U_BKP_CODDIA) Day
	-- Select *
	From #ResultFinal a
	Inner Join dtMaxCli c On 1 =1
	Inner Join #Colores b On a.OrdenPrv = b.IdColor	
	Order By OrdenPrv, OrdenCat
	   
	-- Select * From #ResultFinal 
		
	Set NoCount Off

End

GO


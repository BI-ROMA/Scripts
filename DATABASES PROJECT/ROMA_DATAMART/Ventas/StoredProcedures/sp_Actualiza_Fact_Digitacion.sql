CREATE Proc [Ventas].[sp_Actualiza_Fact_Digitacion] 
@pPeriodo Char(8) = Null
As
Begin

	Set NoCount On
	
	-- [Ventas].[SP_Fact_Digitacion] null
	-- Declare @pPeriodo Char(8) = 20231103

	Exec [Ventas].[sp_Actualiza_DimFechas]
				   
	Declare @Periodo As Char(8)
	If @pPeriodo Is Null
	Begin
		Set @Periodo = Convert(Char(8), GetDate(), 112)
	End
	Else
	Begin
		Set @Periodo = @pPeriodo
	End


	Drop Table If Exists #vendedor
	Drop Table If Exists #tmpcartera
	Drop Table If Exists #tmpcarteraxxx
	Drop Table If Exists #ventadigitado
	Drop Table If Exists #tmpcob
	Drop Table If Exists #tmpvta
	Drop Table If Exists #Fact_Digitacion
	Drop Table If Exists #tmpcarteraYYY
	Drop Table If Exists #vencar
	Drop Table If Exists #carthist
	Drop Table If Exists #OCRD 
	Drop Table If Exists #OITM
	Drop Table If Exists #SupJV
	


	Select CardCode, CardName, CardFName, LicTradNum NumDoc, Case When Len(LicTradNum)=11 Then 'RUC' Else 'NoRuc' End TiDoc
	Into #OCRD 
	From SrvSAP.Roma_Productiva.dbo.OCRD
	
	Select itemcode, itemname, U_BKS_LINEA, y.name Linea, CardCode, NumInBuy, U_BPP_TIPUNMED, U_BKS_CATEGORIA
	Into #OITM
	From srvsap.roma_productiva.dbo.OITM x
	Left Join srvsap.roma_productiva.dbo.[@BKS_LINEAS] y On y.code = x.U_BKS_LINEA
					   

	
	Select Distinct codsede,nomsede,codven,nomven,codsup,codmesa,grupovnd, codcar
	Into #vendedor
	From srvsap.roma_productiva.Reportes.mov_cuotas
	Where periodo=LEft(@periodo, 6) and cuota+cuotamay > 0			

	--Select * From #vendedor Where codven = '2262'
	
	
	-- Drop table #tmpcarteraXxx
	select Distinct docdate, a.slpcode codven, 
	b.cardcode Collate SQL_Latin1_General_CP1_CI_AS CardCode, 
	Convert(Varchar(11), docdate, 112) iDocDate, CodCar, codzon, codmesa, codcnl,  Convert(Char(5), Null) codsede, 
	Right('000'+codDom, 3) codDom
	Into #tmpcarteraXxx
	from srvsap.roma_productiva.gproc.gCAR a 
	inner join srvsap.roma_productiva.gproc.gcar1 b on a.id=b.id 	
	and Convert(Char(8), a.docdate, 112) = @Periodo
	Where  codcnl Is not Null 
		 		
								
	if (select count(*) from #vendedor)=0
	Begin
		insert into #vendedor
		select U_BKS_CodSed,U_BKS_CodSed,SlpCode,SlpName,U_BKS_CODSUP,U_BKS_Mesa,U_BKP_GRUPO,U_BKS_CodCart     
		from srvsap.roma_productiva.dbo.oslp
		where U_BKS_ESTATUS='A'
	End
	Else
	Begin	

		insert into #vendedor		
		Select Distinct U_BKS_CodSed,U_BKS_CodSed,SlpCode,SlpName, x.codsup U_BKS_CODSUP,U_BKS_Mesa,U_BKP_GRUPO,U_BKS_CodCart     
		from srvsap.roma_productiva.dbo.oslp a
		Inner Join (Select Distinct codsup, codven 
					From srvsap.roma_productiva.reportes.mov_cuotas Where periodo=@Periodo) x On a.slpcode = x.codven
		where U_BKS_ESTATUS='A' 			
		And x.codsup In (Select distinct codsup From #vendedor)
		And Not Exists(Select * From #vendedor b Where a.SlpCode = b.codven And x.codsup = b.codsup)

	End		
	
	--Select * From #vendedor Where codsup In ('0077', '0087') Order By codven
	
	Select *, ROW_NUMBER() Over (Partition By CodVen, CardCode, CodZon, CodMesa, CodCnl Order By docdate Desc) Cor
	into #carthist
	From (Select Distinct slpcode  codven, cardcode Collate SQL_Latin1_General_CP1_CI_AS CardCode, 
			codzon, codcnl, codmesa, codcar, docdate
			from srvsap.roma_productiva.gproc.gCAR a 
			inner join srvsap.roma_productiva.gproc.gcar1 b on a.id=b.id 		
			Where Convert(Char(6), docdate, 112) = Left(@Periodo,6) And Codcar Is NOt Null) dt


		
	;With dt As (Select Distinct * from #carthist Where Codcar Is NOt Null And Cor=1)
	Update a Set codcar = b.codcar
	From #tmpcarteraXxx a
	Inner Join dt b On a.cardcode = b.cardcode And a.codmesa = b.codmesa And a.codzon = b.codzon And a.codven = b.codven
					
	Update a Set codcar = b.code
	From #tmpcarteraXxx a
	Inner Join srvsap.roma_productiva.dbo.[@BKS_CARTERA] b On a.codzon = b.U_ZONA
	Where codcar Is Null
	
	select a.ped_pk idpedido, a.usr_pk codven,
	a.cli_codigo  codcli_full,
	substring(a.cli_codigo, 1, CHARINDEX('-', a.cli_codigo)-1)  codcli,
	c.CardCode codprv , /*c.U_BKS_FAMILIA codfam,*/c.ItemCode  codpro ,
	case when b.det_caja>0 then b.det_preciopaq/c.NumInBuy else b.det_preciound end PrecioBase,
	case when b.det_caja>0 then (b.det_caja*b.NumInSale)+b.det_botella else b.det_botella end cantidad,
	b.det_monto monigv, 
	ped_fecinicio, ped_fecfin, ped_fecregistro, ped_canal, Convert(Char(3), Null) ped_sede, IsNull(ped_nopedido, '0000') ped_nopedido, IsNull(ped_nopednom, 'PEDIDO') ped_nopednom
	into #ventadigitado	
	from srvsap.roma_productiva.gproc.vw_tbl_pedido a 
	Left Outer Join srvsap.roma_productiva.gproc.vw_tbl_pedido_detalle b On a.ped_pk =b.ped_pk  
	Left Outer Join #OITM c On b.pro_codigo =c.ItemCode 
	where Convert(Char(8), a.ped_fecregistro, 112) = @Periodo	
	and a.ped_estado !='A'

	--select * from #ventadigitado where codpro = 'VAL110103' and  codven  = 155

	
	   		
	Update a Set ped_sede = b.codigosede
	From #ventadigitado a
	Inner Join srvsap.roma_productiva.gproc.gped b On a.idpedido =b.idpedido

	--Select * From #ventadigitado Where codven = 1448
	
				
	-- Drop tAble #tmpvta 
	Select ped_fecinicio, ped_fecfin, ped_fecregistro, codcli, codcli_full, a.codprv, a.codpro, a.codven, a.monigv as soles, 
	(a.cantidad )*(case b.U_BPP_TIPUNMED when '01' then c.valor1  when '07' then 1/(c.valor1) when '08' then c.valor1 when '12' then 1/(c.valor1) else 0 end ) umes	,
	ped_canal, cantidad, ped_sede CodSede, idpedido, ped_nopedido, ped_nopednom, convert(decimal(18,5), 0.00000) peso
	into #tmpvta 
	from #ventadigitado a 
	Left join #OITM b on a.codpro=b.ItemCode
	left outer join (select * from srvsap.dw.reportes.item_unidadvolumenpeso where valor1>0) c on  b.ItemCode=c.itemcode  

	Update #tmpvta Set codprv='0000000000', codpro = '000000000' Where ped_nopedido != '0000'	   	 
	update #tmpvta set umes = 0, peso = 0 Where codprv Like 'PM00000066'

	Update a Set umes = cantidad*valor2, a.peso = cantidad*convert(decimal(18,5),b.peso)
	From #tmpvta a
	Inner Join srvsap.dw.reportes.item_unidadvolumenpeso b On a.codpro = b.itemcode And a.codprv = b.codprv
	Where a.codprv Like '%00066'

	--Select * From #tmpvta
	
	Update a Set codcar = b.codcar
	From #tmpcarteraXxx a
	Inner Join (Select Distinct CodVen, CodCar From #tmpcarteraXxx where Ltrim(Str(codven)) != codcar) b On a.codven = b.codven
	
	Update a Set codcar = b.codcar
	From #vendedor a
	Inner Join (Select Distinct CodVen, CodCar From #tmpcarteraXxx where Ltrim(Str(codven)) != codcar) b On a.codven = b.codven

	update #tmpvta
	set ped_nopednom =
		case ped_nopednom
		when 'PEDIDO' then 'Pedido'
		else 'NoPedido'
	END

	drop table if exists #tmpvta_f
	select * 
	into #tmpvta_f
	from #tmpvta
	pivot
		(
			count(ped_nopednom)
			for ped_nopednom in ([Pedido], [NoPedido])
		) as PivotTable

	Select ped_fecinicio, ped_fecfin, ped_fecregistro, 
	codcli Collate SQL_Latin1_General_CP1_CI_AS CodCli, 
	codcli_full, 
	a.codprv Collate SQL_Latin1_General_CP1_CI_AS CodPrv, 
	a.codpro Collate SQL_Latin1_General_CP1_CI_AS CodPro,
	codcar Collate SQL_Latin1_General_CP1_CI_AS U_BKS_CodCart, 
	codcar Collate SQL_Latin1_General_CP1_CI_AS U_BKS_CodCartNew, 
	a.codven, nomven as nomven, soles, umes, 0 Cartera, 
	Convert(Char(11), a.ped_Fecregistro, 112) iFechaPedido,
	Convert(Varchar(15), Null) CodZona, codmesa, codsede, Null codsup, ped_canal, cantidad, Right(codcli_full, 3) coddom, 
	DatePart(HOUR, ped_fecregistro) Hora, DatePart(MINUTE, ped_fecregistro) Minuto,
	idpedido,
	Convert(Decimal(18, 2), 0) Cantidad_OC, Convert(Decimal(18, 2), 0) MonIgv_OC, 
	Convert(Decimal(18, 2), 0) UMES_OC, 'NOR' Tipo, ped_nopedido, Pedido, NoPedido,
	0 Item, peso
	Into #Fact_Digitacion
	From #tmpvta_f a
	inner join (Select Distinct CodVen, codcar, nomven, codmesa From #vendedor) c  on  a.codven=c.codven
	Left Outer Join (Select Distinct codven From #tmpcarteraxxx) d on a.codven=d.codven 
	


	;With dtSup As (Select CodVen, codcar, nomven, codmesa, Count(distinct codsup) QtdSup From #vendedor 
	Group By CodVen, codcar, nomven, codmesa 
	Having Count(distinct codsup) = 1)
	Update a Set codsup = c.codsup
	-- Select * 
	From #Fact_Digitacion a
	Inner Join dtSup b On a.codven = b.codven
	Inner Join #vendedor c On a.codven = c.codven

	Update a Set codsup = '0091'
	From #Fact_Digitacion a
	Where codsup Is Null and codven = 2290 And CodPrv In ('PM00000066', 'PM00000091')

	Update a Set codsup = '0090'
	From #Fact_Digitacion a
	Where codsup Is Null and codven = 2290 And CodPrv Not In ('PM00000066', 'PM00000091')
	


	
	If convert(char(8), getdate(), 112)=@Periodo
	Begin		
		;With dt As (Select *, Right(u_bkp_codcnl, 2) CodCanal From srvsap.roma_productiva.dbo.[@BKS_CLIENTE_MESA] 
						Where U_BKP_ESTADO = 'A')
		Update a Set CodZona = b.u_bkp_codzon Collate SQL_Latin1_General_CP1_CI_AS
		From #Fact_Digitacion a
		Inner Join dt b On a.codmesa = b.u_bkp_codmesa 
		And a.U_BKS_CodCart = b.u_bkp_codven Collate SQL_Latin1_General_CP1_CI_AS
		And a.CodCli = b.u_bkp_cliente Collate SQL_Latin1_General_CP1_CI_AS
		And a.CodDom = b.u_bkp_coddom Collate SQL_Latin1_General_CP1_CI_AS
		And a.ped_canal = b.codcanal
		Where b.u_bkp_codzon  Collate SQL_Latin1_General_CP1_CI_AS <> IsNull(codzona, '*')
		And codzona Is Null
		
	End

	;With dt As (Select Distinct U_BKP_CLIENTE+'-'+U_BKP_CODDOM CODCLIFULL, Right(u_bkp_codcnl, 2) CodCanal, Substring(u_bkp_codcnl, 3, 2) CodSede
					From srvsap.roma_productiva.dbo.[@BKS_CLIENTE_MESA] 
					Where U_BKP_ESTADO = 'A' And IsNull(U_BKP_CODVEN, '') <> '')
	Update a Set Ped_Canal = b.CodCanal, CodSede=b.CodSede
	From #Fact_Digitacion a
	Inner Join dt b On a.codcli_full= b.CODCLIFULL Collate SQL_Latin1_General_CP1_CI_AS
	Where ped_nopedido != '0000'
		
	Update a Set codzona = b.u_zona
	From #Fact_Digitacion a
	Inner Join srvsap.roma_productiva.dbo.[@BKS_CARTERA] b On a.U_BKS_CodCart = b.code Collate SQL_Latin1_General_CP1_CI_AS
	Where codzona Is Null


	Select a.*, u_bkp_codsede Collate SQL_Latin1_General_CP1_CI_AS codsed, 
	IsNull(c.codsup, '0000') codsup	
	Into #tmpcarteraYYY	
	From #tmpcarteraXXX a
	Inner Join SrvSAP.roma_productiva.dbo.[@BKS_ZONAS] b On a.codzon = b.code
	Left Join (Select Distinct codven, codsup From #vendedor Where codven Is Not Null) c On a.codven = c.codven

	If Left(@Periodo, 6) = 202102
	Begin	
		Insert Into #tmpcarteraYYY	
		Select a.*, codsede, IsNull(c.codsup, '0000') codsup
		From #tmpcarteraXXX a
		Left Join (Select Distinct codven, codsup From #vendedor Where codven Is Not Null) c On a.codven = c.codven
	End

	Alter Table #Fact_Digitacion Alter Column U_BKS_CodCart nvarchar(16) Collate SQL_Latin1_General_CP850_CI_AS
	Alter Table #Fact_Digitacion Alter Column U_BKS_CodCartNew nvarchar(16) Collate SQL_Latin1_General_CP850_CI_AS
	Update #Fact_Digitacion Set U_BKS_CodCartNew = '00000' Where U_BKS_CodCartNew Is Null


	
	Insert Into Ventas.DimClientes (CodCli, NomCli, TiCliente, CodDom, NumDoc, TipDoc)
	Select Distinct codcli, CardName,
	Case When Left(codcli, 2) = 'EM' Then 'Interno' Else 'Externo' End,	Right(a.codcli_full, 3), NumDoc, TiDoc
	From #Fact_Digitacion a	
	Inner Join #OCRD b On a.codcli = b.CardCode Collate SQL_Latin1_General_CP1_CI_AS
	Where Not Exists (Select * From Ventas.DimClientes b 
					Where a.codcli = b.codcli And b.CodDom = Right(a.codcli_full, 3) Collate SQL_Latin1_General_CP1_CI_AS)	

	Insert Into Ventas.DimClientes (CodCli, NomCli, TiCliente, CodDom, NumDoc, TipDoc)
	Select Distinct a.CardCode, CardName,
	Case When Left(a.CardCode, 2) = 'EM' Then 'Interno' Else 'Externo' End, a.CodDom, NumDoc, TiDoc
	From #tmpcarteraXXX a
	Inner Join #OCRD b On a.cardCode = b.CardCode Collate SQL_Latin1_General_CP1_CI_AS
	Where Not Exists (Select * From Ventas.DimClientes b 
						Where a.cardCode = b.codcli And b.CodDom = a.coddom Collate SQL_Latin1_General_CP1_CI_AS)	
									
	Insert Into Ventas.DimVendedores(CodVen, NomVen)
	Select Distinct codven, nomven From #Fact_Digitacion a
	Where Not Exists (Select * From Ventas.DimVendedores b Where a.codven = b.CodVen)

	Insert Into Ventas.DimVendedores(CodVen, NomVen)
	Select Distinct codven, SlpName From #tmpcarteraXXX a
	Inner Join SrvSAP.ROMA_Productiva.dbo.oslp b On a.codven = b.slpcode
	Where Not Exists (Select * From Ventas.DimVendedores b Where a.codven = b.CodVen)
	
	
	
	Update #Fact_Digitacion Set CodSede = 'XX' Where CodSede Is Null

							
	Delete [Ventas].[Fact_Digitacion] Where Convert(Char(8), fec_pedido, 112) = @Periodo
	   

	Update #Fact_Digitacion Set codsede = 'AN' Where CodVen In (1621)
	Update #Fact_Digitacion Set codsede = 'AP' Where CodVen In (1411, 1955)
	Update #Fact_Digitacion Set codsede = 'AV' Where CodVen In (1821, 2069, 1837)


	Update a Set CodSede = b.u_bkp_codsede
	From #Fact_Digitacion a
	Inner Join SrvSAP.Roma_Productiva.dbo.[@BKS_ZONAS] b On a.CodZona = b.Code Collate SQL_Latin1_General_CP1_CI_AS
	Where CodSede = 'XX'
	


	;With dt As (Select * From SrvSAP.Roma_Productiva.reportes.rel_prv_homologos)
	Update a Set CodPrv = b.codprv_homo
	From #Fact_Digitacion a
	Inner Join dt b On a.CodPrv = b.codprv Collate SQL_Latin1_General_CP1_CI_AS
	Where a.CodPrv <> b.codprv_homo Collate SQL_Latin1_General_CP1_CI_AS

	---Print @Periodo
	Drop Table If Exists #OC
	Select DocTotal, ItemCode, LineTotal, Quantity, U_BKP_PEDNEXTEL, b.GTotal, Canceled, a.DiscPrcnt
	Into #OC
	From SrvSAP.Roma_Productiva.dbo.ORDR a
	Inner Join SrvSAP.Roma_Productiva.dbo.RDR1 b On a.DocEntry = b.DocEntry
	Where Convert(Char(8), a.DocDate, 112) = @Periodo

	;With dtOC As (Select * From #OC)
	Update a Set Cantidad_OC = b.Quantity, MonIgv_OC = (GTotal - Case When IsNull(DiscPrcnt,0)=0 Then 0 Else GTotal*DiscPrcnt/100 End)
	From #Fact_Digitacion a
	Inner Join dtOC b On a.idpedido = b.U_BKP_PEDNEXTEL And a.CodPro = b.ItemCode Collate SQL_Latin1_General_CP1_CI_AS

	Update a Set UMES_OC = Cantidad_OC*valor2	
	From #Fact_Digitacion a
	Inner Join srvsap.dw.reportes.item_unidadvolumenpeso b On a.codpro = b.itemcode  Collate SQL_Latin1_General_CP1_CI_AS
	And a.codprv = b.codprv Collate SQL_Latin1_General_CP1_CI_AS
	Where a.codprv Like '%00066'
	   
	;With dtOC As (Select * From #OC Where Canceled = 'Y')
	Update a Set Tipo = 'CNL', ped_nopedido = '0009'
	From #Fact_Digitacion a
	Inner Join dtOC b On a.idpedido = b.U_BKP_PEDNEXTEL And a.CodPro = b.ItemCode Collate SQL_Latin1_General_CP1_CI_AS


	;With dt As (Select idpedido, CodPro, ROW_NUMBER() Over(Partition by idpedido Order By CodPro) Cor
				From #Fact_Digitacion)
	Update a Set Item = Cor
	From #Fact_Digitacion a
	Inner Join dt b On a.idpedido = b.idpedido And a.CodPro = b.CodPro


	Select IdSupervisor, IdJefe_dVenta 
	Into #SupJV
	From ventas.Fact_Cuotas Where Left(FechaKey, 6)=@Periodo


	update #Fact_Digitacion set ped_fecinicio = ped_fecregistro, ped_fecfin = ped_fecregistro where ped_fecinicio > ped_fecregistro


	alter table #Fact_Digitacion alter column pedido varchar(20)
	alter table #Fact_Digitacion alter column nopedido varchar(20)

	update #Fact_Digitacion
		set pedido = 
			case pedido
				when 1 then CodCli
				else null
			end

	update #Fact_Digitacion
		set NoPedido = 
			case NoPedido
				when 1 then CodCli
				else null
			end

	;with 
		dt as 
		(
			select 
				codven, CodCli, Pedido, NoPedido, sum(Soles) Total
			from #Fact_Digitacion
			group by codven, CodCli, Pedido, NoPedido
		),
		dr as 
		(
			select
				codven,
				CodCli,
				case 
					when Pedido is not null then 1
					else 0
				end Pedido,
				case 
					when NoPedido is not null then 1
					else 0
				end NoPedido
			from dt
		),
		df as
		(
			select codven, sum(Pedido) Pedido, sum(NoPedido) Nopedido 
			from dr 
			group by codven
		)			
		update a
			set a.Pedido = b.Pedido, a.NoPedido = b.Nopedido
		from #Fact_Digitacion a
		inner join df b on a.codven = b.codven
		--select * from #Fact_Digitacion where codven = 1113


	Insert Into Ventas.[Fact_Digitacion] (ped_fecinicio, ped_fecfin, ped_fecregistro, fec_pedido,
	IdCli, IdPrd, IdCartera, IdVen, Soles, UMES, PartitionMonth, Cartera, CliCodFull, idmesa, idsede, 
	idsup, IdCan, Cantidad, PartitionDay, IdVen_Original, FechaKey, IdProducto, IdCarteraNew, IdHora, 
	Cantidad_OC, MonIGV_OC, UMES_OC, IdAlmacen, IdPedido, TiPedido, CoMotivo, Item, IdJefe_dVenta, peso, Pedidos, NoPedidos, IdCat_xPrv)
	Select ped_fecinicio, ped_fecfin, ped_fecregistro, Cast(ped_fecregistro As date), 
	cli.IdCli, null, xcar.IdCartera, IdVen, Soles, UMES,
	Ltrim(Str(DatePart(YY, a.ped_fecregistro))) + Right('00' + Ltrim(Str(DatePart(MM, ped_fecregistro))), 2), 
	Cartera, codcli_full, idmesa, sed.IdSede, IdSup, can.IdCan, cantidad,
	Convert(Varchar(11), a.ped_fecinicio, 112), IdVen, Convert(Varchar(11), a.ped_fecinicio, 112), pr.IdPro, xcar.IdCartera, hh.IdHora,
	Cantidad_OC, MonIgv_OC, UMES_OC, sed.IdAlmacen, idpedido, Tipo, ped_nopedido, Item, IsNull(IdJefe_dVenta, 99), a.peso, Pedido, NoPedido, pr.IdCat_xPrv
	From #Fact_Digitacion a	
	Inner Join Ventas.DimHora hh On a.Hora = hh.hora And a.Minuto = hh.Minuto
	Inner Join Ventas.DimProductos pr On a.CodPro = pr.CodPro
	Inner Join Ventas.DimVendedores ven On a.codven = ven.CodVen
	Inner Join Ventas.DimClientes cli On a.codcli = cli.CodCli And a.coddom Collate SQL_Latin1_General_CP850_CI_AS = cli.coddom
	Inner Join Ventas.DimSedes sed On sed.CodSede = a.codsede	
	Inner Join Ventas.DimCarteras xcar On a.U_BKS_CodCartNew Collate SQL_Latin1_General_CP1_CI_AS = xcar.codcartera 
	Inner Join Ventas.dimMesas me On a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = me.codmesa
	Inner Join Ventas.Dim_vw_Supervisores su On a.codsup = su.CodSup
	Inner Join Ventas.DimCanales can On a.ped_canal Collate SQL_Latin1_General_CP1_CI_AS = can.CodCan
	Left Join #SupJV xx On su.IdSup = xx.IdSupervisor


	

	update a 
		set a.idtipopedido = b.tipo
	From ventas.Fact_Digitacion a
	inner join srvsap.roma_productiva.gproc.gped b on a.idpedido = b.idpedido
	where left(FechaKey,6) = left(@Periodo,6)



	;with dt 
		as (
			select MAX(IdHora) horamax
			from ventas.Fact_Digitacion 
			where FechaKey = convert(varchar, GETDATE(), 112)
		)
		update Ventas.Fact_Digitacion
		set factorVenta = 
			case 
				when (select horamax from dt) < 83000 then 0.06
				when (select horamax from dt) < 90000 then 0.12
				when (select horamax from dt) < 93000 then 0.18
				when (select horamax from dt) < 100000 then 0.24
				when (select horamax from dt) < 103000 then 0.29
				when (select horamax from dt) < 110000 then 0.35
				when (select horamax from dt) < 113000 then 0.41
				when (select horamax from dt) < 120000 then 0.47
				when (select horamax from dt) < 123000 then 0.53
				when (select horamax from dt) < 130000 then 0.59
				when (select horamax from dt) < 133000 then 0.65
				when (select horamax from dt) < 140000 then 0.71
				when (select horamax from dt) < 143000 then 0.76
				when (select horamax from dt) < 150000 then 0.82
				when (select horamax from dt) < 153000 then 0.88
				when (select horamax from dt) < 160000 then 0.94
				when (select horamax from dt) < 163000 then 1.00
				else 1.00
			end
		where FechaKey = Convert(Char(8), GetDate(), 112)



	;with dt 
		as (
			select MAX(IdHora) horamax
			from ventas.Fact_Digitacion 
			where FechaKey = convert(varchar, GETDATE(), 112)
		)
		update Ventas.Fact_Digitacion
		set factorcob = 
			case 
				when (select horamax from dt) < 83000 then 0.04
				when (select horamax from dt) < 90000 then 0.07
				when (select horamax from dt) < 93000 then 0.11
				when (select horamax from dt) < 100000 then 0.14
				when (select horamax from dt) < 103000 then 0.18
				when (select horamax from dt) < 110000 then 0.21
				when (select horamax from dt) < 113000 then 0.25
				when (select horamax from dt) < 120000 then 0.28
				when (select horamax from dt) < 123000 then 0.32
				when (select horamax from dt) < 130000 then 0.35
				when (select horamax from dt) < 133000 then 0.39
				when (select horamax from dt) < 140000 then 0.42
				when (select horamax from dt) < 143000 then 0.46
				when (select horamax from dt) < 150000 then 0.49
				when (select horamax from dt) < 153000 then 0.53
				when (select horamax from dt) < 160000 then 0.56
				when (select horamax from dt) < 163000 then 0.60
				else 0.60
			end
		where FechaKey = Convert(Char(8), GetDate(), 112) and IdMesa not in (5,9,22,23,11,13)



	;with dt 
		as (
			select MAX(IdHora) horamax
			from ventas.Fact_Digitacion 
			where FechaKey = convert(varchar, GETDATE(), 112)
		)
		update Ventas.Fact_Digitacion
		set factorcob = 
			case 
				when (select horamax from dt) < 83000 then 0.05
				when (select horamax from dt) < 90000 then 0.10
				when (select horamax from dt) < 93000 then 0.15
				when (select horamax from dt) < 100000 then 0.20
				when (select horamax from dt) < 103000 then 0.25
				when (select horamax from dt) < 110000 then 0.30
				when (select horamax from dt) < 113000 then 0.35
				when (select horamax from dt) < 120000 then 0.40
				when (select horamax from dt) < 123000 then 0.45
				when (select horamax from dt) < 130000 then 0.50
				when (select horamax from dt) < 133000 then 0.55
				when (select horamax from dt) < 140000 then 0.60
				when (select horamax from dt) < 143000 then 0.65
				when (select horamax from dt) < 150000 then 0.70
				when (select horamax from dt) < 153000 then 0.75
				when (select horamax from dt) < 160000 then 0.80
				when (select horamax from dt) < 163000 then 0.85
				else 0.85
			end
		where FechaKey = Convert(Char(8), GetDate(), 112) and IdMesa in (5,9,22,23,11,13)


		
	;with dt 
		as (
			select MAX(IdHora) horamax
			from ventas.Fact_Digitacion 
			where FechaKey = convert(varchar, GETDATE(), 112)
		)
		update Ventas.Fact_Digitacion
		set factordono = 
			case 
				when (select horamax from dt) < 83000 then 1
				when (select horamax from dt) < 90000 then 2
				when (select horamax from dt) < 93000 then 3
				when (select horamax from dt) < 100000 then 4
				when (select horamax from dt) < 103000 then 5
				when (select horamax from dt) < 110000 then 6
				when (select horamax from dt) < 113000 then 7
				when (select horamax from dt) < 120000 then 8
				when (select horamax from dt) < 123000 then 10
				when (select horamax from dt) < 130000 then 11
				when (select horamax from dt) < 133000 then 12
				when (select horamax from dt) < 140000 then 13
				when (select horamax from dt) < 143000 then 14
				when (select horamax from dt) < 150000 then 15
				when (select horamax from dt) < 153000 then 16
				when (select horamax from dt) < 160000 then 17
				when (select horamax from dt) < 163000 then 18
				else 1
			end
		where FechaKey = Convert(Char(8), GetDate(), 112)










		
	;With dtActual As (Select a.*, c.IdPrv From ventas.Fact_Digitacion a
					Inner Join Ventas.DimProductos b On a.IdPrd = b.IdPro
					inner join Ventas.DimCategorias c on b.IdCat_xPrv = c.IdCat_xPrv
					Where PartitionDay = @Periodo)
	Update a Set IdVen = c.IdVen
	From ventas.Fact_Digitacion a
	Inner Join Ventas.DimProductos b On a.IdPrd = b.IdPro
	inner join Ventas.DimCategorias d on b.IdCat_xPrv = d.IdCat_xPrv
	Inner Join dtActual c On a.PartitionMonth = c.PartitionMonth 
								And c.IdPrv = d.IdPrv 
								And c.IdCartera = a.IdCartera
								And a.IdCli = c.IdCli 
								And a.IdMesa = c.IdMesa
	Where a.PartitionMonth = Left(@Periodo, 6) And a.PartitionDay < @Periodo
		
	Delete Ventas.Fact_Cartera Where Convert(Char(8), docdate, 112) = @Periodo

	--select * from  #tmpcarteraYYY where codsede is not null
	Update #tmpcarteraYYY Set codsede = 'AN' Where CodVen In (1621)
	Update #tmpcarteraYYY Set codsede = 'AP' Where CodVen In (1411, 1955)
	Update #tmpcarteraYYY Set codsede = 'AV' Where CodVen In (1821, 2069, 1837)

	Insert Into Ventas.Fact_Cartera(docdate, IdVen, IdCar, IdCli, CodCli, Qtd, IdSup, IdSed, PartitionDay, FechaKey, IdCarteraNew)
	Select Distinct docdate, IdVen, cr.IdCartera, IdCli, CodCli, 1 Qtd, IdSup, IdSede, Convert(Varchar(11), docdate, 112), Convert(Varchar(11), docdate, 112), IsNull(cr.IdCartera, 0)
	From #tmpcarteraYYY a
	Left Join Ventas.DimCarteras cr On a.CodCar Collate SQL_Latin1_General_CP1_CI_AS = cr.CodCartera
	Inner Join Ventas.DimClientes cli On a.cardcode = cli.CodCli And a.codDom Collate SQL_Latin1_General_CP1_CI_AS = cli.CodDom
	Inner Join Ventas.DimVendedores ven On a.codven = ven.CodVen
	Inner Join Ventas.Dim_vw_Supervisores sup On a.codsup = sup.CodSup
	Inner Join Ventas.DimSedes sed On isnull(a.codsede, a.codsed) = sed.CodSede
	Order By 1 Desc

	exec [Ventas].[sp_Actualiza_Fact_CuotasDiarias]

	Set NoCount Off

End
GO


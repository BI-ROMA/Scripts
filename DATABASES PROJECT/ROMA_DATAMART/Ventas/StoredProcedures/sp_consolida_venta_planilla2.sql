CREATE Procedure [Ventas].[sp_consolida_venta_planilla2] 
@pPeriodo Char(6)
as
begin 

Set NoCount On

	-- Declare @pperiodo char(6) = '202311'
	-- Exec [Ventas].[sp_consolida_venta_planilla2] 202310
		
	Declare @numano as int = Left(@pPeriodo, 4), 
			@nummes as int = Right(@pPeriodo, 2)

	Drop Table If Exists #Cartera
	Drop Table If Exists #DocEntry_Ven
	Drop Table If Exists #DocEntry_Dev
	Drop Table If Exists #Supervisores	
	Drop Table If Exists #Cuotas
	Drop Table If Exists #relfamcatgrupo
	Drop Table If Exists #prvhomo	
	Drop Table If Exists #Data 
	Drop Table If Exists #tmpprod
	Drop Table If Exists #fechas
	Drop Table If Exists #tprodfecha
	Drop Table If Exists #tmpultprecio
	Drop Table If Exists #tmp1
	Drop Table If Exists #tmp2
	Drop Table If Exists #tmp
	Drop Table If Exists #tmppednc
	Drop Table If Exists #tmpfa
	Drop Table If Exists #tmpped
	Drop Table If Exists #tmpdev
	Drop Table If Exists #tmpdev1	
	Drop Table If Exists #tmpcuota
	Drop Table If Exists #OITM
	Drop Table If Exists #ORDR
	Drop Table If Exists #tmp1
	Drop Table If Exists #INV1
	Drop Table If Exists #Result
	Drop Table If Exists #OCRD
	Drop Table If Exists #item_unidadvolumenpeso 

	declare @ld_fecsig date
	declare @ld_fecinimes date
	declare @periodo char(6)
	DECLARE @Exis AS INT

	set @ld_fecinimes=convert(date,cast(@numano as CHAR(4))+right('0'+cast(@nummes as varchar(2)),2)+'01',112)
	set @ld_fecsig=dateadd(month,1,@ld_fecinimes)
	set @periodo=convert(char(6),@ld_fecinimes,112)
	

	Select a.*, IsNull(Valor1, 1) V1, IsNull(Valor2, 0) V2
	Into #item_unidadvolumenpeso 
	-- Select *
	From SRVSAP.dw.reportes.item_unidadvolumenpeso a
			
		
	-- Drop Table #OITM
	Select a.ItemCode, ItemName, CardCode, SWW, U_BKS_FAMILIA, U_BKS_Linea, ItmsGrpCod, InvntItem, TreeType, 
	AvgPrice, U_bks_categoria, U_BPP_TIPUNMED,
	Case When a.cardcode In ('PM00000090', 'PM00000066')
	Then b.V2
	Else 
		Case When v1 = 0 
		Then 0 Else (case U_BPP_TIPUNMED when '01' then isnull(b.V1,0) when '07' then 1/(b.V1) when '08' then isnull(b.V1,0) when '12' then 1/(b.V1) else 0 end ) 
		End End FactorUME
	Into #OITM 
	-- Select *
	From SrvSAP.Roma_Productiva.dbo.OITM a
	Left Join #item_unidadvolumenpeso b On a.ItemCode = b.ItemCode	


	Update #OITM Set U_BKS_CATEGORIA = '000' Where IsNull(U_BKS_CATEGORIA, '')=''

	Update a Set CardCode=b.codprv_homo
	From #OITM a
	Inner Join SrvSAP.Roma_Productiva.REPORTES.rel_prv_homologos b On a.cardcode = b.codprv 
	And Ltrim(Str(@numano)) + Right('00'+Ltrim(Str(@nummes)), 2) >= b.periodoinicio_homo

	-- Drop Table #OCRD
	Select CardCode, CardName, CardfName, LicTradNum NumDoc, Case When Len(LicTradNum)=11 Then 'RUC' Else 'NoRuc' End TiDoc
	Into #OCRD
	From SrvSAP.Roma_Productiva.dbo.OCRD

	Select taxdate, DocEntry
	Into #ORDR
	From SrvSAP.Roma_Productiva.dbo.ORDR f 	
	Where convert(Char(6), f.taxDate, 112)=@periodo
	
	Create Index #idx_OITM On #OITM(itemcode)
	Create Index #idx_ORDR On #ORDR(DocEntry)
			
	Select Convert(nvarchar(40), itemcode) itemcode, fecha, costo, Convert(char(8), fecha, 112) pfecha
	Into #tmpultprecio 
	From SrvSAP.Roma_Productiva.Reportes.ultpreciocompra
	Where convert(char(6), fecha, 112)=@periodo
    
	Create Index #idx_uprecio On #tmpultprecio(itemcode,pfecha)
	
	;With dtOINV As (Select docentry, taxdate, convert(char(8), taxdate, 112) pfecha 
						From SrvSAP.Roma_Productiva.dbo.oinv b 
						Where Convert(Char(6), b.taxdate, 112) = @periodo)
    Select  a.ItemCode,COUNT(*) as cantidad 
	into #tmpprod
	From #OITM a,
		dtOINV b,
		SrvSAP.Roma_Productiva.dbo.inv1 c 
	Where ((a.InvntItem='Y' and  a.SWW<>'EQ FRIO')) 
    And b.DocEntry=c.DocEntry and a.ItemCode=c.itemcode 
    And not exists (Select 1 From  #tmpultprecio d Where a.ItemCode=d.itemcode and b.pfecha=d.pfecha)
    Group By a.ItemCode
	
	;With dtOINV As (Select docentry, taxdate, convert(Char(8), b.TaxDate, 112) pfecha 
					From SrvSAP.Roma_Productiva.dbo.oinv b 
					Where convert(Char(6), b.TaxDate, 112)=@periodo)
	Insert Into #tmpprod
	Select  a.ItemCode,COUNT(*) as cantidad 	
	From #OITM a,
		dtOINV b,
		SrvSAP.Roma_Productiva.dbo.inv1 c 
	Where b.DocEntry=c.DocEntry and a.ItemCode=c.itemcode 
    And (a.TreeType <>'N' )
    And not exists (Select 1  From  #tmpultprecio d Where a.ItemCode=d.itemcode and b.pfecha=d.pfecha)
    Group By a.ItemCode
	
	Select distinct fecha 
	Into #fechas 
	From #tmpultprecio  
		
    Select distinct a.ItemCode,d.fecha ,a.AvgPrice 
	into #tprodfecha
	From #OITM a,
		#tmpprod,
		#fechas d
    Where a.ItemCode=#tmpprod.itemcode and len(a.ItemCode)<=11 
    and Not exists (Select 1 From #tmpultprecio b Where b.itemcode=a.ItemCode and b.fecha=d.fecha   )
	   
    Insert Into #tmpultprecio Select *, convert(char(8), fecha, 112) From #tprodfecha 
		
	Select b.docentry, b.BaseEntry, b.ItemCode, b.Dscription, b.LineTotal, b.GTotal, b.Quantity, b.numpermsr,
	b.vatprcnt, b.pricebefdi, b.whscode, b.U_BKS_Boni, b.DiscPrcnt, BaseType, unitMsr, U_BKS_GRUPO, f.taxdate, LineNum, U_BKS_CodProm, b.price
	Into #INV1
	From SrvSAP.Roma_Productiva.dbo.INV1 b
	Inner Join SrvSAP.Roma_Productiva.dbo.ORDR f on b.BaseEntry=f.DocEntry  
	and convert(char(6), f.taxDate, 112)=@periodo

	Select  a.CardCode as codcli,isnull(a.U_BKS_DOMICILIO,'001') as coddom,a.Docentry ,d.SWW as grupo,b.ItemCode as codpro,
	b.Dscription as nompro, 'V' as tipo,
	a.U_BKP_CODMESA As codmesa,	d.CardCode as codprv, d.U_BKS_FAMILIA as codfam,
	a.SlpCode codven, a.U_BKP_CANAL as codcanal, b.taxdate,	b.LineTotal as monsinigv,b.GTotal as total,
	cast(0 as numeric(14,4)) as pctmargen,	b.Quantity, b.numpermsr,b.unitMsr,	b.Quantity*b.numpermsr as cantidad,
	case isnull(b.U_BKS_boni,'N')  when 'N' then 'N' else 'S' end as flgprom,b.vatprcnt as igv,b.pricebefdi as precioant, b.U_BKS_CodProm as CodigoPromocion, b.price, 
	SPACE(6) as codrut, d.U_BKS_Linea as codlinea, a.GroupNum as cndpago, b.whscode as codalm,a.U_BPV_SERI as serie,
	a.U_BPV_NCON2 as numero, (case when b.discPrcnt = 100 then 'B' else 'P' end) bonificacion, b.DiscPrcnt, ItmsGrpCod, a.U_BKP_TIPO oriped, 
	Convert(Varchar(6), a.U_U_BKS_CODSEDE) CodZona, Convert(Varchar(20), U_BKS_GRUPO) U_BKS_GRUPO, a.SlpCode, LineNum, a.[Address]
	Into #tmp1
	From SrvSAP.Roma_Productiva.dbo.OINV a
	inner join #INV1 b On a.DocEntry=b.DocEntry and b.Quantity>0 and b.BaseType=17
	inner join #OITM d on b.ItemCode=d.ItemCode


	Update a Set codprv=b.codprv_homo
	From #tmp1 a
	Inner Join SrvSAP.Roma_Productiva.REPORTES.rel_prv_homologos b On a.codprv = b.codprv 
	And Ltrim(Str(@numano)) + Right('00'+Ltrim(Str(@nummes)), 2) >= b.periodoinicio_homo
	
	Select a.CardCode as codcli,isnull(a.U_BKS_DOMICILIO,'001') as coddom,a.Docentry ,d.SWW as grupo,b.ItemCode as codpro,
	b.Dscription as nompro,'V' as tipo,isnull(a.U_BKP_CODMESA,' ') as codmesa,isnull(d.CardCode,' ') as codprv,
	isnull(d.U_BKS_FAMILIA,' ') as codfam,a.SlpCode as codven ,isnull(a.U_BKP_CANAL,' ') as codcanal ,a.taxdate ,
	b.LineTotal as monsinigv,b.GTotal as total,cast(0 as numeric(14,4)) as pctmargen,b.Quantity, b.numpermsr,b.unitMsr,
	b.Quantity*b.numpermsr as cantidad,	case isnull(b.U_BKS_boni,'N')  when 'N' then 'N' else 'S' end as flgprom,b.vatprcnt as igv,b.pricebefdi,b.U_BKS_CodProm as CodigoPromocion, b.price, 
	SPACE(6) as codrut,isnull(d.U_BKS_Linea,SPACE(7)) as codlinea,a.GroupNum as cndpago,b.whscode as codalm,a.U_BPV_SERI as serie , 
	a.U_BPV_NCON2 as numero,(case when b.discPrcnt = 100 then 'B' else 'P' end) bonificacion, b.DiscPrcnt ,ItmsGrpCod,a.U_BKP_TIPO oriped, 
	a.U_U_BKS_CODSEDE CodZona, U_BKS_GRUPO, a.SlpCode, LineNum, a.[Address]
	Into #tmp2
	From SrvSAP.Roma_Productiva.dbo.OINV a 
	Inner Join SrvSAP.Roma_Productiva.dbo.INV1 b on a.DocEntry=b.DocEntry 
	and convert(char(6), a.taxDate, 112)=@periodo
	And b.BaseType=-1 and b.Quantity > 0
	Inner Join SrvSAP.Roma_Productiva.dbo.OITM d on b.ItemCode=d.ItemCode 

	Update a Set codprv=b.codprv_homo
	From #tmp2 a
	Inner Join SrvSAP.Roma_Productiva.REPORTES.rel_prv_homologos b On a.codprv = b.codprv 
	And Ltrim(Str(@numano)) + Right('00'+Ltrim(Str(@nummes)), 2) >= b.periodoinicio_homo
	
	insert into #tmp1
	Select * From #tmp2

	--Select * From #tmp1 Where codcli = 'EM002261506'
		   
    create index #idx_taxdate_itemcode1 on #tmp1(codpro, taxdate)
	   	 	
	---margen de los articulos normales sin promocion
	Select x.*,isnull(e.costo,0) costo,x.monsinigv - isnull(e.costo,0)*x.cantidad  as margensinigv,x.Total - x.cantidad *isnull(e.costo,0)*(1+x.igv/100) as margen ,
	x.cantidad*isnull(e.costo,0) as costo_total 
	into #tmp
	-- Select Count(*)
	From #tmp1 x
	Inner join #tmpultprecio e on (x.codpro=e.ItemCode and e.fecha=x.TaxDate ) and x.ItmsGrpCod not in (181,208 ) and x.flgprom='N'
	
	---margen de las promociones calculados desde el precio sin descuento
	insert into #tmp
	Select x.*,isnull(e.costo,0) costo,x.precioant*x.cantidad - isnull(e.costo,0)*x.cantidad  as margensinigv,x.precioant*x.cantidad*(1+x.igv/100) - x.cantidad *isnull(e.costo,0)*(1+x.igv/100) as margen ,
	x.cantidad*isnull(e.costo,0) as costo_total 
	-- Select Count(*)
	From #tmp1 x
	inner join #tmpultprecio e  on (x.codpro=e.ItemCode and e.fecha=x.TaxDate ) and x.ItmsGrpCod not in (181,208 ) and x.flgprom='S'






	---margen de los articulos promocionales
	insert into #tmp
	Select x.*,isnull(e.costo,0) costo,0 as margensinigv,0 as margen ,
	x.cantidad*isnull(e.costo,0) as costo_total 
	-- Select Count(*)
	From #tmp1 x
	inner join #tmpultprecio e  on (x.codpro=e.ItemCode and e.fecha=x.TaxDate ) and x.ItmsGrpCod  in (181,208 ) and x.flgprom='S'


	--- actualizo los descuentos a nivel de cabecera--
	update #tmp 
	set monsinigv=monsinigv*(100 - oinv.DiscPrcnt)/100,total=total*(100 - oinv.DiscPrcnt)/100,	
		margen=precioant*cantidad*(1+igv/100) - Quantity*costo*(1+igv/100)
	From SrvSAP.Roma_Productiva.dbo.oinv 
	Where oinv.docentry=#tmp.docentry and abs(oinv.DiscPrcnt)>0
	    

	-- Drop Table #Result
	Select 'V' Tipo,
	Case When Left(serie, 1)='B' Then 'BV' Else 'FT' End TipDoc,
	codmesa, codprv, codpro, taxdate, substring(codcanal ,3,2) as codsede,
	left(codcli,11) CodCli, coddom, codven, codrut, codfam, codlinea, cndpago, codalm, codcanal,oriped,
	monsinigv, total, margensinigv, margen, cantidad, LineNum, bonificacion, docentry, address, precioant, igv, CodigoPromocion, DiscPrcnt, price, costo
	Into #Result
	-- Select *
	From #tmp
		--select * from #result
	Delete #Result Where codpro Like '%percep%'
		 
	update #tmp
	set margensinigv=Quantity*NumPerMsr*precioant  - costo_total,
		margen=Quantity*NumPerMsr*precioant*(1+#tmp.igv /100)- costo_total*(1+#tmp.igv /100)	,
		pctmargen=case Quantity*NumPerMsr*precioant when 0 then 0 else  ((Quantity*NumPerMsr*precioant  - costo_total)/(Quantity*NumPerMsr*precioant))*100 end
	Where #tmp.flgprom='S' and
		  #tmp.grupo= 'Helados'
	  
    
	update #tmp
	set  pctmargen=case monsinigv when 0 then 0 else  round(margensinigv/monsinigv,4)*100 end
	Where flgprom='N'
		
	Select distinct docentry into #tmpfa From #tmp
	create index idx_fa on #tmpfa(docentry)


	
	Select distinct y.TrgetEntry as docentry,x.TaxDate 
	into #tmpped
	From #ordr x, SrvSAP.Roma_Productiva.dbo.rdr1 y 
	Where x.docentry=y.DocEntry 
	--and YEAR(x.TaxDate)=@numano and  MONTH(x.taxdate)=@nummes
	and Convert(Char(6), x.TaxDate, 112)=@periodo
	
	create index idx_ped on #tmpped(docentry)
	
	Select a.CardCode  as codcli,isnull(a.U_BKS_DOMICILIO,'000')  as coddom,a.Docentry,b.BaseEntry as docentryfact,d.SWW as grupo,'D' as tipo, 
	isnull(c.U_BKP_CODMESA,' ') as codmesa,	isnull(d.CardCode,' ' ) as codprv,	isnull(d.U_BKS_FAMILIA,' ') as codfam,c.SlpCode as  codven ,	
	isnull(c.U_BKP_CANAL,' ') as codcanal ,isnull(f.TaxDate,c.taxdate) as taxdate,b.LineTotal as totalsinigv,	b.GTotal as total,b.Quantity*b.numpermsr*e.costo as costo_total,	
	b.ItemCode as codpro,b.LineTotal - e.costo*b.NumPerMsr*b.Quantity as margensinigv,
	b.Quantity*b.numpermsr*e.costo*(1+b.vatprcnt/100) as costoigv,	b.GTotal - b.Quantity*b.numpermsr*e.costo*(1+b.vatprcnt/100) as margen,
	case isnull(b.U_BKS_boni,'N')  when 'N' then 'N' else 'S' end as flgprom,b.vatprcnt as igv, b.Quantity,b.NumPerMsr,
	CAST(0 as numeric(10,4)) as pctmargen,space(6) as codrut, isnull(d.U_BKS_Linea,SPACE(7)) as  codlinea,a.GroupNum as cndpago,
	b.Quantity*b.numpermsr as cantidad,b.whscode as codalm,(case when b.discPrcnt = 100 then 'B' else 'P' end) bonificacion, b.DiscPrcnt,b.pricebefdi,e.costo,d.ItmsGrpCod, b.U_BKS_CodProm CodigoPromocion , b.price,
	a.U_BKP_TIPO oriped, LineNum, a.[Address]
	into #tmpdev
	-- Select Top 10 *
	From SrvSAP.Roma_Productiva.dbo.ORIN  a 
	inner join SrvSAP.Roma_Productiva.dbo.RIN1 b on (a.DocEntry=b.DocEntry)   
	inner join SrvSAP.Roma_Productiva.dbo.OINV c on (b.BaseEntry =c.DocEntry 
					--and year(c.taxDate)=@numano and MONTH(c.TaxDate)=@nummes)  
					and Convert(Char(6), c.taxDate, 112)=@periodo)  
	inner join #OITM d on (b.ItemCode=d.ItemCode) 
	inner join #tmpped f on (f.docentry= c.DocEntry  )
	inner join #tmpultprecio e on (b.ItemCode=e.ItemCode and  e.fecha=f.TaxDate  )				 
	Where -- not exists (Select 1 From OSLP p Where p.SlpCode=c.SlpCode   and p.slpname  like '%oficina%')
	--and 
	exists (Select 1 From #tmpfa Where #tmpfa.DocEntry=c.docentry )






	Update a Set codprv=b.codprv_homo
	From #tmpdev a
	Inner Join SrvSAP.Roma_Productiva.REPORTES.rel_prv_homologos b On a.codprv = b.codprv 
	And Ltrim(Str(@numano)) + Right('00'+Ltrim(Str(@nummes)), 2) >= b.periodoinicio_homo	
	
	create index idx_dev on  #tmpdev(docentry)
	

	--insert into #tmpdev
	Select a.CardCode  as codcli,isnull(a.U_BKS_DOMICILIO,'000')  as coddom,a.Docentry,b.BaseEntry as docentryfact,d.SWW as grupo,'D' as tipo,
	isnull(c.U_BKP_CODMESA,' ') as codmesa,isnull(d.CardCode,' ' ) as codprv,
	isnull(d.U_BKS_FAMILIA,' ') as codfam,c.slpcode as codven ,isnull(c.U_BKP_CANAL,' ') as codcanal,c.taxdate,b.LineTotal as totalsinigv,
	b.GTotal as total,b.Quantity*b.numpermsr*e.costo as costo_total,	b.ItemCode as codpro,b.LineTotal - e.costo*b.NumPerMsr*b.Quantity as margensinigv,
	b.Quantity*b.numpermsr*e.costo*(1+b.vatprcnt/100) as costoigv,	b.GTotal - b.Quantity*b.numpermsr*e.costo*(1+b.vatprcnt/100) as margen,
	case isnull(b.U_BKS_boni,'N')  when 'N' then 'N' else 'S' end as flgprom,b.vatprcnt as igv,b.Quantity,b.NumPerMsr,
	CAST(0 as numeric(10,4)) as pctmargen,space(6) as codrut, isnull(d.U_BKS_Linea,SPACE(7)) as  codlinea,a.GroupNum as cndpago,
	b.Quantity*b.numpermsr as cantidad,b.whscode as codalm, (case when b.discPrcnt = 100 then 'B' else 'P' end) bonificacion, b.DiscPrcnt, b.pricebefdi,e.costo,d.ItmsGrpCod, b.U_BKS_CodProm CodigoPromocion , b.price,
	a.U_BKP_TIPO oriped, LineNum, a.[Address]
	into #tmpdev1
	From SrvSAP.Roma_Productiva.dbo.ORIN a 
	inner join SrvSAP.Roma_Productiva.dbo.RIN1 b on a.DocEntry=b.DocEntry 	
	inner join SrvSAP.Roma_Productiva.dbo.OINV c on b.BaseEntry=c.DocEntry 
	--and year(c.taxDate)=@numano and MONTH(c.taxDate)=@nummes
	and Convert(char(6), c.taxDate, 112)=@periodo
	inner join #OITM d  on b.ItemCode=d.ItemCode  
	inner join #tmpultprecio e on b.ItemCode=e.ItemCode and  e.fecha=a.TaxDate
	inner join #tmpfa x on x.DocEntry =c.DocEntry 
	
	Update a Set codprv=b.codprv_homo
	From #tmpdev1 a
	Inner Join SrvSAP.Roma_Productiva.REPORTES.rel_prv_homologos b On a.codprv = b.codprv 
	And Ltrim(Str(@numano)) + Right('00'+Ltrim(Str(@nummes)), 2) >= b.periodoinicio_homo		

	DELETE FROM #tmpdev WHERE DOCENTRY IN (1134240,1134241)
	
	-- Parada2 55 Seg


	---*
	create  index idx_dev1 on  #tmpdev1(docentry)
	
	insert into #tmpdev
	Select * From #tmpdev1 a Where not exists (Select 1 From #tmpdev p Where p.docentry=a.docentry  )
    
    -- Print  '12-'+convert(varchar(20),  GETDATE(),114) 
	
	---margen de los articulos normales sin promocion
	update #tmpdev set margensinigv=PriceBefDi*cantidad -  isnull(costo,0)*cantidad,margen=PriceBefDi*cantidad*(1+igv/100) -  isnull(costo,0)*cantidad*(1+igv/100),
	pctmargen=case Quantity*NumPerMsr*PriceBefDi when 0 then 0 else ((Quantity*NumPerMsr*PriceBefDi  - isnull(costo,0)*cantidad)/(Quantity*NumPerMsr*PriceBefDi))*100  end
	Where ItmsGrpCod not in (181,208 ) and flgprom='S'

	update #tmpdev set margensinigv=0,margen=0,pctmargen=0 
	Where ItmsGrpCod  in (181,208 ) and flgprom='S'
	    
    --- Actualiza el descuento a nivel de cabecera
    
    update #tmpdev set totalsinigv=totalsinigv*(100 - ORIN.DiscPrcnt)/100,total=total*(100 - ORIN .DiscPrcnt)/100,
	margen=PriceBefDi*cantidad*(1+igv/100)- costoigv
	From SrvSAP.Roma_Productiva.dbo.ORIN ORIN 
	Where ORIN.docentry=#tmpdev.docentry and abs(ORIN.DiscPrcnt)>0

			
	Insert Into #Result
	Select 'D' as tipo, 'NC' TipDoc, codmesa, codprv, codpro, taxdate, substring(codcanal ,3,2) as codsede, 
	left(codcli,11),
	coddom, codven, codrut, codfam, codlinea, cndpago, codalm, codcanal, Null, totalsinigv, total, margensinigv, 
	margen, cantidad, LineNum, bonificacion, docentry, address, pricebefdi, igv, CodigoPromocion, DiscPrcnt, price, costo
	From #tmpdev
	--select * from #Result

	update #Result set codsede=substring(codalm,3,2) Where codsede='' 

	Select Top 0 * 
	Into #Supervisores
	From SrvSAP.Roma_Productiva.dbo.[@BKS_SUPERVISORES] Where u_tipo = 'J' 

	If @periodo >= 202105
	Begin
		Insert Into #Supervisores
		Select *
		From SrvSAP.Roma_Productiva.dbo.[@BKS_SUPERVISORES] Where u_tipo = 'J' /*And Code != '0084'*/ And u_bks_estatus = 'A'
	End
	Else
	Begin
		Insert Into #Supervisores
		Select *
		From SrvSAP.Roma_Productiva.dbo.[@BKS_SUPERVISORES] Where u_tipo = 'J' /*And Code != '0086'*/ And u_bks_estatus = 'A'
	End


			   
	-- Drop Table #Cuotas
	Select Distinct CodCar, CodVen, CodSup, b.code codjv , codprv--, codgrupo codcat
	Into #Cuotas
	-- Select * 
	From SrvSAP.Roma_Productiva.Reportes.Mov_Cuotas a
	Inner Join #Supervisores b On u_sedes Like '%' + codsede + '%' --And b.code <> '0071'
	Where Periodo = @periodo 
	And b.u_tipo = 'J'

	Create Table #Data (Tipo Char(1), TiDoc Char(2), codmesa Char(3), codprv Varchar(20), codpro Varchar(20), taxdate Date, codsede Char(2),
	CodCli Varchar(20), coddom Char(3), codven Char(5), codrut Varchar(10), codfam Char(10), codlinea Char(20), cndpago Smallint,
	codalm Varchar(10), codcanal Char(2), oriped  Varchar(20), monsinigv Decimal(18, 2), total Decimal(18, 2), margensinigv Decimal(18, 2),
	margen Decimal(18, 2), cantidad Decimal(18, 5), CodCat Char(5), Item Smallint, bonificacion char(1), DocEntry Int, CodSup Char(5), CodJV Char(5),
	nomcat Varchar(50), nomcat_corto Varchar(50), nomcat_corto2 Varchar(50), CodCartera Varchar(10), UME Decimal(18, 5), priceBefDi Decimal(18, 5), 
	VatPrcnt Decimal(18, 5), CodigoPromocion varchar(25), DiscPrcnt Decimal(18, 5), price Decimal(18, 5), costo Decimal(18, 5))
	
	
	-- Drop Table #prvhomo
	Select CodPrv, CodPrv_Homo, PeriodoInicio_Homo
	Into #prvhomo 	
	From SRVSAP.roma_productiva.Reportes.rel_prv_homologos a
	Where @Periodo >= periodoinicio_homo
		
	Select numano, nummes, x.codcat, x.codprv,  codfam, y.nomcat, y.nomcat_corto, y.nomcat_corto2
	Into #relfamcatgrupo
	From SRVSAP.roma_productiva.reportes.relfamcatgrupo x
	Inner Join SRVSAP.roma_productiva.reportes.grupocategoria y On x.codcat=y.codcat and  x.codprv=y.codprv 
	Where numano+nummes= @Periodo
	
	Update a Set codprv = b.codprv_homo	
	From #relfamcatgrupo a
	Inner Join #prvhomo b On a.codprv = b.codprv And @Periodo >= periodoinicio_homo
	
	If convert(char(6), Getdate(), 112)=@periodo
	Begin
		Delete From #Result Where day(taxdate)=Day(Getdate())
	End


	--Select * From #Result where Convert(Char(8), TaxDate, 112)=20220527

	Update #Result Set CodDom = '001'	Where IsNull(coddom, '') = '' And Left(CodCli, 2) = 'EM'
 	Update #Result Set CodDom = '001'	Where IsNull(coddom, '001') = '000' And Left(CodCli, 2) = 'EM'

		

	-- Truncate Table #Data
	Insert Into #Data (Tipo, TiDoc, codmesa, codprv, codpro, taxdate, codsede, CodCli, coddom, codven, codrut, codfam, codlinea, 
	cndpago, codalm, codcanal, oriped, monsinigv, total, margensinigv, margen, cantidad, CodCat, Item, bonificacion, DocEntry, CodSup, CodJV,
	nomcat, nomcat_corto, nomcat_corto2, UME, priceBefDi,VatPrcnt, CodigoPromocion, DiscPrcnt, price, costo)
	Select Tipo, tipdoc, codmesa, a.codprv, codpro, taxdate, codsede, CodCli, coddom, a.codven, codrut, b.codfam, codlinea, 
	cndpago, codalm, Right(codcanal, 2), oriped, 
	(Case When tipo='V' Then 1 Else -1 End)*monsinigv, 
	(Case When tipo='V' Then 1 Else -1 End)*total, 
	margensinigv, 
	margen, 
	(Case When tipo='V' Then 1 Else -1 End)*cantidad, 
	b.codcat, LineNum, bonificacion, DocEntry, IsNull(aa.codsup, '0000'), IsNull(aa.codjv, '0000'),
	Null nomcat, Null nomcat_corto, Null nomcat_corto2,
	xx.FactorUME, precioant, igv, CodigoPromocion, DiscPrcnt, price, costo
	-- Select Count(*)
	-- Select *
	From #Result a
	Inner Join #OITM xx On a.codprv = xx.cardcode And a.codpro = xx.itemcode
	Inner Join #item_unidadvolumenpeso b On a.codprv = b.codprv And a.codpro = b.ItemCode And b.codprv = xx.cardcode And b.itemcode = xx.itemcode
	Left Outer Join #Cuotas aa On a.codven = aa.codven And a.codprv = aa.codprv 	
		
	
	Update #Data Set CodDom = '001'	Where IsNull(coddom, '') = '' And Left(CodCli, 2) = 'EM'
 	Update #Data Set CodDom = '001'	Where IsNull(coddom, '001') = '000' And Left(CodCli, 2) = 'EM'


	
	Insert Into Ventas.DimClientes(CodCli, NomCli, Origen, TiCliente, CodDom, NumDoc, TipDoc)
	Select Distinct codcli, CardName, 'Remuneraciones', 
	Case When Left(codcli, 2) = 'EM' Then 'Interno' Else 'Externo' End, 
	Case When IsNull(coddom, '')='' Then '001' Else coddom End, b.NumDoc, b.TiDoc
	From #Data a
	Inner Join #OCRD b On a.codcli = b.CardCode  Collate SQL_Latin1_General_CP1_CI_AS
	Where Not Exists (Select * From Ventas.DimClientes c 
						Where a.codcli = c.codcli Collate SQL_Latin1_General_CP1_CI_AS
						And a.coddom = c.CodDom Collate SQL_Latin1_General_CP1_CI_AS)
							
	;With dt As (Select CodCli, coddom, Count(distinct Address) Q, Max(address) address From #Result
				Group By CodCli, coddom
				Having Count(distinct Address)=1)
	--Select * 
	Update a Set Direccion = b.address
	From Ventas.DimClientes a 
	Inner Join dt b On a.CodCli = b.CodCli Collate SQL_Latin1_General_CP1_CI_AS And a.CodDom = b.coddom Collate SQL_Latin1_General_CP1_CI_AS
	Where IsNull(a.Direccion, '*') != b.address Collate SQL_Latin1_General_CP1_CI_AS 
		
	Select Distinct DocEntry
	Into #DocEntry_Dev
	From #Data a
	Where Tipo = 'D' And 
	Not Exists (Select * From ventas.DimDocumentos doc 
	Where doc.DocEntry = a.DocEntry And doc.TiDocumento = a.TiDoc)

	If Exists (Select 1 From #DocEntry_Dev)
	Begin
		Insert Into Ventas.DimDocumentos(Serie, Numero, DocEntry, TiDocumento, FeCreate)
		Select Serie, number Numero, DocEntry, 'NC' TiDocumento, Convert(Varchar(8), DocDate, 112) FeCreate
		-- Select *
		From SrvSAP.Roma_Productiva.gproc.v_documents2
		Where TipoDocumento = 'NC'
		And DocEntry In (Select DocEntry From #DocEntry_Dev)
	End
	
	Select Distinct DocEntry
	Into #DocEntry_Ven
	From #Data a
	Where Tipo = 'V' And 
	Not Exists (Select * From ventas.DimDocumentos doc 
		where doc.DocEntry = a.DocEntry And doc.TiDocumento = a.TiDoc)

	If Exists (Select 1 From #DocEntry_Ven)
	Begin
		Insert Into Ventas.DimDocumentos(Serie, Numero, DocEntry, TiDocumento, FeCreate)
		Select Serie, number Numero, DocEntry, 
		Case When TipoDocumento = 'BO' Then 'BV' Else 'FT' End TipoDocumento, 
		Convert(Varchar(8), DocDate, 112) FeCreate
		From SrvSAP.Roma_Productiva.gproc.v_documents2
		Where TipoDocumento In ('BO', 'FA')
		And DocEntry In (Select DocEntry From #DocEntry_Ven)
	End
	
	Update a Set codcanal = '00' From #Data a where oriped = 'VTAOFIC' and codcanal =''
	Update a Set codcanal = '00' From #Data a where codven = 16 and codcanal =''
	
	Update #Data Set codcanal = '01' Where codprv Like 'PM00000027' And codcanal In ('08', '09')
	Update #Data Set codcanal = '07' Where codprv Like 'PM00000027' And codcanal In ('04')
		
	--Select taxdate, sum(total) From #Data where codprv = 'PM00000021' group by taxdate

	Update a Set codcanal = '00'
	From #Data a
	Inner Join #OCRD b On a.codcli = b.cardcode Collate SQL_Latin1_General_CP1_CI_AS
	Where codcanal = '' and Left(CodCli, 2) = 'EM'

	--select * from #data
	--select * from #Data Where CodPrv like '%00027'
	

	Update #Data Set CodCartera = '00000' Where Left(CodCli,2)='EM'
	



	Update #Data Set oriped = 'VTAOFIC' Where oriped Is Null And Left(CodCli, 2) = 'EM'
	Update #Data Set oriped = 'VTAOFIC' Where oriped Is Null And codmesa = '000'
	Update #Data Set oriped = 'VTATOPE' Where oriped Is Null And codmesa <> '000'

	Update a Set CodCartera = '00000'
	From #Data a Where CodCartera = codven
	
	Update a Set CodCartera = '00000'
	From #Data a Where oriped = 'VTAOFIC' And CodCartera Is Null

	Update #Data Set CodCat = '000' Where CodCat Is Null
		
	Drop Table If Exists #XCuotas
	Select Distinct CodCar, CodVen, codprv, CodMesa 
	Into #XCuotas
	From SrvSAP.Roma_Productiva.Reportes.Mov_Cuotas a
	Where Periodo = @pPeriodo
	

	update a
		set a.CodCartera = b.CodCar
	from #Data a
	inner join Ventas.DimVendedores b on a.codven = b.CodVen --and a.codsede  = b.CodSede

	--select * from #result where codven = 2286
	--select * from #data where codven = 2352
	Update #Data Set codsede = 'AP' Where CodCartera In ('HAY05', 'TAY05')
	Update #Data Set codsede = 'AV' Where CodCartera In ('MAY06', 'HAY03', 'TAY06')
	update #Data set CodSup = '0076', CodJV = '0103' where CodCartera = 'TAY06'
	update #Data set CodSup = '0076', CodJV = '0103' where CodCartera = 'TAY05' and codprv in ('PM00000066', 'PM00000091') 
	update #Data set CodSup = '0076', CodJV = '0103' where CodCartera = 'TAY05' and codprv not in ('PM00000066', 'PM00000091')  
	
	
	-----------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------
	update #Data set CodSup = '0076' where CodSup = '0101'
	update #Data set CodJV = '0103' where CodSup = '0076'

	--update #data set codmesa = '025' where codven = 2352 and codmesa = '023' and taxdate = '2023-08-01'
	--update #Data set codven = 1955, codsede = 'AP' where taxdate = '2023-03-22' and codven = 16 and docentry = 9010300 and monsinigv = 17781.00
	--update #Data set codven = 2370 where taxdate between '20230201' and '20230208' and codven = 1593


	---------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------


	Drop Table If Exists #DataFinal
	--CORREGIDO AL MOMENTO DE COMPRAR CONTRA REPORTES.RESPRVDIA_PED
	update ventas.DimDocumentos set Activo = 'No' where numero = 'ANULADO' and tidocumento = 'bv'

	Select Distinct  Convert(Char(8), a.TaxDate, 112) FechaKey, IdSede, IdMesa, can.IdCan IdCanal, 
	prv.IdPrv IdProveedor, IdPro IdProducto, cat.IdCat_xPrv, IdVen IdVendedor, 
	IdCli IdCliente, IdDoc IdDocumento, IsNull(Item, 0) Item, bonificacion,
	Cantidad, monsinigv Total, total TotalIGV, 
	Convert(Char(6), a.TaxDate, 112) PartitionMonth, IdSup, IdJV, car.IdCartera, a.UME,
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(prv.IdPrv)), 3) + Right('000'+Ltrim(Str(cat.IdCat_xPrv)), 3) IdRelGeneral2, 
	'X'+Right('00'+Ltrim(Str(IdSede)), 2) + 
	Right('00'+Ltrim(Str(IdMesa)), 2) + 
	Right('00'+Ltrim(Str(IdCan)), 2) + Right('000'+Ltrim(Str(IdCartera)), 3) +
	Right('000'+Ltrim(Str(prv.IdPrv)), 3) + Right('000'+Ltrim(Str(cat.IdCat_xPrv)), 3) +
	Right('0000'+Ltrim(Str(ven.IdVen)), 4) IdRelGeneral, IdTipoVenta, 0 Item2, priceBefDi,VatPrcnt, CodigoPromocion,DiscPrcnt, price, costo
	Into #DataFinal	
	From #Data a	
	Inner Join Ventas.DimCarteras car On Ltrim(Rtrim(car.CodCartera)) = Ltrim(Rtrim(a.CodCartera))	
	Inner Join ventas.DimDocumentos doc On doc.DocEntry = a.DocEntry And doc.TiDocumento = a.TiDoc and Activo = 'Si'
	Inner Join ventas.DimSedes sede On sede.CodSede = a.codsede
	Inner Join ventas.DimMesas mesa On mesa.codmesa = a.CodMesa
	Inner Join ventas.DimProveedores prv On prv.CodPrv = a.codprv
	Inner Join ventas.DimProductos pro On pro.CodPro = a.codpro 
	Inner Join ventas.DimClientes cli On cli.CodCli = a.CodCli And cli.CodDom = a.coddom
	Inner Join ventas.DimVendedores ven On ven.CodVen = a.codven
	Inner Join ventas.DimCanales can On can.CodCan Collate SQL_Latin1_General_CP1_CI_AS= a.codcanal
	Inner Join ventas.DimCategorias cat On cat.IdPrv = prv.IdPrv And cat.CodCat = a.CodCat
	Inner Join ventas.Dim_vw_Supervisores sup On sup.CodSup Collate SQL_Latin1_General_CP1_CI_AS = a.CodSup
	Inner Join ventas.Dim_vw_Jefes_dVenta jv On jv.CodJV Collate SQL_Latin1_General_CP1_CI_AS = a.CodJV
	Inner Join Ventas.DimTipoVenta tv On a.oriped = tv.TipoVenta
	

	
	;With dt As (Select Distinct IdRelGeneral2, IdSede, IdCanal, IdCartera, IdProveedor, IdCat_xPrv
				From #DataFinal a)
	Insert Into Ventas.DimRelGeneral2(IdRelGeneral, IdSede, IdCanal, IdCar, IdPrv, IdCat_xPrv)
	Select * From dt a
	Where Not Exists (Select * From Ventas.DimRelGeneral2 b Where a.IdRelGeneral2 = b.IdRelGeneral)

	/*
	;With dt As (Select Distinct IdRelGeneral, IdSede, IdMesa, IdCanal, IdCartera, IdProveedor, IdCat_xPrv, IdVendedor From #DataFinal a)
	Insert Into Ventas.DimRelGeneral(IdRelGeneral, IdSede, IdMesa, IdCanal, IdCar, IdPrv, IdCat_xPrv, IdVendedor)
	Select * From dt a
	Where Not Exists (Select * From Ventas.DimRelGeneral b Where a.IdRelGeneral = b.IdRelGeneral)
	*/
	;With dt As (Select distinct IdCartera, NomVen From #DataFinal a
				Inner Join Ventas.DimVendedores b On a.IdVendedor = b.IdVen)
	Update a Set NomVendedor = b.NomVen	
	From Ventas.DimRelGeneral2 a 
	Inner Join dt b On a.IdCar = b.IdCartera
	Where a.NomVendedor Is Null
	--select fechakey, sum(total) from #datafinal where idproveedor = 4 group by fechakey

	

	--Select FechaKey, Count(*) From #DataFinal Group By FechaKey Order By 1 Desc

	;With dt As (Select FechaKey, IdProducto, IdDocumento, ROW_NUMBER() Over(Partition by FechaKey, IdDocumento Order By IdProducto) Cor
			From #DataFinal)
	Update a Set Item2 = Cor
	From #DataFinal a
	Inner Join dt b On a.FechaKey = b.FechaKey And a.IdDocumento = b.IdDocumento And a.IdProducto = b.IdProducto

	Delete Planillas.Fact_Ventas Where Left(FechaKey, 6) = @periodo	

	Insert Into Planillas.Fact_Ventas(FechaKey, IdSede, IdMesa, IdCanal, IdProveedor, IdProducto, IdCat_xPrv, IdVendedor, IdCliente, 
	IdDocumento, Item, bonificacion, Cantidad, Total, TotalIGV, PartitionMonth, IdSupervisor, IdJefe_dVenta, IdCartera, FactorUME, IdRelGeneral2, 
	IdRelGeneral, IdTipoVenta, Item2, priceBefDi, VatPrcnt, CodigoPromocion, DiscPrcnt, price, costo)
	Select Distinct * From #DataFinal a
	--select top 10 * from planillas.fact_ventas
	

	Update a Set TaxDate = Convert(Varchar(20), b.TaxDate, 103)
	From Ventas.DimDocumentos a
	Inner Join SrvSAP.Roma_Productiva.dbo.OINV b On a.DocEntry = b.DocEntry
	Where TiDocumento <> 'NC' And a.TaxDate Is Null


	Update a Set TaxDate = Convert(Varchar(20), b.TaxDate, 103)
	From Ventas.DimDocumentos a
	Inner Join SrvSAP.Roma_Productiva.dbo.ORIN b On a.DocEntry = b.DocEntry
	Where TiDocumento = 'NC' And a.TaxDate Is Null
  
	Set NoCount Off

End

GO


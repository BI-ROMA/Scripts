CREATE PROCEDURE [Reports].[sp_CommissionsMultibrandReport] @Period char(6)

as
begin
	


	--declare @period varchar(6) = 202311
	declare @periodoant varchar(6) = @period-1
	


	drop table if exists #fact_ventas, #fact_cartera, #fact_cobertura, #fact_ventas_ant, 
						 #fact_cuotas, #fact_devoluciones, #factor_proyectado, #comision_venta, 
						 #comision_cobertura, #comision_devolucion, #num_cat, #comision_final


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
			LEFT(FechaKey, 6) Periodo, IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta, SUM(TotalIGV) TotalIGV
	into #fact_ventas 
	from ROMA_DATAMART.ventas.Fact_Ventas
	where left(FechaKey, 6) = @period and ((IdProveedor = 16 and IdCartera = 131) or (IdProveedor <> 16)) and IdMesa not in (5,9,22,23)
	group by 
			left(FechaKey, 6),		  IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta

	--select * from #fact_ventas where IdCartera = 131


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA CARTERA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
			LEFT(FechaKey, 6) Periodo, IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta, COUNT(distinct CodCli) Cartera
	into #fact_cartera
	from ROMA_DATAMART.Ventas.Fact_CarteraInicial_xVendedor 
	where LEFT(FechaKey, 6) = @period and ((IdProveedor = 16 and IdCartera = 131) or (IdProveedor <> 16)) and IdMesa not in (5,9,22,23)
	group by 
			LEFT(FechaKey, 6)		 , IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta



	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA COBERTURA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	;with dt as (
		select  
				left(fechakey, 6) periodo, idmesa, idcartera, idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa, idcliente, sum(TotalIGV) total
		from ROMA_DATAMART.ventas.fact_ventas a
		where left(fechakey, 6) = @period and ((IdProveedor = 16 and IdCartera = 131) or (IdProveedor <> 16)) and IdMesa not in (5,9,22,23)
		group by 
				left(fechakey, 6),		   idmesa, idcartera, idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa, idcliente
		having sum(TotalIGV) > 0
	) 
	select 
			periodo, IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta, COUNT(distinct IdCliente) cobertura,
			(select count(distinct IdCliente) from dt sub where sub.IdCartera = dt.IdCartera and sub.IdProveedor = dt.IdProveedor) cobertura_subtotal,
			(select count(distinct IdCliente) from dt sub where sub.IdCartera = dt.IdCartera) cobertura_total
	into #fact_cobertura 
	from dt
	group by periodo, IdMesa, IdCartera, IdCat_xPrv, IdProveedor, IdSupervisor, IdJefe_dVenta



	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LA VENTA DEL PERIODO ANTERIOR
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
			left(fechakey, 6) periodo, idmesa, idcartera,  idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_ventas_ant 
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @periodoant and ((IdProveedor = 16 and IdCartera = 131) or (IdProveedor <> 16)) and IdMesa not in (5,9,22,23)
	group by 
			left(fechakey, 6),		  idmesa, idcartera,  idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa

	

	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS COTAS DE VENTA Y COBERTURA DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
			left(fechakey, 6) periodo, idmesa, idcar, idcat_xprv, IdPrv, idsupervisor, idjefe_dventa, 
			sum(cuota) cuota, max(CobMeta) cobmeta, max(FactorCob_xLinea) FactorCob
	into #fact_cuotas
	from ROMA_DATAMART.ventas.fact_cuotas
	where left(fechakey, 6) = @period and ((IdPrv = 16 and IdCar = 131) or (IdPrv <> 16)) and IdMesa not in (5,9,22,23)
	group by 	
			left(fechakey, 6),		   idmesa, idcar, idcat_xprv, IdPrv, idsupervisor, idjefe_dventa
	


	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS LAS DEVOLUCIONES DEL PERIODO ACTUAL
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select  
		left(fechakey, 6) periodo, idmesa, idcartera,  idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_devoluciones
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @period and ((IdProveedor = 16 and IdCartera = 131) or (IdProveedor <> 16)) and IdMesa not in (5,9,22,23) and TotalIGV < 0
	group by 
		left(fechakey, 6),		  idmesa, idcartera,  idcat_xprv, IdProveedor, idsupervisor, idjefe_dventa


	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--TRAEMOS EL FACTOR DE PROYECCION DEL PERIODO
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		left(FechaKey,6) periodo, FechaActual, DiasFaltantes, DiasValidosMes,DiasValidosTranscurridos, DiasFeriadosMes,FactorPryMes FactorPry
	into #factor_proyectado
	from ROMA_DATAMART.Ventas.Dim_vw_FactorProyectado

	if (select periodo from #factor_proyectado) <> @Period
		update #factor_proyectado 
			set periodo = @Period, 
			FechaActual = CAST(CONVERT(char(8), @Period + '01', 112) AS date), 
			DiasFaltantes = 0, 
			DiasValidosMes = 25, 
			DiasValidosTranscurridos = 25,
			DiasFeriadosMes = 5, 
			FactorPry = 1

	------------------------------------------------------------------------------------------------------------------------------------------------------
	--CALCULAMOS EL PESO POR CATEGORIA 
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.IdCar, count(distinct b.CodCat) numcat, convert(decimal(10,4), COUNT(distinct b.CodCat)) peso
	into #num_cat
	from #fact_cuotas a 
	inner join ROMA_DATAMART.Ventas.DimCategorias b on a.IdCat_xPrv =  b.IdCat_xPrv
	group by IdCar


	update #num_cat set peso = convert(decimal(10,4), 1/peso)



	------------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE VENTAS
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
			a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv,	a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta,
			isnull(c.TotalIGV,0) vtamesant, isnull(a.cuota, 0) cuota, isnull(b.TotalIGV,0) vta	
	into #comision_venta
	from #fact_cuotas a
	left join #fact_ventas b on a.IdCar = b.IdCartera and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdProveedor and a.IdMesa = b.IdMesa 
	left join #fact_ventas_ant c on a.IdCar = c.IdCartera and a.IdCat_xPrv = c.IdCat_xPrv and a.IdPrv = c.IdProveedor and a.IdMesa = c.IdMesa


	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE COBERTURA
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv, a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta, isnull(a.cobmeta,0) cobmeta, isnull(a.FactorCob,0) FactorCob, 
		isnull(b.cartera,0) cartera, isnull(c.cobertura,0) cobertura, isnull(c.cobertura_subtotal,0) cobertura_subtotal, isnull(c.cobertura_total,0) cobertura_total
	into #comision_cobertura
	from #fact_cuotas a
	left join #fact_cartera b on a.IdCar = b.IdCartera and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdProveedor and a.periodo = b.periodo and a.IdMesa = b.IdMesa
	left join #fact_cobertura c on a.IdCar = c.IdCartera and a.IdPrv = c.IdProveedor and a.IdCat_xPrv = c.IdCat_xPrv and a.IdMesa = C.IdMesa




	------------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE DEVOLUCIONES
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv, a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta, isnull(b.TotalIGV,0) devolucion 
	into #comision_devolucion
	from #fact_cuotas a
	left join #fact_devoluciones b on a.IdCar = b.IdCartera and a.IdPrv = b.IdProveedor and a.periodo = b.periodo and a.IdCat_xPrv = b.IdCat_xPrv and a.IdMesa = b.IdMesa
	

	--select * from #comision_venta
	--select * from #comision_cobertura where idcar = 34
	--select * from #comision_venta
	--select * from #numcat
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--GENERAMOS LA TABLA DE GENERAL DE COMISIONES
	------------------------------------------------------------------------------------------------------------------------------------------------------
	select 
		a.periodo, h.CodSede, h.NomSede, i.CodMesa, i.NomMesa, i.grupo, j.CodCartera,j.NomCartera, kk.CodPrv, 
		kk.NomPrvAbr, k.CodCat, k.NomCat, l.CodCan, l.NomCan, m.CodVen, m.NomVen, n.CodSup, n.NomSup, o.CodJV, o.NomJV,		
		a.vtamesant, 
		sum(a.vtamesant) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubVtaMesAnt,
		sum(a.vtamesant) over (partition by m.codven, n.codsup, i.codmesa, h.codsede) TotalVtaMesAnt,
		a.cuota, 
		sum(a.cuota) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubCuota,
		sum(a.cuota) over (partition by m.codven, n.codsup, i.codmesa, h.codsede) TotalCuota,
		a.vta,
		sum(a.vta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubVta,
		sum(a.vta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalVta,
		(a.vta*FactorPry) VtaPry,
		sum(a.vta*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubVtaPry,
		sum(a.vta*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalVtaPry,
		(a.vta*FactorPry)/a.cuota VtaPryPrc,
		convert(decimal(10,4), 0) SubVtaPryPrc,
		convert(decimal(10,4), 0) TotalVtaPryPrc,
		b.cartera,
		max(b.cartera) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubCartera,
		max(b.cartera) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalCartera,
		b.FactorCob,
		max(b.FactorCob) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubFactorCob,
		max(b.FactorCob) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalFactorCob,
		b.cobmeta,
		max(b.cobmeta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubCobMeta,
		max(b.cobmeta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalCobMeta,
		b.cobertura,
		b.cobertura_subtotal SubCobertura,
		b.cobertura_total TotalCobertura,
		(b.cobertura*FactorPry) CobPry,
		max(b.cobertura_subtotal*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubCobPry,
		max(b.cobertura_total*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalCobPry,
		isnull((b.cobertura*FactorPry) / nullif(b.cobmeta,0),0) CobPryPrc,
		convert(decimal(10,4), 0) SubCobPryPrc,
		convert(decimal(10,4), 0) TotalCobPryPrc,
		c.devolucion,
		sum(c.devolucion) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubDevolucion,
		sum(c.devolucion) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalDevolucion,
		(c.devolucion*FactorPry) devPry,
		sum(c.devolucion*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, kk.CodPrv) SubDevPry,
		sum(c.devolucion*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede ) TotalDevPry,
		isnull((c.devolucion*FactorPry)/(nullif(a.vta,0)*FactorPry),0) devPryPrc,
		convert(decimal(10,4), 0) SubDevPryPrc,
		convert(decimal(10,4), 0) TotalDevPryPrc,
		d.DiasValidosMes, d.DiasValidosTranscurridos, d.DiasFaltantes, 
		e.numcat, e.peso, 
		f.escala, f.excedenteporc, (f.escala*f.factor_xvta) BaseVtaCom, (f.escala*f.factor_xcob) BaseCobCom,
		convert(decimal(18,2), 0) ComVta, convert(decimal(18,2), 0) SubComVta, convert(decimal(18,2), 0) TotalComVta,
		convert(decimal(18,2), 0) ComCob, convert(decimal(18,2), 0) SubComCob, convert(decimal(18,2), 0) TotalComCob, 
		convert(decimal(18,2), 0) ComTotal, convert(decimal(18,2), 0) SubComTotal, convert(decimal(18,2), 0) TotalComTotal, 
		convert(decimal(18,2), 0) Sueldo
	into #comision_final
	from #comision_venta a
	inner join #comision_cobertura b on a.IdCar = b.IdCar and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdPrv
	inner join #comision_devolucion c on a.IdCar = c.IdCar and a.IdCat_xPrv = c.IdCat_xPrv and a.IdPrv = c.IdPrv
	inner join #factor_proyectado d on  a.periodo = d.periodo 
	inner join #num_cat e on a.IdCar = e.IdCar
	inner join ROMA_DATAMART.Ventas.DimComisiones f on a.IdMesa = f.idmesa and IdTipoUser = 1
	inner join ROMA_DATAMART.Ventas.DimMesas i on a.IdMesa = i.IdMesa 
	inner join ROMA_DATAMART.Ventas.DimCarteras j on a.IdCar = j.IdCartera
	inner join ROMA_DATAMART.Ventas.DimCategorias k on a.IdCat_xPrv = k.IdCat_xPrv
	inner join ROMA_DATAMART.ventas.DimProveedores kk on k.IdPrv = kk.IdPrv
	inner join ROMA_DATAMART.Ventas.DimVendedores m on j.CodCartera = m.CodCar and m.Estado = 'A'
	inner join ROMA_DATAMART.Ventas.DimSedes h on m.CodSede = h.CodSede
	inner join ROMA_DATAMART.Ventas.DimCanales l on m.CodCan = l.CodCan
	inner join ROMA_DATAMART.Ventas.Dim_vw_Supervisores n on a.IdSupervisor = n.IdSup
	inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta o on a.IdJefe_dVenta = o.IdJV

	--select * from #comision_final where codven = 1413

	----------------------------------------------------------------------------------------------------
	--Actualizar monto vendedor AP - EGARCIA
	update #comision_final set BaseCobCom = 750, BaseVtaCom = 1750, escala = 2500 where CodVen = 1955
	----------------------------------------------------------------------------------------------------

	update #comision_final set SubVtaPryPrc = SubVtaPry/SubCuota	
	update #comision_final set TotalVtaPryPrc = TotalVtaPry/TotalCuota


	update #comision_final set SubCobMeta = 1 where SubCobMeta = 0
	update #comision_final set TotalCobMeta = 1 where TotalCobMeta = 0
	

	update #comision_final set SubCobPryPrc = SubCobPry/SubCobMeta
	update #comision_final set TotalCobPryPrc = TotalCobPry/TotalCobMeta


	update #comision_final set SubVtaPry = 1 where SubVtaPry = 0
	update #comision_final set TotalVtaPry = 1 where TotalVtaPry = 0
	
	
	update #comision_final set SubDevPryPrc = SubDevPry/SubVtaPry
	update #comision_final set TotalDevPryPrc = TotalDevPry/TotalVtaPry
	


	update  #comision_final 
		set ComVta = BaseVtaCom*peso * (case when VtaPryPrc > 1.20 then 1.20 else VtaPryPrc end) 

	update  #comision_final 
		set ComCob = BaseCobCom*peso * (case when CobPryPrc > 1.20 then 1.20 else CobPryPrc end) 
	


	update #comision_final
		set ComTotal = ComVta + ComCob



	update #comision_final 
		set SubComVta = ( 
				select sum(ComVta)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen and x.CodPrv = #comision_final.CodPrv and x.CodSede = #comision_final.CodSede
		)
	update #comision_final 
		set SubComCob = ( 
				select sum(ComCob)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen and x.CodPrv = #comision_final.CodPrv and x.CodSede = #comision_final.CodSede
		)
	update #comision_final 
		set SubComTotal = ( 
				select sum(ComTotal)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen and x.CodPrv = #comision_final.CodPrv and x.CodSede = #comision_final.CodSede
		)
	



	update #comision_final 
		set TotalComVta = ( 
				select sum(ComVta)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen --and x.CodPrv = #comision_final.CodPrv and x.CodCat = #comision_final.CodCat
		)
	update #comision_final 
		set TotalComCob = ( 
				select sum(ComCob)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen  --and x.CodPrv = #comision_final.CodPrv and x.CodCat = #comision_final.CodCat
		)
	update #comision_final 
		set TotalComTotal = ( 
				select sum(ComTotal)
				from #comision_final x
				where x.CodVen = #comision_final.CodVen --and x.CodPrv = #comision_final.CodPrv and x.CodCat = #comision_final.CodCat
		)


	--select * from #comision_final where CodVen = 2412




	update #comision_final 
		set ComVta = 0, SubComVta = 0, TotalComVta = 0, ComCob = 0, SubComCob = 0, TotalComCob = 0, ComTotal = 0, SubComTotal = 0, TotalComTotal = 0, Sueldo = 0
	where CodCartera in ('HAY07', 'HCH05', 'HIC07')



	update #comision_final set Sueldo = TotalComTotal

	
	delete from [Reports].[CommissionsMultibrandReport]
	where period = @period

	insert into [Reports].[CommissionsMultibrandReport]
	select * from #comision_final
	
end

GO


CREATE procedure [Reports].[sp_CommissionsDeprodecaReport] @Period char(6)
as
begin



	--declare @Period varchar(6) = 202311
	declare @periodoant varchar(6) = @Period -1

	

	drop table if exists #fact_ventas, #fact_cartera, #fact_cobertura, #fact_ventas_ant, 
						 #fact_cuotas, #fact_devoluciones, #factor_proyectado, #comision_venta, 
						 #comision_cobertura, #comision_devolucion, #num_cat, #comision_final



	select  
			LEFT(FechaKey, 6) Periodo, IdMesa, IdCartera,  IdCat_xPrv, 
			IdProveedor, IdSupervisor, IdJefe_dVenta, SUM(TotalIGV) TotalIGV
	into #fact_ventas 
	from ROMA_DATAMART.ventas.Fact_Ventas
	where left(FechaKey, 6) = @Period and IdProveedor = 16
	group by 
			left(FechaKey, 6), IdMesa, IdCartera, IdCat_xPrv,
			IdProveedor, IdSupervisor, IdJefe_dVenta



	select  
			LEFT(FechaKey, 6) Periodo, IdMesa, IdCartera, IdCat_xPrv,
			IdProveedor, IdSupervisor, IdJefe_dVenta, COUNT(distinct CodCli) Cartera
	into #fact_cartera
	from ROMA_DATAMART.Ventas.Fact_CarteraInicial_xVendedor 
	where LEFT(FechaKey, 6) = @Period and IdProveedor = 16
	group by 
			LEFT(FechaKey, 6), IdMesa, IdCartera, IdCat_xPrv,
			IdProveedor, IdSupervisor, IdJefe_dVenta



	
	;with dt as (
		select  
				left(fechakey, 6) periodo, idmesa, idcartera,  idcat_xprv,
				IdProveedor, idsupervisor, idjefe_dventa, idcliente, sum(TotalIGV) total
		from ROMA_DATAMART.ventas.fact_ventas a
		--inner join Ventas.DimClientes b on a.IdCliente = b.IdCli
		where left(fechakey, 6) = @Period and idproveedor = 16
		group by 
				left(fechakey, 6), idmesa, idcartera,  idcat_xprv,  
				IdProveedor, idsupervisor, idjefe_dventa, idcliente--, CodCli
		having sum(TotalIGV) > 0
	) 
	select 
			periodo, IdMesa, IdCartera, IdCat_xPrv,
			IdProveedor, IdSupervisor, IdJefe_dVenta, COUNT(distinct IdCliente) cobertura
	into #fact_cobertura 
	from dt
	group by periodo, IdMesa, IdCartera, IdCat_xPrv,
			IdProveedor, IdSupervisor, IdJefe_dVenta







	select  
			left(fechakey, 6) periodo, idmesa, idcartera,  idcat_xprv, 
			IdProveedor, idsupervisor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_ventas_ant 
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @periodoant and idproveedor = 16
	group by 
			left(fechakey, 6), idmesa, idcartera,  idcat_xprv, 
			IdProveedor, idsupervisor, idjefe_dventa

	

	select 
			left(fechakey, 6) periodo, idmesa, idcar, idcat_xprv, 
			IdPrv, idsupervisor, idjefe_dventa, sum(cuota) cuota, max(CobMeta) cobmeta, max(FactorCob_xLinea) FactorCob
	into #fact_cuotas
	from ROMA_DATAMART.ventas.fact_cuotas
	where left(fechakey, 6) = @Period and idprv = 16
	group by 	
			left(fechakey, 6), idmesa, idcar, idcat_xprv,  
			IdPrv, idsupervisor, idjefe_dventa
	--select * from #fact_cuotas where idven = 31 and idcat_xprv = 61

	select  
		left(fechakey, 6) periodo, idmesa, idcartera,  idcat_xprv, 
		IdProveedor, idsupervisor, idjefe_dventa, sum(totaligv) totaligv
	into #fact_devoluciones
	from ROMA_DATAMART.ventas.fact_ventas 
	where left(fechakey, 6) = @Period and idproveedor = 16 and TotalIGV < 0
	group by 
		left(fechakey, 6), idmesa, idcartera,  idcat_xprv, 
		IdProveedor, idsupervisor, idjefe_dventa


	
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


	select 
		a.idcar,
		COUNT(distinct b.catprv) peso
	into #num_cat
	from #fact_cuotas a 
	inner join ROMA_DATAMART.Ventas.DimCategorias b on a.IdCat_xPrv =  b.IdCat_xPrv
	group by IdCar

	--select * from #num_Cat



	select 
			a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv,
			a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta,
			a.cuota, isnull(c.TotalIGV,0) vtamesant, isnull(b.TotalIGV,0) vta	
	into #comision_venta
	from #fact_cuotas a
	left join #fact_ventas b on a.IdCar = b.IdCartera and a.IdCat_xPrv = b.IdCat_xPrv and 
								a.IdPrv = b.IdProveedor and a.IdMesa = b.IdMesa 
	left join #fact_ventas_ant c on a.IdCar = c.IdCartera and a.IdCat_xPrv = c.IdCat_xPrv and 
								a.IdPrv = c.IdProveedor and a.IdMesa = c.IdMesa



	select 
		a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv, 
		a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta,
		isnull(a.cobmeta,0) cobmeta, isnull(a.FactorCob,0) FactorCob, 
		b.cartera, isnull(c.cobertura,0) cobertura  
	into #comision_cobertura
	from #fact_cuotas a
	left join #fact_cartera b on a.IdCar = b.IdCartera and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdProveedor and 
										   a.periodo = b.periodo and a.IdMesa = b.IdMesa 
	left join #fact_cobertura c on a.IdCar = c.IdCartera and a.IdPrv = c.IdProveedor and 
									a.IdCat_xPrv = c.IdCat_xPrv and a.IdMesa = C.IdMesa
	
	--select * from #comision_cobertura where IdVen = 522
	--select * from #fact_cartera where IdVen = 522
	--select * from #fact_cobertura where IdVendedor = 522
	--select * from #comision_devolucion where IdVendedor = 522


	select 
		a.periodo, a.IdMesa, a.IdCar, a.IdCat_xPrv,
		a.IdPrv, a.IdSupervisor, a.IdJefe_dVenta, isnull(b.TotalIGV,0) devolucion 
	into #comision_devolucion
	from #fact_cuotas a
	left join #fact_devoluciones b on a.IdCar = b.IdCartera and a.IdPrv = b.IdProveedor and 
									  a.periodo = b.periodo and a.IdCat_xPrv = b.IdCat_xPrv
	
	




	select 
		a.periodo, h.CodSede, h.NomSede, i.CodMesa, i.NomMesa, i.grupo, j.CodCartera,j.NomCartera, g.CodPrv, g.NomPrvAbr, k.CodCat, k.NomCat, k.catprv,
		l.CodCan, l.NomCan, m.CodVen, m.NomVen, n.CodSup, n.NomSup, o.CodJV, o.NomJV, a.vtamesant, 

		a.cuota, sum(a.cuota) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) SumCuota,		
		a.vta, sum(a.vta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) SumVta,
		(a.vta*FactorPry) vtaPry, sum(a.vta*FactorPry) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) SumVtaPry,
		(a.vta*FactorPry)/a.cuota VtaPryPrc,
		convert(decimal(10,2), 0) SumVtaPryPrc,

		case when ((a.vta*FactorPry)/a.cuota) >= 0.5 then 1 else 0 end FlagVta, 0 FlagVtaMax, b.cartera, b.FactorCob,

		b.cobertura, max(b.cobertura) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) MaxCobertura,		 
		b.cobmeta, max(b.cobmeta) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) MaxCobmeta,
		(b.cobertura*FactorPry) cobPry, max((b.cobertura*FactorPry)) over (partition by m.codven, n.codsup, i.codmesa, h.codsede, k.catprv order by k.catprv) MaxCobPry,
		ISNULL((b.cobertura*FactorPry)/nullif(b.cobmeta,0),0) cobPryPrc, 
		convert(decimal(10,2), 0) MaxCobPryPrc,

		case when ISNULL((b.cobertura*FactorPry)/nullif(b.cobmeta,0),0) >= 0.5 then 1 else 0 end FlagCob, 0 FlagCobMax,
		c.devolucion, (c.devolucion*FactorPry) devPry, isnull((c.devolucion*FactorPry)/(nullif(a.vta,0)*FactorPry),0) devPryPrc,
		d.DiasValidosMes, d.DiasValidosTranscurridos, d.DiasFaltantes, '' numcat, e.peso, f.escala, f.excedenteporc, 
		(f.escala*F.factor_xvta) BaseVtaCom, (f.escala*f.factor_xcob) BaseCobCom,
		'-' ComVta, 0 SumComVta,
		'-' ComCob, 0 SumComCob,
		0 ComTotal, 0 Sueldo
	into #comision_final
	from #comision_venta a
	inner join #comision_cobertura b on a.IdCar = b.IdCar and a.IdCat_xPrv = b.IdCat_xPrv and a.IdPrv = b.IdPrv --and a.IdCanal = b.IdCanal
	inner join #comision_devolucion c on a.IdCar = c.IdCar and a.IdCat_xPrv = c.IdCat_xPrv and a.IdPrv = c.IdPrv --and a.IdCanal = c.IdCanal
	inner join #factor_proyectado d on  a.periodo = d.periodo 
	inner join #num_cat e on a.IdCar = e.IdCar
	inner join ROMA_DATAMART.Ventas.DimComisiones f on a.IdMesa = f.idmesa and IdTipoUser = 1
	inner join ROMA_DATAMART.Ventas.DimMesas i on a.IdMesa = i.IdMesa 
	inner join ROMA_DATAMART.Ventas.DimCarteras j on a.IdCar = j.IdCartera
	inner join ROMA_DATAMART.Ventas.DimCategorias k on a.IdCat_xPrv = k.IdCat_xPrv
	inner join ROMA_DATAMART.Ventas.DimProveedores g on k.IdPrv = g.IdPrv
	inner join ROMA_DATAMART.Ventas.DimVendedores m on j.CodCartera = m.CodCar and m.Estado = 'A' and CodCar <> 'TAY05'
	inner join ROMA_DATAMART.Ventas.DimSedes h on m.CodSede = h.CodSede
	inner join ROMA_DATAMART.Ventas.DimCanales l on m.CodCan = l.CodCan
	inner join ROMA_DATAMART.Ventas.Dim_vw_Supervisores n on a.IdSupervisor = n.IdSup
	inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta o on a.IdJefe_dVenta = o.IdJV
	--select * from #comision_final where codven = 1955 order by nomcat 
	--select * from ventas.dimvendedores
	--select * from ventas.DimCategorias
	

	--update #comision_final set escala = 2500, BaseVtaCom = 1750 , BaseCobCom = 750 where CodCartera = 'TAY05'
	--update #comision_final set CodMesa = '025', NomMesa = 'MACEDONICA - AY', grupo = 'MACEDONICA' where CodCartera = 'TAY05'


	update  #comision_final 
		set SumVtaPryPrc = SumVtaPry/SumCuota

	update  #comision_final 
		set MaxCobPryPrc = MaxCobPry/MaxCobMeta

	
	update  #comision_final 
		set SumComVta = BaseVtaCom/peso * (case when SumVtaPryPrc > 1.20 then 1.20 else SumVtaPryPrc end) 

	update  #comision_final 
		set SumComCob = BaseCobCom/peso * (case when MaxCobPryPrc > 1.20 then 1.20 else MaxCobPryPrc end) 





	update #comision_final
		set FlagVtaMax = SubQuery.FlagVtaMax
	from
		(
			select 
				CodVen, catprv, FlagVta,
				MIN(FlagVta) over (partition by CodVen, catprv ) FlagVtaMax
			from #comision_final
		) as SubQuery
	where #comision_final.catprv = SubQuery.catprv and #comision_final.CodVen = SubQuery.CodVen
	
	

	update #comision_final
		set FlagCobMax = SubQuery.FlagCobMax
	from
		(
			select 
				CodVen, catprv, FlagCob,
				MIN(FlagCob) over (partition by CodVen, catprv ) FlagCobMax
			from #comision_final
		) as SubQuery
	where #comision_final.catprv = SubQuery.catprv and #comision_final.CodVen = SubQuery.CodVen
	


	update #comision_final
		set SumComVta = 0
	where FlagVtaMax = 0

	update #comision_final
		set SumComCob = 0
	where FlagCobMax = 0

	update #comision_final
		set ComTotal = SumComVta + SumComCob


	;with 
		dt 
		as 
			(
				select codven, codsup, codmesa, codsede, catprv, max(ComTotal) ComTotal
				from #comision_final
				group by codven, codsup, codmesa, codsede, catprv
			),
		dr
		as
			(
				select codven, sum(ComTotal) Sueldo from dt GROUP BY CodVen
			) 
		update a
		set a.sueldo = dr.Sueldo
		from #comision_final a
		inner join dr on a.CodVen = dr.CodVen
		where a.periodo = @Period



	delete from Reports.CommissionsDeprodecaReport where periodo = @Period



	insert into Reports.CommissionsDeprodecaReport
	select * from #comision_final 
	order by catprv desc


	
end

GO


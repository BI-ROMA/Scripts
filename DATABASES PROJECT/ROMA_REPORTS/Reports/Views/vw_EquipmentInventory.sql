








create view  [Reports].[vw_EquipmentInventory]
as

(
		SELECT   
			a.cardcode codcliente,
			e.cardname cliente,
			a.domi,	
			g.street address,
			i.CardCode codproveedor,
			i.cardname proveedor,
			c.name marca,
			d.name modelo,
			a.serie,
			a.estado,
			a.inuse,
			a.created_at,
			a.verified,
			a.verified_at,
			a.verified_by,
			a.closedAt,
			a.closedBy,
			a.closeMemo,
			a.closeReason,
			b.isDown,
			b.downAt,
			a.id_cartera,
			f.slpcode codven,
			f.slpname nomven,
			f.U_BKS_CodSed sede,
			f.U_BKS_CODSUP codsup,
			h.name nomsup,
			d.cuota*1.18 cuota,
			a.createdBy
			--select *
		FROM srvsap.roma_productiva.comodato.asignados a
		inner join srvsap.roma_productiva.comodato.equipo b on a.equipo = b.id  
		inner join srvsap.roma_productiva.comodato.marca c on b.marca = c.id
		inner join srvsap.roma_productiva.comodato.modelo d on b.modelo = d.id
		inner join srvsap.roma_productiva.dbo.ocrd i on i.cardcode = b.cardcode
		inner join srvsap.roma_productiva.dbo.ocrd e on a.cardcode = e.cardcode
		inner join srvsap.roma_productiva.dbo.oslp f on f.U_BKS_CodCart = a.id_cartera and f.U_BKS_ESTATUS = 'A'
		inner join srvsap.roma_productiva.dbo.crd1 g on g.cardcode = e.cardcode and adrestype = 'S' and isnull(g.U_BKS_CodDom,'001') = a.domi 
		inner join srvsap.roma_productiva.dbo."@BKS_SUPERVISORES" h on h.Code = f.U_BKS_CODSUP
)

GO


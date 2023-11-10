





CREATE View [Gloria].[vw_ItemsxLineaxOrden]
As
	SELECT a.CardCode,
		   a.ItemName,
		   a.ItemCode,
		   a.valor1,
		   a.peso,
		   a.volumen,
		   a.U_bks_categoria,
		   a.U_BPP_TIPUNMED,
		   a.U_BKS_FAMILIA,
		   a.U_BKS_MARCA,
		   a.U_BKS_Linea,
		   a.Linea,
		   a.U_BKS_MARCANombre,
		   IsNull(a.LineaRW, 'No Definido') LineaRW,
		   a.Valor2,
		   a.FactorUMES,
		   a.FactorUMES2,
		   999 Orden,
		   IsNull(a.Categoria, 'No Definido') Categoria,
		   IsNull(a.Marca, 'No Definido') Marca,
		   IsNull(a.Familia, 'No Definido') Familia,
		   CASE
			   WHEN a.Contenido IS NULL THEN 'No Definido'
			   ELSE a.Contenido + CASE
									  WHEN a.envase IS NOT NULL THEN ' (' + a.envase + ')'
									  ELSE ''
								  END
		   END Contenido,
		   a.Envase
	FROM SrvSAP.dw.Reportes.vw_Item_UnidadVolumenPeso a
	--LEFT JOIN Gloria.Orden_Linea b ON a.linearw = b.LINEA
	WHERE CardCode = 'PM00000066'

GO


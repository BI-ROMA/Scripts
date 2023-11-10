




CREATE VIEW [Reports].[vw_SupplierCategoryProduct]
AS

	select 
		a.IdPro ProductId, 
		a.CodPro ProductCode, 
		a.NomPro ProductName, 
		b.IdCat_xPrv CategoryId, 
		b.CodCat CategoryCode, 
		b.NomCat CategoryName, 
		c.IdPrv SupplierId, 
		c.CodPrv SupplierCode, 
		c.NomPrv SupplierName,
		c.u_login SupplierLogin
	from ROMA_DATAMART.Ventas.DimProductos a
	left join ROMA_DATAMART.Ventas.DimCategorias b on a.IdCat_xPrv = b.IdCat_xPrv
	left join ROMA_DATAMART.Ventas.DimProveedores c on b.IdPrv = c.IdPrv

GO


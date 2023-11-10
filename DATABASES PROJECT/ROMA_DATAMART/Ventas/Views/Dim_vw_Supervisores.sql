





CREATE   View [Ventas].[Dim_vw_Supervisores]
As
	Select 
		Convert(Smallint, Code) IdSup, 
		Code CodSup, 
		Name NomSup, 
		U_bks_codigo CodSupSAP, 
		u_login, 
		'DSROMASAC\' + u_login u_loginFull,
		u_bks_estatus EstSup,
		u_sedes Sedes
	From SrvSAP.Roma_Productiva.dbo.[@BKS_SUPERVISORES]
	--Where u_tipo ='C' 

GO


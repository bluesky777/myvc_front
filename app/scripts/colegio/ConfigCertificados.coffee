angular.module('myvcFrontApp')

.directive('configuracionCertificados',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}colegio/configCertificados.tpl.html"


	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
	controller: 'ConfigCertificadosCtrl'

])

.controller 'ConfigCertificadosCtrl', ['$scope', 'App', 'Restangular', '$state', '$cookies', '$rootScope', 'uiGridConstants', '$filter', ($scope, App, Restangular, $state, $cookies, $rootScope, uiGridConstants, $filter) ->

	#console.log 'Configurando certificados'
	$scope.newcertif = {
		encabezado_width: 0
		encabezado_height: 0
		encabezado_margin_top: 0
		encabezado_margin_left: 0
		piepagina_width: 0
		piepagina_height: 0
		piepagina_margin_bottom: 0
		piepagina_margin_left: 0
	}
	$scope.creando_certificado = false
	$scope.editando = false
	$scope.currentCertif = {}
	$scope.certificado = {}

	
	certs = $filter('filter')($scope.certificados, {id: $scope.year.config_certificado_estudio_id})
	if certs
		if certs.length > 0	
			$scope.certificado.config_actual = certs[0]	


	$scope.crearConfig = ()->
		$scope.creando_certificado = true
	
	$scope.cancelConfig = ()->
		$scope.creando_certificado = false



	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: false,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'nombre', displayName:'Nombre', enableSorting: false, enableColumnMenu: false }
			{ name: 'edicion', displayName:'Edición', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'encabezado_width', displayName:'AnchoE', filter: { condition: uiGridConstants.filter.CONTAINS } }
			{ field: 'encabezado_height', displayName:'AltoE', filter: { condition: uiGridConstants.filter.CONTAINS } }
			{ field: 'encabezado_margin_top', displayName:'MargenEArr', filter: { condition: uiGridConstants.filter.CONTAINS } }
			{ field: 'encabezado_margin_left', displayName:'MargenEIzq', filter: { condition: uiGridConstants.filter.CONTAINS } }
			{ field: 'piepagina_width', displayName:'AnchoP'}
			{ field: 'piepagina_height', displayName:'AltoP'}
			{ field: 'piepagina_margin_left', displayName:'MargenPIzq'}
			{ field: 'piepagina_margin_bottom', displayName:'MargenPAba'}
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue

					Restangular.one('certificados/update').customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Certificado modificado', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
					)

				$scope.$apply()
			)

	

	$scope.gridOptions.data = $scope.certificados;




	$scope.guardar = ()->
		Restangular.one('certificados/store').customPOST($scope.newcertif).then((r)->
			$scope.toastr.success 'Certificado creado.'
			$scope.creando_certificado = false
			$scope.certificados.push r 
			$scope.gridOptions.data = $scope.certificados
		, (r2)->
			$scope.toastr.error 'Certificado no guardado', 'Error'
		)
		


	$scope.editar = (certif)->
		$scope.editando = true
		$scope.currentCertif = certif
		enc_img = $filter('filter')($scope.imagenes, {id: certif.encabezado_img_id})
		pie_img = $filter('filter')($scope.imagenes, {id: certif.piepagina_img_id})

		if enc_img.length > 0
			enc_img = enc_img[0]
			$scope.currentCertif.encabezado_img = enc_img

		if pie_img.length > 0
			pie_img = pie_img[0]
			$scope.currentCertif.piepagina_img = pie_img
	
		

	$scope.cancelEdit = ()->
		$scope.editando = false
		

	$scope.actualizar = ()->
		Restangular.one('certificados/update').customPUT($scope.currentCertif).then((r)->
			$scope.toastr.success 'Certificado modificado', 'Actualizado'
			$scope.editando = false
		, (r2)->
			$scope.toastr.error 'Cambio no guardado', 'Error'
		)
		
		

	$scope.eliminar = (certif)->
		Restangular.one('certificados/destroy/'+certif.id).customDELETE().then((r)->
			$scope.toastr.success 'Certificado eliminado.'
			$scope.certificados = $filter('filter')($scope.certificados, {id: '!'+certif.id})
			$scope.gridOptions.data = $scope.certificados
		, (r2)->
			$scope.toastr.error 'Certificado no eliminado', 'Error'
		)
		

	$scope.certificadoSelect = ($item, $model)->
		Restangular.one('certificados/actual').customPUT({config_certificado_estudio_id: $item.id, year_id: $scope.year.id}).then((r)->
			$scope.toastr.success 'Certificado actual cambiado.'
		, (r2)->
			$scope.toastr.error 'Certificado no cambiado', 'Error'
		)



	return
]

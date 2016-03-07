angular.module("myvcFrontApp")

.controller('BitacoraCtrl', ['$scope', 'toastr', '$state', '$http', 'uiGridConstants', 'AuthService', ($scope, toastr, $state, $http, uiGridConstants, AuthService)->
	$scope.data = {} # Para el popup del Datapicker

	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$http.get('::contratos').then((r)->
		$scope.contratos = r.data
	, (r2)->
		toastr.error 'No se trajeron los profesores contratados'
	)


	$http.get('::bitacoras').then((r)->
		$scope.gridOptions.data = r.data
	, (r2)->
		toastr.error 'No se pudo traer la bitácora'
	)


	$scope.seleccionaProfe = (item, model)->

		$http.get('::bitacoras/index/'+item.user_id).then((r)->
			$scope.gridOptions.data = r.data
		, (r2)->
			toastr.error 'No se pudo traer la bitácora'
		)




	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', width: 60 }
			{ name: 'edicion', displayName:'Edición', width: 40, enableSorting: false, enableFiltering: false, cellTemplate: btGrid2, enableCellEdit: false}
			{ field: 'descripcion', displayName:'Descripción', filter: {condition: uiGridConstants.filter.CONTAINS} }
			{ field: 'affected_element_type', displayName:'Tipo', minWidth: 80, filter: {condition: uiGridConstants.filter.CONTAINS} }
			{ field: 'affected_element_old_value_int', displayName:'Anterior'}
			{ field: 'affected_element_new_value_int', displayName:'Nuevo'}
			{ field: 'created_at', displayName:'Fecha', width: 150, filter: {condition: uiGridConstants.filter.CONTAINS} }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	



])
angular.module("myvcFrontApp")

.controller('BitacoraCtrl', ['$scope', '$rootScope', '$state', 'Restangular', 'uiGridConstants', ($scope, $rootScope, $state, Restangular, uiGridConstants)->
	$scope.data = {} # Para el popup del Datapicker


	Restangular.all('contratos').getList().then((r)->
		$scope.contratos = r
	, (r2)->
		$scope.toastr.error 'No se trajeron los profesores contratados'
	)


	Restangular.all('bitacoras').getList().then((r)->
		$scope.gridOptions.data = r
	, (r2)->
		$scope.toastr.error 'No se pudo traer la bitácora'
	)


	$scope.seleccionaProfe = (item, model)->

		Restangular.all('bitacoras/index/'+item.user_id).getList().then((r)->
			$scope.gridOptions.data = r
		, (r2)->
			$scope.toastr.error 'No se pudo traer la bitácora'
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
			{ field: 'affected_person_name', displayName:'Afectado', width: 200, filter: {condition: uiGridConstants.filter.CONTAINS} }
			{ field: 'created_at', displayName:'Fecha', width: 150, filter: {condition: uiGridConstants.filter.CONTAINS} }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	



])
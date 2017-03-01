'use strict'

angular.module('myvcFrontApp')
.controller 'NivelesCtrl', ['$scope', '$filter', '$state', 'toastr', '$http', ($scope, $filter, $state, toastr, $http) ->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.editar = (row)->
		$state.go('panel.niveles.editar', {nivel_id: row.id})

	$scope.eliminar = (row)->
		$htt.delete('niveles_educativos/'+row.id).then((r)->
			$scope.niveles = $filter('filter')($scope.niveles, {id: '!'+r.data.id})
			$scope.gridOptions.data = $scope.niveles
		, (r)->
			toastr.warning 'No se pudo eliminar.'
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'orden', type: 'number', maxWidth: 50, enableSorting: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName:'Abreviatura' }
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$http.put('::niveles_educativos/'+rowEntity.id, rowEntity).then((r)->
						toastr.success 'Nivel actualizado', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)

	

	$http.get('::niveles_educativos').then((data)->
		$scope.niveles = data.data
		$scope.gridOptions.data = $scope.niveles
	)
	return
]

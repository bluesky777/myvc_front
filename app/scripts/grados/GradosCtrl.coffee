'use strict'

angular.module('myvcFrontApp')
.controller('GradosCtrl', ['$scope', '$filter', '$state', 'App', 'niveles', '$uibModal', 'toastr', '$http', ($scope, $filter, $state, App, niveles, $modal, toastr, $http) ->


	$scope.grados = {nivel: {}}
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.niveles = niveles

	$scope.editar = (row)->
		$state.go('panel.grados.editar', {grado_id: row.id})

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: '==grados/removeGrado.tpl.html'
			controller: 'RemoveGradoCtrl'
			size: 'sm',
			resolve: 
				grado: ()->
					row
		})
		modalInstance.result.then( (grado)->
			$scope.grados = $filter('filter')($scope.grados, {id: '!'+grado.id})
			$scope.gridOptions.data = $scope.grados
		)


	editNivel = "==grados/editCellNivel.tpl.html"

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName:'abreviatura', maxWidth: 50, enableSorting: false }
			{ field: 'orden', type: 'number', maxWidth: 50 }
			{ field: 'nivel_educativo_id', displayName: 'Nivel Educativo', editDropdownOptionsArray: niveles, cellFilter: 'mapNivel:grid.appScope.niveles', editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombre' }
			{ name: 'nn', displayName: '', maxWidth: 20, enableSorting: false, enableFiltering: false }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$http.put('::grados/update/'+rowEntity.id, rowEntity).then((r)->
						toastr.success 'Grado actualizado con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)
			


	$http.get('::grados').then((data)->
		$scope.grados = data.data
		$scope.gridOptions.data = $scope.grados;
	)

	$scope.$on 'gradocreado', (ev, grado)->
		$scope.grados.push grado
		$scope.gridOptions.data = $scope.grados;


	return
])

.filter('mapNivel', ['$filter', ($filter)->

	return (input, niveles)->
		if not input
			return ''
		else
			niv = $filter('filter')(niveles, {id: input})[0]
			return  niv.nombre
])



.controller('RemoveGradoCtrl', ['$scope', '$uibModalInstance', 'grado', '$http', 'toastr', ($scope, $modalInstance, grado, $http, toastr)->
	$scope.grado = grado

	$scope.ok = ()->

		$http.delete('::grados/destroy/'+grado.id).then((r)->
			toastr.success 'Grado ' + r.nombre + ' eliminado con éxito', 'Eliminado'
		, (r)->
			toastr.error 'No se pudo eliminar a '+row.nombre
		)
		$modalInstance.close(grado)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
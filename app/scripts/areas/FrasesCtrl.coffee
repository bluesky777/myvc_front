angular.module("myvcFrontApp")

.controller('FrasesCtrl', ['$scope', 'toastr', '$filter', '$http', '$uibModal', 'App', 'AuthService', ($scope, toastr, $filter, $http, $modal, App, AuthService)->

	AuthService.verificar_acceso()

	$scope.currentFrase = {}
	$scope.currentFraseEdit = {}
	$scope.creando = false
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.tipos = [
		{tipo_frase:	'Debilidad'}
		{tipo_frase:	'Amenaza'}
		{tipo_frase:	'Oportunidad'}
		{tipo_frase:	'Fortaleza'}
	]

	$scope.currentFrase.tipo_frase = 
		tipo_frase: 'Fortaleza'

	$scope.cancelarCrear = ()->
		$scope.creando = false

	$scope.crear = ()->
		$http.post('::frases/store', $scope.currentFrase).then((r)->
			$scope.gridOptions.data.push r.data
			$scope.currentFrase.frase = ''
			$scope.cancelarCrear()
			toastr.success 'Frase creada con éxito'
		, (r2)->
			toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		$http.put('::frases/update/'+$scope.currentFraseEdit.id, $scope.currentFraseEdit).then((r)->
			$scope.currentFraseEdit.frase = r.data.frase # Para actualizar el grid
			toastr.success 'Frase actualizada con éxito'
		, (r2)->
			toastr.error 'Error guardando', 'Problema'
		)

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'areas/removeFrase.tpl.html'
			controller: 'RemoveFraseCtrl'
			resolve: 
				frase: ()->
					row
		})
		modalInstance.result.then( (frase)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+frase.id})
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', width: 70, enableCellEdit: false }
			{ name: 'edicion', displayName:'Edición', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: btGrid2, enableCellEdit: false}
			{ field: 'tipo_frase', displayName:'Tipo', width: 90, enableCellEdit: false }
			{ field: 'frase', displayName:'Frase', minWidth: 300 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$scope.currentFraseEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	$http.get('::frases').then((data)->
		$scope.gridOptions.data = data.data
	)

])

.controller('RemoveFraseCtrl', ['$scope', '$uibModalInstance', 'frase', '$http', 'toastr', ($scope, $modalInstance, frase, $http, toastr)->
	$scope.frase = frase

	$scope.ok = ()->

		$http.delete('::frases/destroy/'+frase.id).then((r)->
			toastr.success 'frase "'+frase.frase+'" eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar la frase.'
		)
		$modalInstance.close(frase)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


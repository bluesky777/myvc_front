angular.module("myvcFrontApp")

.controller('ListAlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', 'Restangular', '$filter', ($scope, App, $rootScope, $state, Restangular, $filter)->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.dato = {}

	$scope.traerListado = (grupo_id)->
		if not grupo_id
			grupo_id = $scope.dato.grupo.id
		else if grupo_id.id
			grupo_id = grupo_id.id

		Restangular.one('grupos/listado', grupo_id).getList().then((r)->
			$scope.gridOptions.data = r
			
		, (r2)->
			console.log 'No se pudo traer el listado', r2
		)

	if $state.params.grupo_id
		$scope.traerListado($state.params.grupo_id)

	Restangular.one('grupos').getList().then((r)->
		$scope.grupos = r
		gr = $filter('filter')(r, {id: $state.params.grupo_id})
		$scope.dato = {
			grupo: gr[0]
		}
	, ()->
		console.log 'No se pudo traer los grupos'
	)

	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'username', displayName: 'Usuario'}
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'direccion', displayName: 'Dirección' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('alumnos/update', rowEntity.alumno_id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Alumno actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

])
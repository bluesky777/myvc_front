angular.module("myvcFrontApp")

.controller('ListAlumnosCtrl', ['$scope', 'toastr', '$state', '$http', '$filter', ($scope, toastr, $state, $http, $filter)->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.dato = {}

	$scope.traerListado = (grupo_id)->
		if not grupo_id
			grupo_id = $scope.dato.grupo.id
		else if grupo_id.id
			grupo_id = grupo_id.id

		$http.get('::grupos/listado/'+grupo_id).then((r)->
			$scope.gridOptions.data = r.data
		, (r2)->
			toastr.error 'No se pudo traer el listado'
		)

	if $state.params.grupo_id
		$scope.traerListado($state.params.grupo_id)

	$http.get('::grupos').then((r)->
		$scope.grupos = r.data
		gr = $filter('filter')($scope.grupos, {id: $state.params.grupo_id})
		$scope.dato = {
			grupo: gr[0]
		}
	, ()->
		toastr.error 'No se pudo traer los grupos'
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
				
				if newValue != oldValue
					$http.put('::alumnos/update/'+rowEntity.alumno_id, rowEntity).then((r)->
						toastr.success 'Alumno actualizado con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)

])
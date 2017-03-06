'use strict'

angular.module("myvcFrontApp")

.controller('AcudientesCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', 'uiGridConstants', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http, uiGridConstants)->

	AuthService.verificar_acceso()

	$scope.dato = {}
	$scope.gridOptions = {}
	$scope.perfilPath 				= App.images+'perfil/'
	$scope.views 					= App.views
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid



	$scope.dato.grupo = ''
	
	$http.get('::grupos').then((r)->

		acud_grupo = 0

		if localStorage.acud_grupo 
			acud_grupo = parseInt(localStorage.acud_grupo)

		$scope.grupos = r.data

		for grupo in $scope.grupos
			if grupo.id == acud_grupo
				$scope.dato.grupo = grupo

		$scope.traerAcudientes($scope.dato.grupo)

	)


	$scope.onGrupoSelect = ($item, $model)->
		if not $item
			return

		localStorage.setItem('acud_grupo', $item.id)
		$scope.traerAcudientes($item)


	
	$scope.editar = (row)->
		console.log row
		$state.go('panel.acudientes.editar', {acudiente_id: row.acudiente_id})


	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btPazysalvo = "==directives/botonesPazysalvo.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEdit: true,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ name: 'no', displayName:'No', width: 45, enableCellEdit: false, enableColumnMenu: false, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row)+1}}</div>'}
			{ name: 'edicion', displayName:'Edición', width: 30, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'foto_nombre', displayName:'Foto', cellTemplate: "<img width=\"35px\" ng-src=\"{{grid.appScope.perfilPath + grid.getCellValue(row, col)}}\">", width: 40}
			{ field: 'nombres', minWidth: 80,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false }
			{ field: 'apellidos', minWidth: 80, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', width: 60 }
			{ field: 'nombre_grupo', displayName:'Grupo' }
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, minWidth: 150 }
			# { field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'deuda', displayName: 'Deuda', cellTemplate: btPazysalvo, minWidth: 150 }
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue

					if colDef.field == "sexo"
						if newValue == 'M' or newValue == 'F'
							# Es correcto...
							$http.put('::alumnos/update/'+rowEntity.alumno_id, rowEntity).then((r)->
								toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
							, (r2)->
								toastr.error 'Cambio no guardado', 'Error'
							)
						else
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
					else

						$http.put('::alumnos/update/'+rowEntity.alumno_id, rowEntity).then((r)->
							toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
						)

				$scope.$apply()
			)

	
	


	$scope.traerAcudientes = (item)->
		
		$http.put("::acudientes/datos", {grupo_actual: item}).then((r)->
			$scope.gridOptions.data = r.data

			$scope.gridOptions.columnDefs[6].visible = false
			$scope.gridApi.grid.refresh()
		)



	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		$http.put('::alumnos/update/' + fila.alumno_id, fila).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			toastr.error 'Cambio no guardado', 'Error'
		)
		
	
	$scope.resetPass = (row)->
		
		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)








	return
])


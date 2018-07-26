'use strict'

angular.module("myvcFrontApp")

.controller('CarteraCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', 'uiGridConstants', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http, uiGridConstants)->

	AuthService.verificar_acceso()

	$scope.dato = {}
	$scope.gridOptions = {}
	$scope.perfilPath 				= App.images+'perfil/'
	$scope.views 					= App.views
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid



	$scope.dato.grupo = ''

	$http.get('::grupos').then((r)->

		matr_grupo = 0

		if localStorage.matr_grupo
			matr_grupo = parseInt(localStorage.matr_grupo)

		$scope.grupos = r.data

		for grupo in $scope.grupos
			if grupo.id == matr_grupo
				$scope.dato.grupo = grupo

		$scope.traerAlumnos($scope.dato.grupo)

	)


	$scope.onGrupoSelect = ($item, $model)->
		if not $item
			return

		localStorage.setItem('matr_grupo', $item.id)
		$scope.traerAlumnos($item)



	$scope.editar = (row)->
		console.log row.alumno_id
		$state.go('panel.cartera.editar', {alumno_id: row.alumno_id})


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

					if not rowEntity.alumno_id
						rowEntity.alumno_id = fila.id

					$http.put('::alumnos/guardar-valor', {alumno_id: rowEntity.alumno_id, propiedad: colDef.field, valor: newValue } ).then((r)->
						toastr.success 'Alumno(a) actualizado con éxito'
					, (r2)->
						rowEntity[colDef.field] = oldValue
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)





	$scope.traerAlumnos = (item)->

		$http.put("::cartera/alumnos", {grupo_actual: item}).then((r)->
			$scope.gridOptions.data = r.data

			$scope.gridOptions.columnDefs[6].visible = false
			$scope.gridApi.grid.refresh()
		)



	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			propiedad: 	'pazysalvo'
			valor: 		fila.pazysalvo

		$http.put('::alumnos/guardar-valor', datos).then((r)->
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



	$scope.traerSoloDeudores = (row)->

		$http.put("::cartera/solo-deudores", {year_id: $scope.USER.year_id }).then((r)->
			$scope.gridOptions.data = r.data

			$scope.gridOptions.columnDefs[6].visible = true
			$scope.gridApi.grid.refresh()
		)







	return
])


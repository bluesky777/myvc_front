'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'RAlumnos', 'Restangular', 'uiGridConstants', 'GruposServ', '$modal', '$filter', ($scope, App, $rootScope, $state, $interval, RAlumnos, Restangular, uiGridConstants, GruposServ, $modal, $filter)->

	$scope.bigLoader = true
	$scope.dato = {}
	$scope.dato.mostrartoolgrupo = true
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	stop = $interval( ()->
		$scope.bigLoader = false
	, 1000)

	$scope.dato.grupo = {nombre: ''}
	GruposServ.getGrupos().then((r)->
		$scope.grupos = r

	)

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			size: 'sm',
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
			console.log 'Resultado del modal: ', alum
		)

	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			$scope.toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = {alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id}
		
		console.log 'Argumentos: ', datos

		Restangular.all('matriculas/matricularuno/'+datos.alumno_id+'/'+datos.grupo_id).post().then((r)->
			console.log 'Matriculado. ', r
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.nombregrupo = $scope.dato.grupo.nombre
			row.abrevgrupo = $scope.dato.grupo.abrev
			row.actual = 1
			$scope.toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			console.log 'Falla al matricularlo. ', r2
			$scope.toastr.error 'No se pudo matricular el alumno.', 'Error'

		)

	$scope.eliminarMatricula = (row)->
		console.log row

		Restangular.all('matriculas/destroy/'+row.matricula_id).remove().then((r)->
			console.log 'Desmatriculado. ', r
			row.currentyear = 0
			$scope.toastr.success 'Alumno desmatriculado'
			return row
		, (r2)->
			console.log 'No se pudo desmatricular.', r2
			$scope.toastr.error 'No se pudo desmatricular', 'Problema'
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	btMatricular = "#{App.views}directives/botonesMatricular.tpl.html"

	headerGroup = """
				<div ng-class="{ 'sortable': sortable }">
				<div class="ui-grid-vertical-bar">&nbsp;</div>
				<div class="ui-grid-cell-contents {{col.headerClass}}" col-index="renderIndex">
					{{ col.displayName CUSTOM_FILTERS }}
					<br>
					<select ng-model="grid.appScope.value[col.field]" ng-change="$event.stopPropagation();grid.appScope.yourFilterFunction(col.field)">
					</select>
				</div></div></div>
				"""

	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'no_matricula', type: 'number', maxWidth: 50, enableSorting: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'username', displayName: 'Usuario', headerCellTemplate: headerGroup}
			{ field: 'abrevgrupo', displayName: 'Grupo', enableCellEdit: false, cellTemplate: btMatricular, filter: {
					condition: uiGridConstants.filter.CONTAINS,
					placeholder: 'Abreviatura. Ej: 8A'
				}, 
			}
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'direccion', displayName: 'Dirección' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	
	RAlumnos.getList().then((data)->
		$scope.gridOptions.data = data;
	)

	$scope.borrar = (alum)->
		alum.delete().then((r)->
			console.log 'Eliminado con éxito', r
			$scope.toastr.success 'El alumno fue eliminado', 'Exito'
		, (r)->
			console.log 'No se pudo eliminar', r
			$scope.toastr.error 'No se pudo eliminar el alumno', 'Error'
		)


	$scope.$on 'alumnoguardado', (data, alum)->
		$scope.gridOptions.data.push alum

	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$modalInstance', 'alumno', 'Restangular', 'toastr', ($scope, $modalInstance, alumno, Restangular, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		Restangular.all('alumnos/destroy/'+alumno.alumno_id).remove().then((r)->
			toastr.success 'Eliminado', 'Alumno eliminado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo eliminar al alumno.', 'Problema'
			console.log 'Error eliminando alumno: ', r2
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


angular.module('myvcFrontApp')
.controller('CopiarCtrl', ['$scope', '$uibModal', 'Restangular', '$filter', '$rootScope', 'AuthService', 'toastr', 'App', 'YearsServ', 
	($scope, $modal, Restangular, $filter, $rootScope, AuthService, toastr, App, YearsServ) ->
		
		AuthService.verificar_acceso()

		$scope.configuracion = {copiar_subunidades: true, copiar_notas: true}
		$scope.periodos = []
		$scope.resultado = ''

		profe_id = $scope.USER.persona_id

		$scope.urlTplSubunidades = "#{App.views}unidades/subunidadespop.tpl.html"


		if $scope.hasRoleOrPerm('admin') == true
			$scope.profesores = []
			$scope.conprofes = true # Para indicar que el select de años se llene con la selección de un profe y no años traidos por get

			Restangular.all('profesores/conyears').getList().then((r)->
				$scope.profesores = r
			,(r)->
				console.log 'No se pudo traer los profes con años', r
			)

		else
			$scope.conprofes = false

			YearsServ.getYears().then((r)->
				$scope.years_copy = r
				$scope.years_copy_to = r
			, (r)->
				console.log 'No se pudo traer los años a copiar', r
			)




		# ORIGEN
		$scope.profesorSelect = ($item, $model)->
			$scope.years_copy = $item.years
			if $scope.configuracion.periodo_from
				$scope.configuracion.periodo_from = $scope.configuracion.year_from.periodos[0]
				$scope.periodoSelect($scope.configuracion.periodo_from)


		$scope.yearSelect = ($item, $model)->
			$scope.periodos = $item.periodos


		$scope.periodoSelect = ($item, $model)->

			if $scope.conprofes == true
				profe_id = $scope.configuracion.profesor_from.id

			Restangular.all('asignaturas/listasignaturasyear/'+profe_id+'/'+$scope.configuracion.periodo_from.id).getList().then((r)->
				$scope.asignaturas = r

				if $scope.configuracion.asignatura_from
					asig_id = $scope.configuracion.asignatura_from.asignatura_id
					asig_found = $filter('filter')($scope.asignaturas, {asignatura_id: asig_id})[0]
					$scope.configuracion.asignatura_from = asig_found

					$scope.asignaturaSelect asig_found

			, (r2)->
				console.log 'No se pudo traer las asignaturas origen, ', r2
			)

		$scope.asignaturaSelect = ($item, $model)->
			if $item and $item.unidades
				$scope.unidades = $item.unidades
			else
				$scope.unidades = []



		# DESTINO
		$scope.profesorToSelect = ($item, $model)->
			$scope.years_copy_to = $item.years
			if $scope.configuracion.periodo_to
				$scope.configuracion.periodo_to = $scope.configuracion.year_to.periodos[0]
				$scope.periodoToSelect($scope.configuracion.periodo_to)


		$scope.yearToSelect = ($item, $model)->
			$scope.periodos_to = $item.periodos


		$scope.periodoToSelect = ($item, $model)->

			if $scope.conprofes == true
				profe_id = $scope.configuracion.profesor_to.id

			Restangular.all('asignaturas/listasignaturasyear/'+profe_id+'/'+$scope.configuracion.periodo_to.id).getList().then((r)->
				$scope.asignaturas_to = r

				if $scope.configuracion.asignatura_to
					asig_id = $scope.configuracion.asignatura_to.asignatura_id
					asig_found = $filter('filter')($scope.asignaturas_to, {asignatura_id: asig_id})[0]
					$scope.configuracion.asignatura_to = asig_found

					$scope.asignaturaToSelect asig_found

			, (r2)->
				console.log 'No se pudo traer las asignaturas destino, ', r2
			)

		$scope.asignaturaToSelect = ($item, $model)->

			if $item and $item.unidades
				$scope.unidades_to = $item.unidades
			else
				$scope.unidades_to = []

			$scope.activar_btn_copiar = true



		# COPIAR
		$scope.copiar = ()->

			$scope.activar_btn_copiar = false

			unidades_a_copiar = $filter('filter')($scope.unidades.items, {seleccionada: true})
			unidades_ids = []

			angular.forEach unidades_a_copiar, (value, key) ->
				unidades_ids.push value.id
			

			datos = 
				copiar_subunidades: 	$scope.configuracion.copiar_subunidades
				copiar_notas:			$scope.configuracion.copiar_notas
				asignatura_to_id:		$scope.configuracion.asignatura_to.asignatura_id
				periodo_from_id: 		$scope.configuracion.periodo_from.id
				periodo_to_id: 			$scope.configuracion.periodo_to.id
				unidades_ids: 			unidades_ids
				grupo_from_id:			$scope.configuracion.asignatura_from.grupo_id
				grupo_to_id:			$scope.configuracion.asignatura_to.grupo_id



			Restangular.one('periodos/copiar').customPUT(datos).then((r)->
				toastr.success 'Copiado con éxito'
				console.log 'Copiado con éxito', r
				$scope.activar_btn_copiar = true
				$scope.resultado = 'Unidades copiadas: ' + r.unidades_copiadas + 
									' - Subunidades copiadas: ' + r.subunidades_copiadas +
									' - Notas copidas: ' + r.notas_copiadas

				$scope.unidades_to.items.push unidad_a_copiar for unidad_a_copiar in unidades_a_copiar

				if $scope.configuracion.asignatura_from.asignatura_id == $scope.configuracion.asignatura_to.asignatura_id and $scope.configuracion.periodo_from.id==$scope.configuracion.periodo_to.id
					$scope.unidades.items.push unidad_a_copiar for unidad_a_copiar in unidades_a_copiar

			, (r2)->
				toastr.error 'No se pudieron copiar los datos'
				console.log 'No se pudieron copiar los datos', r2
				$scope.activar_btn_copiar = true
			)


	]
)

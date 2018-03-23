angular.module('myvcFrontApp')
.controller('CopiarCtrl', ['$scope', '$uibModal', '$http', '$filter', '$rootScope', 'AuthService', 'toastr', 'App', 'YearsServ',
	($scope, $modal, $http, $filter, $rootScope, AuthService, toastr, App, YearsServ) ->

		AuthService.verificar_acceso()
		$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

		$scope.configuracion = {copiar_subunidades: true, copiar_notas: true}
		$scope.periodos = []
		$scope.resultado = ''

		profe_id = $scope.USER.persona_id

		$scope.urlTplSubunidades = "==unidades/subunidadespop.tpl.html"

		###
		if $scope.hasRoleOrPerm('admin') == true
			$scope.profesores = []
			$scope.conprofes = true # Para indicar que el select de años se llene con la selección de un profe y no años traidos por get

			$http.get('::profesores/conyears').then((r)->
				$scope.profesores = r.data
			,(r)->
				toastr.error 'No se pudo traer los profes con años', r
			)

		else
			$scope.conprofes = false

			YearsServ.getYears().then((r)->
				$scope.years_copy = r
				$scope.years_copy_to = r
			, (r)->
				toastr.error 'No se pudo traer los años a copiar', r
			)
		###

		$scope.profesores = []
		if $scope.hasRoleOrPerm('admin') == true
			$scope.conprofes = true # Para indicar que el select de años se llene con la selección de un profe y no años traidos por get


		$http.get('::profesores/conyears').then((r)->
			$scope.profesores       = r.data
			if localStorage.asignatura_a_copiar
				$scope.asignatura_a_copiar = JSON.parse(localStorage.asignatura_a_copiar)

				if $scope.asignatura_a_copiar.profesor_id

					for profe in $scope.profesores
						if profe.id == $scope.asignatura_a_copiar.profesor_id
							$scope.configuracion.profesor_from	= profe
							$scope.years_copy             			= profe.years

							for year_search in $scope.years
								if year_search.id == $scope.asignatura_a_copiar.year_id
									$scope.configuracion.year_from  		= year_search
									$scope.yearSelect(year_search)

						# Para el año destino
						if profe.id == profe_id
							$scope.years_copy_to          = profe.years
							$scope.configuracion.year_to  = profe.years[profe.years.length-1]
							$scope.yearToSelect(profe.years[profe.years.length-1])

				else
					# Para el año destino
					for profe in $scope.profesores
						if profe.id == profe_id
							$scope.years_copy_to          = profe.years
							$scope.configuracion.year_to  = profe.years[profe.years.length-1]
							$scope.yearToSelect(profe.years[profe.years.length-1])


		,(r)->
			toastr.error 'No se pudo traer los profes con años', r
		)


		# ORIGEN
		$scope.profesorSelect = ($item, $model)->
			$scope.years_copy               = $item.years
			$scope.configuracion.year_from  = $scope.years_copy[$scope.years_copy.length-1]

			if $scope.configuracion.periodo_from
				$scope.configuracion.periodo_from = $scope.configuracion.year_from.periodos[0]
				$scope.periodoSelect($scope.configuracion.periodo_from)
			else
				$scope.periodos = $scope.configuracion.year_from.periodos

		$scope.yearSelect = ($item, $model)->
			$scope.periodos = $item.periodos
			if $scope.asignatura_a_copiar
				if $scope.asignatura_a_copiar.periodo_id

					for periodo in $scope.periodos
						if periodo.id == $scope.asignatura_a_copiar.periodo_id
							$scope.configuracion.periodo_from = periodo
							$scope.periodoSelect(periodo)


		$scope.periodoSelect = ($item, $model)->

			if $scope.asignatura_a_copiar
				profesor_id = $scope.asignatura_a_copiar.profesor_id
			else
				profesor_id = $scope.configuracion.profesor_from.id

			$http.get('::asignaturas/list-asignaturas-year/'+profesor_id+'/'+$scope.configuracion.periodo_from.id).then((r)->
				$scope.asignaturas = r.data

				if $scope.asignatura_a_copiar
					if $scope.asignatura_a_copiar.asignatura_id

						for asignatu in $scope.asignaturas
							if asignatu.asignatura_id == $scope.asignatura_a_copiar.asignatura_id
								$scope.configuracion.asignatura_from = asignatu
								$scope.asignaturaSelect asignatu


				if $scope.configuracion.asignatura_from
					asig_id = $scope.configuracion.asignatura_from.asignatura_id
					asig_found = $filter('filter')($scope.asignaturas, {asignatura_id: asig_id})[0]
					$scope.configuracion.asignatura_from = asig_found

					$scope.asignaturaSelect asig_found

			, (r2)->
				toastr.error 'No se pudo traer las asignaturas origen'
			)

		$scope.asignaturaSelect = ($item, $model)->
			if $item and $item.unidades
				for unidad in $item.unidades.items
					unidad.seleccionada = true
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

			$http.get('::asignaturas/list-asignaturas-year/'+profe_id+'/'+$scope.configuracion.periodo_to.id).then((r)->
				r = r.data
				$scope.asignaturas_to = r

				if $scope.configuracion.asignatura_to
					asig_id = $scope.configuracion.asignatura_to.asignatura_id
					asig_found = $filter('filter')($scope.asignaturas_to, {asignatura_id: asig_id})[0]
					$scope.configuracion.asignatura_to = asig_found

					$scope.asignaturaToSelect asig_found

			, (r2)->
				toastr.error 'No se pudo traer las asignaturas destino, ', r2
			)

		$scope.asignaturaToSelect = ($item, $model)->

			if $item and $item.unidades
				$scope.unidades_to = $item.unidades
			else
				$scope.unidades_to = []

			$scope.activar_btn_copiar = true



		# COPIAR
		$scope.copiar = ()->
			if !$scope.activar_btn_copiar
				return

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



			$http.put('::periodos/copiar', datos).then((r)->
				r = r.data
				toastr.success 'Copiado con éxito'
				$scope.activar_btn_copiar = true
				$scope.resultado = 'Unidades copiadas: ' + r.unidades_copiadas +
									' - Subunidades copiadas: ' + r.subunidades_copiadas +
									' - Notas copidas: ' + r.notas_copiadas

				$scope.unidades_to.items.push unidad_a_copiar for unidad_a_copiar in unidades_a_copiar

				if $scope.configuracion.asignatura_from.asignatura_id == $scope.configuracion.asignatura_to.asignatura_id and $scope.configuracion.periodo_from.id==$scope.configuracion.periodo_to.id
					$scope.unidades.items.push unidad_a_copiar for unidad_a_copiar in unidades_a_copiar

			, (r2)->
				toastr.error 'No se pudieron copiar los datos'
				$scope.activar_btn_copiar = true
			)


	]
)

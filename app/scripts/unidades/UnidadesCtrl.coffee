angular.module('myvcFrontApp')
.controller('UnidadesCtrl', ['$scope', '$uibModal', '$http', '$state', '$filter', 'AuthService', 'toastr', 'resolved_user', '$timeout', ($scope, $uibModal, $http, $state, $filter, AuthService, toastr, resolved_user, $timeout) ->

	AuthService.verificar_acceso()


	$scope.asignatura 		= {}
	$scope.asignatura_id 	= $state.params.asignatura_id
	$scope.datos 			    = {}
	$scope.UNIDAD 			  = $scope.USER.unidad_displayname
	$scope.GENERO_UNI 		= $scope.USER.genero_unidad
	$scope.SUBUNIDAD 		  = $scope.USER.subunidad_displayname
	$scope.GENERO_SUB 		= $scope.USER.genero_subunidad
	$scope.UNIDADES 		  = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES 		= $scope.USER.subunidades_displayname
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm

	$scope.activar_crear_unidad = true
	$scope.unidades = []


	$http.put('::unidades/de-asignatura-periodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).then((r)->
		
		$scope.anios_pasados = r.data.anios_pasados
		$scope.mostrar_poco_anteriores = true
		
		if r.data.unidades.length > 0
			for unidad in r.data.unidades
				unidad.anim_bloqueada = false
				unidad.subunidades = $filter('orderBy')(unidad.subunidades, 'orden')
				$scope.bloquear_animacion(unidad)

				if unidad
					for subuni in unidad.subunidades
						subuni.anim_bloqueada = false
						$scope.bloquear_animacion(subuni)

			$scope.unidades = r.data.unidades
			$scope.unidades = $filter('orderBy')($scope.unidades, 'orden')

			$scope.calcularPorcUnidades()
	, (r2)->
		toastr.error 'No se pudo traer las ' + $scope.UNIDADES, 'Problemas'
	)

	$http.get('::asignaturas/show/' + $scope.asignatura_id).then((r)->
		r = r.data
		$scope.asignatura = r
		$scope.inicializado = true
		$scope.profesor_id 	= r.profesor_id
		if not r
			$scope.no_asignatura = true
	, (r2)->
		toastr.error 'No se pudo traer los datos de la asignatura'
		$scope.no_asignatura = true
	)



	$scope.mostrarUnidadesEliminadas = ()->
		if $scope.mostrando_unidades_eliminadas
			$scope.mostrando_unidades_eliminadas = false
		else
			$http.put('::unidades/eliminadas/' + $scope.asignatura_id).then((r)->
				r = r.data
				$scope.unidades_eliminadas    = r.unidades_eliminadas
				$scope.subunidades_eliminadas = r.subunidades_eliminadas
				$scope.mostrando_unidades_eliminadas = true
			, (r2)->
				$scope.mostrando_unidades_eliminadas = true
				toastr.error 'No se pudo traer las unidades eliminadas'
			)


	$scope.restaurarUnidad = (unidad)->
		if !unidad.restaurando
			unidad.restaurando = true
			$http.put('::unidades/restore/'+unidad.id).then((r)->

				$scope.unidades.push unidad
				$scope.calcularPorcUnidades()
				$timeout(()->
					$scope.onSortUnidades(undefined, $scope.unidades)
				, 100)
				toastr.success 'Listo.'
			, (r2)->
				unidad.restaurando = false
				toastr.error 'Error restaurando', 'Problema'
			)




	$scope.mostrarSubunidadesEliminadas = ()->
		if $scope.mostrando_subunidades_eliminadas
			$scope.mostrando_subunidades_eliminadas = false
		else
			$http.put('::subunidades/eliminadas/' + $scope.asignatura_id).then((r)->
				r = r.data
				$scope.subunidades_eliminadas = r.subunidades
				$scope.mostrando_subunidades_eliminadas = true
			, (r2)->
				$scope.mostrando_subunidades_eliminadas = true
				toastr.error 'No se pudo traer las subunidades eliminadas'
			)


	$scope.restaurarSubunidad = (subunidad)->
		if !subunidad.restaurando
			subunidad.restaurando = true
			$http.put('::subunidades/restore/'+subunidad.id).then((r)->
				toastr.success 'Listo. Recargue para ver los cambios'
			, (r2)->
				subunidad.restaurando = false
				toastr.error 'Error restaurando', 'Problema'
			)





	$scope.copiarUnidade = ()->
		$scope.asignatura.periodo_id      = $scope.USER.periodo_id
		$scope.asignatura.year_id         = $scope.USER.year_id
		
		modalInstance = $uibModal.open({
			templateUrl: '==unidades/copiarUnidadModal.tpl.html'
			controller: 'CopiarUnidadModalCtrl'
			resolve:
				USER: ()->
					$scope.USER
				asignatura: ()->
					$scope.asignatura
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
		, ()->
			# nada
		)



	$scope.copiarUnidades = ()->
		$scope.asignatura.periodo_id      = $scope.USER.periodo_id
		$scope.asignatura.year_id         = $scope.USER.year_id
		localStorage.asignatura_a_copiar  = JSON.stringify($scope.asignatura)
		$state.go('panel.copiar')



	$scope.calcularPorcUnidades = ()->
		sum = 0
		angular.forEach $scope.unidades, (unidad, key) ->
			sum = sum + unidad.porcentaje

			subsum = 0
			angular.forEach unidad.subunidades, (subunidad, key) ->
				subsum = subsum + subunidad.porcentaje

			unidad.subunidades.porc_subunidades = subsum
			unidad.subunidades.unidad_id = unidad.id # El ordenador me borra esta propiedad a cada rato, por eso la pongo aquí

		$scope.unidades.porc_unidades 	= sum




	$scope.crearUnidad = ()->

		$scope.activar_crear_unidad     = false

		$scope.newunidad.asignatura_id = $scope.asignatura.asignatura_id

		$http.post('::unidades', $scope.newunidad).then((r)->
			r = r.data
			r.subunidades = []
			r.obligatoria = 0
			r.anim_bloqueada = false
			$scope.unidades.push r

			creado = 'creado'
			if $scope.GENERO_UNI == 'F'
				creado = 'creada'

			toastr.success $scope.UNIDAD + ' ' + creado + '. Ahora agrégale ' + $scope.SUBUNIDADES
			$scope.newunidad.definicion = ''
			$scope.calcularPorcUnidades()
			$scope.activar_crear_unidad = true
			$scope.bloquear_animacion()
		, (r2)->
			toastr.error 'No se pudo crear la unidad', 'Problemas'
			$scope.activar_crear_unidad = true
		)



	$scope.actualizarUnidad = (unidad)->

		datos =
			definicion: 		unidad.definicion
			porcentaje: 		unidad.porcentaje
			asignatura_id: 	unidad.asignatura_id
			periodo_id: 		$scope.USER.periodo_id
			num_periodo: 		$scope.USER.numero_periodo

		$http.put('::unidades/update/' + unidad.id, datos).then((r)->

			actualizado = 'actualizado'
			if $scope.GENERO_UNI == 'F'
				actualizado = 'actualizada'

			toastr.success $scope.UNIDAD + ' ' + actualizado + ' con éxito.'
			unidad.editando = false
			$scope.calcularPorcUnidades()
		, (r2)->
			toastr.error 'No se pudo actualizar ' + $scope.UNIDAD, 'Problemas'
		)



	$scope.removeUnidad = (unidad)->

		modalInstance = $uibModal.open({
			templateUrl: '==unidades/removeUnidad.tpl.html'
			controller: 'RemoveUnidadCtrl'
			resolve:
				unidad: ()->
					unidad
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (unidad)->
			$scope.unidades = $filter('filter')($scope.unidades, {id: '!'+unidad.id})
			$scope.calcularPorcUnidades()
			$timeout(()->
				$scope.onSortUnidades(undefined, $scope.unidades)
			, 100)
		)



	$scope.onSortUnidades = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->

		sortHash = []

		for unidad, index in $partFrom
			unidad.orden = index

			hashEntry = {}
			hashEntry["" + unidad.id] = index
			sortHash.push(hashEntry)

		datos =
			sortHash: sortHash

		$http.put('::unidades/update-orden', datos).then((r)->
			return true
		, (r2)->
			toastr.warning 'No se pudo ordenar', 'Problema'
			return false;
		)

		$scope.calcularPorcUnidades()


	$scope.onStartSortUnidades= ($item, $part, $index, $helper)->
		console.log $item, $part

	$scope.bloquear_animacion = (elemento)->
		if !elemento
			return
		$timeout(()->
			elemento.anim_bloqueada   = true
		, 2000)


	$scope.activar_crear_subunidad = true


	$scope.onSortSubunidades = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->

		if $partFrom == $partTo

			sortHash = []

			for subunidad, index in $partFrom #subunidades
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash.push(hashEntry)

			datos =
				sortHash: sortHash

			$http.put('::subunidades/update-orden', datos).then((r)->
				return true
			, (r2)->
				toastr.warning 'No se pudo ordenar', 'Problema'
				return false;
			)

		else

			sortHash1 	= []
			sortHash2 	= []
			datos 		= {}

			# Actualizamos la primera parte
			for subunidad, index in $partFrom #subunidades
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash1.push(hashEntry)


			if sortHash1.length > 0
				datos.unidad1_id 	= $partFrom.unidad_id
				datos.sortHash1 	= sortHash1

			# Actualizamos la Segunda parte
			for subunidad, index in $partTo
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash2.push(hashEntry)


			if sortHash1.length > 0
				datos.unidad2_id 	= $partTo.unidad_id
				datos.sortHash2 	= sortHash2

			$http.put('::subunidades/update-orden-varias', datos).then((r)->
				return true
			, (r2)->
				toastr.warning 'No se pudo ordenar', 'Problema'
				return false;
			)

		$scope.calcularPorcUnidades()







	$scope.addSubunidad = (unidad)->

		$scope.activar_crear_subunidad  = false

		if !unidad.newsubunidad
			toastr.warning 'Aún debes escribir.'
			$scope.activar_crear_subunidad  = true
			return

		if !unidad.newsubunidad.definicion
			toastr.warning 'Debes escribir la difinición.'
			$scope.activar_crear_subunidad  = true
			return

		if !unidad.newsubunidad.porcentaje
			unidad.newsubunidad.porcentaje  = 0

		if !unidad.newsubunidad.nota_default
			unidad.newsubunidad.nota_default  = 0

		unidad.newsubunidad.unidad_id   = unidad.id
		unidad.newsubunidad.definicion  = unidad.newsubunidad.definicion.trim()

		$http.post('::subunidades', unidad.newsubunidad).then((r)->
			r.data.anim_bloqueada = false
			unidad.subunidades.push r.data

			creado = 'creado'
			if $scope.GENERO_SUB == 'F'
				creado = 'creada'

			toastr.success $scope.SUBUNIDAD + ' ' + creado + ' con éxito.'
			unidad.newsubunidad.definicion = ''
			$scope.calcularPorcUnidades()
			$scope.activar_crear_subunidad = true
			$scope.bloquear_animacion(r.data)
		, (r2)->
			toastr.error 'No se pudo crear  ' + (if $scope.GENERO_UNI=="M" then 'el' else 'la') + scope.SUBUNIDAD, 'Problemas'
			$scope.activar_crear_subunidad = true
		)

	$scope.ir_a_notas = (datos)->
		$state.go 'panel.notas', datos

	$scope.actualizarSubunidad = (subunidad, unidad)->

		datos =
			definicion: subunidad.definicion
			porcentaje: subunidad.porcentaje
			nota_default: subunidad.nota_default
			orden: subunidad.orden
			asignatura_id: 	unidad.asignatura_id
			periodo_id: 		$scope.USER.periodo_id
			num_periodo: 		$scope.USER.numero_periodo

		$http.put('::subunidades/update/' + subunidad.id, datos).then((r)->

			actualizado = 'actualizado'
			if $scope.GENERO_SUB == 'F'
				actualizado = 'actualizada'

			toastr.success $scope.SUBUNIDAD + ' ' + actualizado + ' con éxito.'
			subunidad.editando = false

			$scope.calcularPorcUnidades()
		, (r2)->
			toastr.error 'No se pudo actualizar ' + $scope.SUBUNIDAD, 'Problemas'
		)

	$scope.removeSubunidad = (unidad, subunidad)->

		modalInstance = $uibModal.open({
			templateUrl: '==unidades/removeSubunidad.tpl.html'
			controller: 'RemoveSubunidadCtrl'
			resolve:
				subunidad: ()->
					subunidad
				unidad: ()->
					unidad
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (unid)->
			unidad.subunidades = $filter('filter')(unidad.subunidades, {id: '!'+subunidad.id})
			$scope.calcularPorcUnidades()
			$timeout(()->
				$scope.onSortSubunidades(undefined, undefined, unidad.subunidades)
			, 100)
		)



])

.controller('RemoveUnidadCtrl', ['$scope', '$uibModalInstance', 'unidad', '$http', 'toastr', 'USER', ($scope, $modalInstance, unidad, $http, toastr, USER)->
	$scope.unidad = unidad

	$scope.ok = ()->

		datos =
			asignatura_id: 	unidad.asignatura_id
			periodo_id: 		USER.periodo_id
			num_periodo: 		USER.numero_periodo


		$http.delete('::unidades/destroy/'+unidad.id, {params: datos}).then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la unidad.', 'Problema'
		)
		$modalInstance.close(unidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('RemoveSubunidadCtrl', ['$scope', '$uibModalInstance', 'subunidad', 'unidad', 'USER', '$http', 'toastr', ($scope, $modalInstance, subunidad, unidad, USER, $http, toastr)->
	$scope.subunidad = subunidad

	$scope.ok = ()->

		datos =
			asignatura_id: 	unidad.asignatura_id
			periodo_id: 		USER.periodo_id
			num_periodo: 		USER.numero_periodo

		$http.delete('::subunidades/destroy/'+subunidad.id, {params: datos}).then((r)->
			toastr.success 'Subunidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la subunidad.', 'Problema'
		)
		$modalInstance.close(subunidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('CopiarUnidadModalCtrl', ['$scope', '$state', '$uibModalInstance', 'asignatura', 'USER', '$http', 'toastr', 'App', '$filter', ($scope, $state, $modalInstance, asignatura, USER, $http, toastr, App, $filter)->
	$scope.asignatura 		= asignatura
	$scope.UNIDAD			= USER.unidad_displayname
	$scope.GENERO_UNI 		= USER.genero_unidad
	$scope.SUBUNIDAD		= USER.subunidad_displayname
	$scope.GENERO_SUB 		= USER.genero_subunidad
	$scope.UNIDADES			= USER.unidades_displayname
	$scope.SUBUNIDADES 		= USER.subunidades_displayname
	$scope.configuracion 	= {copiar_subunidades: true, copiar_notas: true}
	$scope.views 			= App.views
	
	$http.get('::profesores/conyears').then((r)->
		$scope.profesores = r.data
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
			copiar_subunidades: 		$scope.configuracion.copiar_subunidades
			copiar_notas:				$scope.configuracion.copiar_notas
			asignatura_to_id:			asignatura.asignatura_id
			periodo_from_id: 			$scope.configuracion.periodo_from.id
			periodo_to_id: 				asignatura.periodo_id
			unidades_ids: 				unidades_ids
			grupo_from_id:				$scope.configuracion.asignatura_from.grupo_id
			grupo_to_id:				asignatura.grupo_id



		$http.put('::periodos/copiar', datos).then((r)->
			r = r.data
			toastr.success 'Copiado con éxito'
			$scope.activar_btn_copiar = true
			$scope.resultado = 'Unidades copiadas: ' + r.unidades_copiadas +
								' - Subunidades copiadas: ' + r.subunidades_copiadas +
								' - Notas copidas: ' + r.notas_copiadas

			$state.go 'panel.unidades', {asignatura_id: asignatura.asignatura_id}, {reload: true}


		, (r2)->
			toastr.error 'No se pudieron copiar los datos'
			$scope.activar_btn_copiar = true
		)

	

	$scope.ok = ()->

		$modalInstance.close(subunidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])






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


	$http.get('::unidades/de-asignatura-periodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).then((r)->
		if r.data.length > 0
			for unidad in r.data
				unidad.anim_bloqueada = false
				unidad.subunidades = $filter('orderBy')(unidad.subunidades, 'orden')
				$scope.bloquear_animacion(unidad)

				for subuni in unidad.subunidades
					subuni.anim_bloqueada = false
					$scope.bloquear_animacion(subuni)

			$scope.unidades = r.data
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






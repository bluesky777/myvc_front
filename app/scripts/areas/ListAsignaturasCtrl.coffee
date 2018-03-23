angular.module('myvcFrontApp')
.controller 'ListAsignaturasCtrl', ['$scope', '$http', 'toastr', '$state', '$cookies', '$rootScope', 'AuthService', 'App', 'resolved_user', '$filter', '$uibModal', ($scope, $http, toastr, $state, $cookies, $rootScope, AuthService, App, resolved_user, $filter, $modal) ->

	#$scope.$parent.bigLoader 	= true

	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.GENERO_UNI = $scope.USER.genero_unidad
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.GENERO_SUB = $scope.USER.genero_subunidad
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	$scope.dato = { }

	$scope.views = App.views + 'areas/' # La uso en jade

	$scope.mes = new Date().getMonth();

	$scope.profesor = {}

	if $state.params.profesor_id

		$scope.profesor_id = true

		$http.get('::asignaturas/listasignaturas/'+$state.params.profesor_id).then((r)->
			$scope.asignaturas            = r.data.asignaturas
			$scope.profesor               = r.data.info_profesor
			$scope.gruposcomportamientos  = r.data.grados_comp
			$scope.grupos                 = r.data.grupos
			$scope.pedidos                = r.data.pedidos
			$scope.materias               = r.data.materias
			#$scope.$parent.bigLoader 	= false

		, (r2)->
			toastr.error 'No se pudo traer las asignaturas'
			#$scope.$parent.bigLoader 	= false
		)


	else
		$http.get('::asignaturas/listasignaturas').then((r)->
			$scope.asignaturas 				    = r.data.asignaturas
			$scope.gruposcomportamientos 	= r.data.grados_comp
			$scope.grupos                 = r.data.grupos
			$scope.pedidos                = r.data.pedidos
			$scope.materias               = r.data.materias


			for pedido in $scope.pedidos
				if pedido.materia_to_add_accepted == 1 or pedido.asignatura_to_remove_accepted == 1
					pedido.estado = ':: APROBADO ::  '
				if pedido.materia_to_add_accepted == 0 or pedido.asignatura_to_remove_accepted == 0
					pedido.estado = ':: RECHAZADO ::  '


			#$scope.$parent.bigLoader 		= false
		, (r2)->
			toastr.error 'No se pudo traer tus asignaturas'
			#$scope.$parent.bigLoader 	= false
		)


	$scope.solicitarMateria = ()->
		if !$scope.dato.grupo
			toastr.warning 'Debes seleccionar un grupo.'
			return

		if !$scope.dato.materia
			toastr.warning 'Debes seleccionar una materia.'
			return

		if !$scope.dato.creditos > 0
			toastr.warning 'Debes asignar la intensidad horaria.'
			return

		$http.put('::ChangesAskedAssignment/solicitar-materia', { grupo_id: $scope.dato.grupo.id, materia_id: $scope.dato.materia.id, creditos: $scope.dato.creditos }).then((r)->
			$scope.pedidos.push r.data.pedido
			toastr.success 'Materia solicitada. Un administrador lo revisará.'
		, (r2)->
			toastr.error 'No se pudo solicitar materia'
			#$scope.$parent.bigLoader 	= false
		)


	$scope.quitarSolicitud = (pedido)->

		$http.put('::ChangesAsked/destruir-pedido-asignatura', { asked_id: pedido.asked_id, assignment_id: pedido.assignment_id }).then((r)->
			$scope.pedidos = $filter('filter')($scope.pedidos, {asked_id: '!'+pedido.asked_id})
			toastr.success 'Solicitada eliminada'
		, (r2)->
			toastr.error 'No se pudo solicitar materia'
			#$scope.$parent.bigLoader 	= false
		)


	$scope.noEsMia = (asignatura)->

		for pedido in $scope.pedidos
			if pedido.asignatura_to_remove_id==asignatura.asignatura_id and !pedido.asignatura_to_remove_accepted
				toastr.info 'Ya has hecho esta solicitud'
				return

		modalInstance = $modal.open({
			templateUrl: '==areas/asignaturaNoEsMia.tpl.html'
			controller: 'AsignaturaNoEsMiaCtrl'
			resolve:
				asignatura: ()->
					asignatura
		})
		modalInstance.result.then( (r)->
			toastr.success 'Has solicitado remoción de asignatura.'
			$scope.pedidos.push r.pedido
		)


	$scope.irDefinitivas = (asignatura)->
		localStorage.asignatura_id_def  = asignatura.asignatura_id
		$state.go('panel.definitivas_periodos', {profesor_id: $state.params.profesor_id})




	$scope.open = (asignatura)->
		$state.go 'panel.unidades', {asignatura_id: asignatura.asignatura_id}


]




.controller('AsignaturaNoEsMiaCtrl', ['$scope', '$uibModalInstance', 'asignatura', '$http', 'toastr', 'App', ($scope, $modalInstance, asignatura, $http, toastr, App)->

	$scope.asignatura = asignatura

	$scope.ok = ()->

		datos = { asignatura_id: asignatura.asignatura_id }

		$http.put('::ChangesAskedAssignment/pedir-quitar-asignatura', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo hacer solicitud.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



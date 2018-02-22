angular.module('myvcFrontApp')

.directive('anunciosDir',['App', '$http', 'toastr', '$uibModal', '$state', (App, $http, toastr, $modal, $state)->

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->

		scope.perfilPath = App.images+'perfil/'

		if $state.is 'panel'
			$http.get('::ChangesAsked/to-me').then((r)->
				scope.changes_asked = r.data
			, (r2)->
				#toastr.error 'No se pudo traer los anuncios.'
				console.log r2
			)

	controller: 'AnunciosDirCtrl'
])


.controller('AnunciosDirCtrl', ['$scope', '$uibModal', 'AuthService', '$http', 'toastr', ($scope, $modal, AuthService, $http, toastr)->

	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.verDetalles = (change_asked)->
		if change_asked.mostrando
			change_asked.mostrando = false
		else
			change_asked.mostrando = true

			if not change_asked.detalles
				datos = { asked_id: change_asked.asked_id,  }

				$http.put('::ChangesAsked/ver-detalles', datos).then((r)->
					change_asked.detalles = r.data.detalles
				, (r2)->
					console.log 'Error trayendo detalles', r2
				)


	$scope.rechazarCambio = (asked, tipo)->

		modalInstance = $modal.open({
			templateUrl: '==panel/rechazarAsked.tpl.html'
			controller: 'RechazarAskedCtrl'
			resolve:
				asked: ()->
					asked
				tipo: ()->
					tipo
		})
		modalInstance.result.then( (r)->
			toastr.info 'Pedido rechazado.'
			asked.finalizado = r.finalizado

			if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = false
			if tipo == 'foto_oficial' 	then asked.detalles.foto_id_accepted = false
			if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = false
		)

	$scope.aprobarCambio = (asked, tipo, valor_nuevo)->

		modalInstance = $modal.open({
			templateUrl: '==panel/aceptarAsked.tpl.html'
			controller: 'AceptarAskedCtrl'
			resolve:
				asked: ()->
					asked
				tipo: ()->
					tipo
				valor_nuevo: ()->
					valor_nuevo
		})
		modalInstance.result.then( (r)->
			toastr.success 'Pedido aceptado.'
			asked.finalizado = r.finalizado

			if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = true
			if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = true
			if tipo == 'nombres' 	    then asked.detalles.nombres_accepted = true
			if tipo == 'apellidos' 	  then asked.detalles.apellidos_accepted = true
			if tipo == 'sexo' 	      then asked.detalles.sexo_accepted = true
			if tipo == 'fecha_nac' 	  then asked.detalles.fecha_nac_accepted = true
			if tipo == 'foto_oficial'
				asked.detalles.foto_id_accepted = true
				asked.foto_nombre 				= asked.detalles.foto_new_nombre

			if tipo == 'asignatura' then asked.finalizado = true

		)

	$scope.eliminarSolicitudes = (asked)->

		modalInstance = $modal.open({
			templateUrl: '==panel/eliminarAsked.tpl.html'
			controller: 'EliminarAskedCtrl'
			resolve:
				asked: ()->
					asked
		})
		modalInstance.result.then( (r)->
			toastr.success 'Pedido eliminado.'
			asked.finalizado = true
		)

])



.controller('AceptarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', 'valor_nuevo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, valor_nuevo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked


	$scope.aceptarAsignatura = ()->
			datos = { pedido: asked, tipo: tipo, asker_id: asked.asked_by_user_id }

			$http.put('::ChangesAsked/aceptar-asignatura', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)


	$scope.ok = ()->
		if asked.assignment_id
			$scope.aceptarAsignatura()
		else
			datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id, tipo: tipo, valor_nuevo: valor_nuevo, asker_id: asked.asked_by_user_id }

			if asked.alumno_id
				datos.alumno_id = asked.alumno_id

			$http.put('::ChangesAsked/aceptar-alumno', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.controller('RechazarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		data_id       = if asked.detalles then asked.detalles.data_id else asked.assignment_id
		assignment_id = asked.detalles.assignment_id

		datos = { asked_id: asked.asked_id, data_id: data_id, assignment_id: assignment_id, tipo: tipo, asker_id: asked.asked_by_user_id }

		$http.put('::ChangesAsked/rechazar', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo rechazar petición.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('EliminarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id }

		$http.put('::ChangesAsked/destruir', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo eliminar peticiones.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



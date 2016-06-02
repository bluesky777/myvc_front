angular.module('myvcFrontApp')

.directive('anunciosDir',['App', '$http', 'toastr', '$uibModal', '$state', (App, $http, toastr, $modal, $state)-> 

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->
		
		scope.perfilPath = App.images+'perfil/'

		if $state.is 'panel'
			$http.get('::ChangesAsked/to-me').then((r)->
				scope.changes_asked_to_me = r.data.cambios
				scope.changes_asked_elim = r.data.cambios_elim
			, (r2)->
				toastr.error 'No se pudo traer los anuncios.'
			)

	controller: 'AnunciosDirCtrl'
])


.controller('AnunciosDirCtrl', ['$scope', '$uibModal', 'AuthService', ($scope, $modal, AuthService)->
	
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.verDetalles = (row)->

		modalInstance = $modal.open({
			templateUrl: '==panel/verDetalles.tpl.html'
			controller: 'VerDetallesCtrl'
			resolve: 
				asked: ()->
					$http.get('::change')
		})
		modalInstance.result.then( (asked)->
			#console.log 'Resultado del modal: ', asked
		)

	$scope.rechazarAsked = (row)->

		modalInstance = $modal.open({
			templateUrl: '==panel/rechazarAsked.tpl.html'
			controller: 'RechazarAskedCtrl'
			resolve: 
				asked: ()->
					row
		})
		modalInstance.result.then( (asked)->
			#console.log 'Resultado del modal: ', asked
		)

])


.controller('VerDetallesCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = {asked_id: asked.id}

		$http.put('::ChangesAsked/aceptar', datos).then((r)->
			r = r.data
			toastr.success 'Pedido aceptado.', 'Éxito'
			asked.deleted_at 	= r.deleted_at
			asked.accepted_at 	= r.deleted_at
			asked.deleted_by 	= r.deleted_by
			asked.comentario 	= r.comentario
			asked.oficial_image_id = r.oficial_image_id
			asked.foto_nombre	= asked.foto_nombre_asked

		, (r2)->
			toastr.warning 'Problema', 'No se pudo aceptar petición.'
		)
		$modalInstance.close(asked)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AceptarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = {asked_id: asked.id}

		$http.put('::ChangesAsked/aceptar', datos).then((r)->
			r = r.data
			toastr.success 'Pedido aceptado.', 'Éxito'
			asked.deleted_at 	= r.deleted_at
			asked.accepted_at 	= r.deleted_at
			asked.deleted_by 	= r.deleted_by
			asked.comentario 	= r.comentario
			asked.oficial_image_id = r.oficial_image_id
			asked.foto_nombre	= asked.foto_nombre_asked

		, (r2)->
			toastr.warning 'Problema', 'No se pudo aceptar petición.'
		)
		$modalInstance.close(asked)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.controller('RechazarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = {asked_id: asked.id}

		$http.put('::ChangesAsked/rechazar', datos).then((r)->
			r = r.data
			toastr.success 'Pedido aceptado.', 'Éxito'
			asked.deleted_at 	= r.deleted_at
			asked.rechazado_at 	= r.deleted_at
			asked.deleted_by 	= r.deleted_by
			asked.comentario 	= r.comentario

		, (r2)->
			toastr.warning 'Problema', 'No se pudo rechazar petición.'
		)
		$modalInstance.close(asked)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



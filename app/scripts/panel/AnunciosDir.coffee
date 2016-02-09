angular.module('myvcFrontApp')

.directive('anunciosDir',['App', 'Restangular', 'toastr', '$modal', (App, Restangular, toastr, $modal)-> 

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->
		
		scope.perfilPath = App.images+'perfil/'


		Restangular.one('ChangesAsked/to-me').customGET().then((r)->
			scope.changes_asked_to_me = r
		, (r2)->
			toastr.error 'No se pudo traer los anuncios.'
		)

	controller: 'AnunciosDirCtrl'
])


.controller('AnunciosDirCtrl', ['$scope', 'Restangular', 'toastr', '$modal', 'App', ($scope, Restangular, toastr, $modal, App)->
	

	$scope.aceptarAsked = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'panel/aceptarAsked.tpl.html'
			controller: 'AceptarAskedCtrl'
			resolve: 
				asked: ()->
					row
		})
		modalInstance.result.then( (asked)->
			console.log 'Resultado del modal: ', asked
		)

	$scope.rechazarAsked = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'panel/rechazarAsked.tpl.html'
			controller: 'RechazarAskedCtrl'
			resolve: 
				asked: ()->
					row
		})
		modalInstance.result.then( (asked)->
			console.log 'Resultado del modal: ', asked
		)

])


.controller('AceptarAskedCtrl', ['$scope', '$modalInstance', 'asked', 'Restangular', 'toastr', 'App', ($scope, $modalInstance, asked, Restangular, toastr, App)->
	
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = {asked_id: asked.id}

		Restangular.one('ChangesAsked/aceptar').customPUT(datos).then((r)->
			toastr.success 'Pedido aceptado.', 'Éxito'
			asked.deleted_at 	= r.deleted_at
			asked.accepted_at 	= r.deleted_at
			asked.deleted_by 	= r.deleted_by
			asked.comentario 	= r.comentario
			asked.oficial_image_id = r.oficial_image_id
			asked.foto_nombre	= asked.foto_nombre_asked

		, (r2)->
			toastr.warning 'Problema', 'No se pudo aceptar petición.'
			console.log 'Error aceptando asked: ', r2
		)
		$modalInstance.close(asked)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




.controller('RechazarAskedCtrl', ['$scope', '$modalInstance', 'asked', 'Restangular', 'toastr', 'App', ($scope, $modalInstance, asked, Restangular, toastr, App)->
	
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = {asked_id: asked.id}

		Restangular.one('ChangesAsked/rechazar').customPUT(datos).then((r)->
			toastr.success 'Pedido aceptado.', 'Éxito'
			asked.deleted_at 	= r.deleted_at
			asked.rechazado_at 	= r.deleted_at
			asked.deleted_by 	= r.deleted_by
			asked.comentario 	= r.comentario

		, (r2)->
			toastr.warning 'Problema', 'No se pudo rechazar petición.'
			console.log 'Error rechando asked: ', r2
		)
		$modalInstance.close(asked)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



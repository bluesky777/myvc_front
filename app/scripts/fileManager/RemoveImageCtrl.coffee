angular.module("myvcFrontApp")

.controller('RemoveImageCtrl', ['$scope', '$modalInstance', 'imagen', 'App', 'Restangular', ($scope, $modalInstance, imagen, App, Restangular)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.imagen = imagen

	$scope.ok = ()->

		Restangular.all('myimages/destroy/'+imagen.id).remove().then((r)->
			console.log 'Imagen removida con éxito.'
		, (r2)->
			console.log 'No se pudo eliminar la imagen.', r2
		)
		$modalInstance.close(imagen)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	return
])
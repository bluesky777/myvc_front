angular.module("myvcFrontApp")

.controller('RemoveImageCtrl', ['$scope', '$modalInstance', 'imagen', 'user_id', 'datos_imagen', 'App', 'Restangular', 'AuthService', ($scope, $modalInstance, imagen, user_id, datos_imagen, App, Restangular, AuthService)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.imagen = imagen
	$scope.datos_imagen = datos_imagen
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

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
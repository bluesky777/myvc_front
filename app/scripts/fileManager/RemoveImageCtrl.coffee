angular.module("myvcFrontApp")

.controller('RemoveImageCtrl', ['$scope', '$uibModalInstance', 'imagen', 'user_id', 'datos_imagen', 'App', '$http', 'AuthService', 'toastr', ($scope, $modalInstance, imagen, user_id, datos_imagen, App, $http, AuthService, toastr)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.imagen = imagen
	$scope.datos_imagen = datos_imagen
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.ok = ()->

		$http.delete('::myimages/destroy/'+imagen.id).then((r)->
			console.log 'Proceso de eliminado exitoso'
		, (r2)->
			toastr.error 'No se pudo eliminar la imagen.'
		)
		$modalInstance.close(imagen)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	return
])
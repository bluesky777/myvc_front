'use strict'

angular.module("myvcFrontApp")


.controller('VerPublicacionModalCtrl', ['$scope', 'App', '$uibModalInstance', 'publicacion_actual', 'USER', '$http', 'toastr', '$filter', ($scope, App, $modalInstance, publicacion_actual, USER, $http, toastr, $filter)->
	$scope.publicacion_actual 		= publicacion_actual
	$scope.perfilPath             = App.images+'perfil/'
	$scope.USER                   = USER
	$scope.new_comentario         = ''


	$scope.agregarComentario = (comentario)->

		datos = { publi_id: $scope.publicacion_actual.id, comentario: comentario }

		$http.put('::publicaciones/comentar', datos).then((r)->

			$scope.new_comentario         = ''

			new_coment = {
				id: r.data.comentario_id
				publicacion_id: $scope.publicacion_actual.id
				comentario: comentario
				nombre_autor: $scope.USER.nombres + ' ' + $scope.USER.apellidos
				foto_autor: $scope.USER.foto_nombre
			}

			$scope.publicacion_actual.comentarios.push(new_coment)


		, (r2)->
			toastr.error 'Error al eliminar', 'Problema'
			return {}
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	$scope.ok = ()->
		$modalInstance.close(publicacion_actual)

])

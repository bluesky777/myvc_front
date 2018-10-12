'use strict'

angular.module("myvcFrontApp")


.controller('VerPublicacionModalCtrl', ['$scope', 'App', '$uibModalInstance', 'publicacion_actual', 'USER', '$http', 'toastr', '$filter', ($scope, App, $modalInstance, publicacion_actual, USER, $http, toastr, $filter)->
	$scope.publicacion_actual 		= publicacion_actual
	$scope.perfilPath             = App.images+'perfil/'
	$scope.USER                   = USER
	$scope.new_comentario         = ''
	$scope.guardando_coment       = false


	$scope.agregarComentario = (comentario)->
		$scope.guardando_coment = true
		datos = { publi_id: $scope.publicacion_actual.id, comentario: comentario }

		$http.put('::publicaciones/comentar', datos).then((r)->

			$scope.new_comentario         = ''

			new_coment = {
				id: r.data.comentario_id
				publicacion_id: $scope.publicacion_actual.id
				comentario: comentario
				nombre_autor: if $scope.USER.nombres then ($scope.USER.nombres + ' ' + $scope.USER.apellidos) else $scope.USER.username
				foto_autor: $scope.USER.foto_nombre
			}

			$scope.publicacion_actual.comentarios.push(new_coment)
			$scope.guardando_coment       = false

		, (r2)->
			toastr.error 'Error al eliminar', 'Problema'
			$scope.guardando_coment       = false
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	$scope.ok = ()->
		$modalInstance.close(publicacion_actual)

])

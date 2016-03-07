angular.module("myvcFrontApp")

.controller('ResultadosCtrl', ['$scope', '$http', 'App', ($scope, $http, App)->


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.imagesPath = App.images + 'perfil/'

	$http.get('::votos/show').then((r)->
		$scope.votaciones = r.data
	, (r2)->
		toastr.error 'Error trayendo las votaciones.'
	)



	return
])

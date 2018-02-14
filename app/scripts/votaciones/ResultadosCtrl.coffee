angular.module("myvcFrontApp")

.controller('ResultadosCtrl', ['$scope', '$http', 'App', 'toastr', ($scope, $http, App, toastr)->


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.imagesPath = App.images + 'perfil/'

	$http.put('::votos/show').then((r)->
		$scope.votaciones = r.data.votaciones
		$scope.year       = r.data.year
	, (r2)->
		toastr.error 'Error trayendo las votaciones.'
	)



	return
])

.controller('TarjetonesCtrl', ['$scope', '$http', 'App', 'toastr', ($scope, $http, App, toastr)->


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.imagesPath = App.images + 'perfil/'


	$http.put('::votos/show').then((r)->
		$scope.votaciones = r.data.votaciones
		$scope.year       = r.data.year
	, (r2)->
		toastr.error 'Error trayendo las votaciones.'
	)


	###
	$http.get('::votaciones/actual').then((r)->
		$scope.votacion = r.data
	, (r2)->
		toastr.error 'Error trayendo las votaciones.'
	)

	$http.get('::candidatos/conaspiraciones').then((r)->
		$scope.aspiraciones = r.data
	, (r2)->
		toastr.error 'No se pudo traer las aspiraciones', 'Problema'
	)
	###



	return
])

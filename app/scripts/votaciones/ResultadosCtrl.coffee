angular.module("myvcFrontApp")

.controller('ResultadosCtrl', ['$scope', '$filter', 'Restangular', 'App', '$state', '$uibModal', '$window', ($scope, $filter, Restangular, App, $state, $modal, $window)->


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.imagesPath = App.images + 'perfil/'

	Restangular.one('votos/show').get().then((r)->
		$scope.votaciones = r
	, (r2)->
		console.log 'Error trayendo las votaciones. ', r2
	)



	return
])

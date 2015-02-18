'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresEditCtrl', ['$scope', '$rootScope', '$interval', 'RProfesores', ($scope, $rootScope, $interval, RProfesores)->

	$scope.profesor = 
		'nombres'		: 'FRANCISCO'
		'apellidos'		: 'BAEZ'
		'sexo'			: 'M'


	$scope.guardar = ()->
		RProfesores.post($scope.profesor).then((r)->
			console.log 'Se hizo el post del profesor', r
		)
	return
])

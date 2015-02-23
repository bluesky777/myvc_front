angular.module('myvcFrontApp')
.controller('UserConfiguracionCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App) ->

	$scope.data = {} # Para el popup del Datapicker
	$scope.comprobando = false
	$scope.mostrarErrorUsername = false
	$scope.mostrarErrorPassword = false
	$scope.newusername = ''
	$scope.passantiguo = ''

	$scope.nombresdeusuario=[]

	Restangular.all('perfiles/usernames').getList().then((r)->
		$scope.nombresdeusuario = r
	, (r2)->
		console.log 'No se trajeron los nombres de usuario', r2
	)

	$scope.comprobarusername = ()->
		$scope.comprobando = true

		if $scope.newusername.username
			$scope.newusername = $scope.newusername.username
		if $scope.newusername == ''
			$scope.toastr.warning 'Debes copiar un nombre de usuario.'
			$scope.comprobando = false
			return

		Restangular.all('perfiles/comprobarusername/'+$scope.newusername).getList().then((r)->
			if r[0].existe
				$scope.mostrarErrorUsername = true
			else
				$scope.mostrarErrorUsername = false
			$scope.comprobando = false
		, (r2)->
			console.log 'No se trajeron los nombres de usuario', r2
			$scope.comprobando = false
		)

	$scope.guardar = ()->
		console.log 'A guardar'
		datos = 
			nombres:	$scope.perfilactual.nombres
			apellidos:	$scope.perfilactual.apellidos
			sexo:		$scope.perfilactual.sexo
			fecha_nac:	$scope.perfilactual.fecha_nac
			celular:	$scope.perfilactual.celular
			email:		$scope.perfilactual.email
			tipo:		$scope.perfilactual.tipo

		Restangular.one('perfiles/update', $scope.perfilactual.persona_id).customPUT(datos).then((r)->
			console.log 'Datos guardados, ', r
			$scope.toastr.success 'Datos guardados'
		, (r2)->
			console.log 'No se pudo guardar cambios, ', r2
			$scope.toastr.error 'Datos NO guardados', 'Problema'
		)

	$scope.CambiarUsername = ()->
		Restangular.one('perfiles/guardarusername', $scope.perfilactual.user_id).customPUT({'username':$scope.newusername}).then((r)->
			console.log 'Nombre de usuario guardado, ', r
			$scope.toastr.success 'Nombre de usuario guardado'
		, (r2)->
			console.log 'No se pudo guardar nombre de usuario, ', r2
			$scope.toastr.error 'Nombre de usuario NO guardado', 'Problema'
		)

	$scope.CambiarPass = ()->
		if $scope.newpass != $scope.newpassverif
			$scope.toastr.warning 'Las contraseñas no coinciden'
			return
		if $scope.newpass.length < 4
			$scope.toastr.warning 'La contraseña debe tener mínimo 4 caracteres. Sin espacios ni Ñ ni tildes.'
			return

		datos = {'password':$scope.newpassverif, 'oldpassword': $scope.passantiguo }
		console.log datos
		Restangular.one('perfiles/cambiarpassword', $scope.perfilactual.user_id).customPUT(datos).then((r)->
			console.log 'Contraseña cambiada, ', r
			$scope.toastr.success 'Contraseña cambiada.'
		, (r2)->
			console.log 'No se pudo cambiar la contraseña, ', r2
			$scope.toastr.error 'No se pudo cambiar la contraseña', 'Problema'
		)

])

